# frozen_string_literal: true

require 'connection_pool'
require 'optparse'
require 'redis'
require 'yaml'

# This file requires the `redis` and `connection_pool` gems.
#
# On a VM node, run the following to setup
# ```
# gem install redis -v '~> 4.8.0'
# gem install connection_pool -v '~> 2.0'
# ```
#
# Usage: ruby redis_diff.rb --migrate --keys=1000
#
# Pre-requisite: Create 2 files, source.yml and destination.yml with details of
# the source and destination redis instances.
# option 1: url: redis://<username>:<password>@<host>:<port>
# if cluster, define cluster(list of objects with host and port keys) + username + password

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-m", "--migrate", "Copy mismatched key values (and their TTLs) from src to dst redis") do |v|
    options[:migrate] = v
  end

  opts.on("-k", "--keys=<number_of_keys>", "Number of keys to check") do |number_of_keys|
    options[:keys] = number_of_keys
  end

  opts.on("-t", "--type=<number_of_keys>", "Type of keys to check") do |key_type|
    options[:key_type] = key_type
  end

  opts.on("-c", "--cursor=<cursor>", "Cursor to start from") do |cursor|
    options[:cursor] = cursor
  end

  opts.on("-p", "--pattern=<pattern>", "Keys to match pattern") do |pattern|
    options[:match] = pattern
  end

  opts.on("-r", "--rate=<rate>", "Maximum allowed rate of keys being migrated per second") do |rate|
    options[:max_allowed_rate] = rate
  end

  opts.on("-ps", "--pool_size=<nbr>", "Redis connection pool size") do |nbr|
    options[:pool_size] = nbr
  end

  opts.on("-b", "--batch=<nbr>", "SCAN count, controls number of threads") do |nbr|
    options[:batch] = nbr
  end

  opts.on("-i", "--ignore=<ignore_pattern>", "Key pattern to ignore") do |ignore_pattern|
    options[:ignore_pattern] = ignore_pattern
  end
end.parse!

# Ensure the ttl is also migrated for a key
def migrate_ttl(src, dst, key)
  ttl = src.with { |c| c.ttl(key) }
  return if ttl == -1 # key does not have associated ttl
  return dst.with { |c| c.del(key) } if ttl == -2 # expired in src db

  dst.with { |c| c.expire(key, ttl) }
end

# Strings
def compare_string(src, dst, key)
  src.with { |c| c.get(key) } == dst.with { |c| c.get(key) }
end

def migrate_string(src, dst, key)
  string_details = src.with { |c| c.get(key) }

  # the hash could be expired/deleted between comparison and migration
  return if string_details.nil?

  dst.with { |c| c.set(key, string_details) }
  migrate_ttl(src, dst, key)
end

# Hash
def compare_hash(src, dst, key)
  src.with { |c| c.hgetall(key) } == dst.with { |c| c.hgetall(key) }
end

def migrate_hash(src, dst, key)
  hash_details = src.with { |c| c.hgetall(key) }

  # the hash could be expired/deleted between comparison and migration
  return if hash_details.empty?

  dst.with { |c| c.hset(key, hash_details) }
  migrate_ttl(src, dst, key)
end

# Set
def compare_set(src, dst, key)
  src_list = src.with { |c| c.smembers(key) }
  dst_list = dst.with { |c| c.smembers(key) }

  src_list & dst_list == src_list
end

def migrate_set(src, dst, key)
  members = src.with { |c| c.smembers(key) }

  # the hash could be expired/deleted between comparison and migration
  return if members.empty?

  dst.with { |c| c.sadd(key, members) }
  migrate_ttl(src, dst, key)
end

# List
def compare_list(src, dst, key)
  src_list = src.with { |c| c.lrange(key, 0, -1) }
  dst_list = dst.with { |c| c.lrange(key, 0, -1) }

  src_list & dst_list == src_list
end

def migrate_list(src, dst, key)
  src_list = src.with { |c| c.lrange(key, 0, -1) }
  dst.with { |c| c.rpush(key, src_list) } # rpush to maintain order
  migrate_ttl(src, dst, key)
end

# Zset
def compare_zset(src, dst, key)
  src_list = src.with { |c| c.zrange(key, 0, -1, withscores: true) }
  dst_list = dst.with { |c| c.zrange(key, 0, -1, withscores: true) }

  src_list & dst_list == src_list
end

def migrate_zset(src, dst, key)
  # map to switch order of score and member as zrange returns <member, score>
  # but zadd expects <score, member>
  source_zset = src.with { |c| c.zrange(key, 0, -1, withscores: true) }.map { |x, y| [y, x] }
  dst.with { |c| c.zadd(key, source_zset) }
  migrate_ttl(src, dst, key)
end

def compare_and_migrate(key, src, dst, migrate)
  ktype = src.with { |r| r.type(key) }

  unless %w[hash set string list zset].include?(ktype)
    puts "Unsupported #{key} of #{ktype}"
    return nil
  end

  identical = send("compare_#{ktype}", src, dst, key) # rubocop:disable GitlabSecurity/PublicSend

  unless identical
    puts "key #{key} differs"

    # alternatively we can run MIGRATE command but we need to know which port
    # and it only works when migrating from a lower Redis version to a higher Redis version
    if migrate # some argv
      puts "migrating #{key}..."
      send("migrate_#{ktype}", src, dst, key) # rubocop:disable GitlabSecurity/PublicSend
    end
  end

  !identical
end

def src_redis
  puts "creating src_redis object"
  ::Redis.new(YAML.load_file('source.yml').transform_keys(&:to_sym))
end

def dest_redis
  puts "creating dest_redis object"
  ::Redis.new(YAML.load_file('destination.yml').transform_keys(&:to_sym))
end

checked = 0
diffcount = 0
migrated_count = 0
unsupported_count = 0
ignored_count = 0

max_allowed_rate = (options[:max_allowed_rate] || 500.0).to_f
it = options[:cursor] || "0"
batch = (options[:batch] || 10).to_i
pool_size = (options[:pool_size] || 10).to_i

src_db = ConnectionPool.new(size: pool_size, timeout: 60) { src_redis }
dest_db = ConnectionPool.new(size: pool_size, timeout: 60) { dest_redis }

scan_params = { match: "*", count: batch }
scan_params[:type] = options[:key_type] if options[:key_type]
scan_params[:match] = options[:match] if options[:match]

ignore_regexp = /#{options[:ignore_pattern]}/ if options[:ignore_pattern]

begin
  loop do
    current_cursor = it
    it, keys = src_db.with { |r| r.scan(it, **scan_params) }

    puts "Scanned #{keys.size} for #{current_cursor}"

    start = Time.now
    keys_to_recheck = []

    threads = []
    # first pass to compare and migrate keys if not identical
    keys.each_with_index do |key, idx|
      if ignore_regexp && key.match?(ignore_regexp)
        ignored_count += 1
        next
      end

      threads << Thread.new do
        result = compare_and_migrate(key, src_db, dest_db, options[:migrate])

        unsupported_count += 1 if result.nil?

        if result
          diffcount += 1
          keys_to_recheck << idx
        end
      end
    end
    threads.each(&:join)

    threads = []
    # perform a 2nd iteraation to recheck keys to confirm convergence
    # instead of immediately checking in the above loop
    if options[:migrate]
      keys.each_with_index do |key, idx|
        next unless keys_to_recheck.include?(idx)

        threads << Thread.new do
          if !compare_and_migrate(key, src_db, dest_db, false)
            migrated_count += 1
          else
            # TODO write persistent mismatches into a tmp file?
            puts "Failed to migrate #{key}"
          end
        end
      end
      threads.each(&:join)
    end

    checked += keys.size
    duration = Time.now - start
    wait = (keys.size / max_allowed_rate) - duration
    if wait.positive?
      puts "Processing at #{keys.size / duration} ops per second. Sleeping for #{wait} to maintain max of #{max_allowed_rate}"
      sleep(wait)
    end

    puts "Checked #{keys.size} keys from cursor #{current_cursor}"

    break if options[:keys] && checked > options[:keys].to_i
    break if it == "0"
  end
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.to_s
end

puts "Checked #{checked}"
puts "#{diffcount} different keys"
puts "#{unsupported_count} unsupported type keys"
puts "#{ignored_count} ignored keys"
puts "Migrated #{migrated_count} keys successfully"
