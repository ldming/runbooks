#! /usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'

def jsonnet(input)
  Open3.capture2('jsonnet', '-', stdin_data: input).first
end

def feature_categories(json)
  JSON.parse(json).flat_map { |_k, v| v['feature_categories'] }
end

old_file = jsonnet(`git show HEAD:services/stage-group-mapping.jsonnet`)
new_file = jsonnet(File.read(File.join(File.dirname(__FILE__), '../services/stage-group-mapping.jsonnet')))
crossover_file = File.join(File.dirname(__FILE__), '../services/stage-group-mapping-crossover.jsonnet')

diff = (feature_categories(old_file) - feature_categories(new_file)).to_h do |category|
  [category, '']
end

File.open(crossover_file, "w") do |f|
  f.write(
    <<~JSONNET
      // This file is autogenerated using scripts/generate_crossover_stage_group_mappings.rb.
      // Please update it manually if feature categories were renamed, as:
      // {
      //   "old_category": "new_category",
      // }
      //
      // Blank values will be ignored.
      #{JSON.pretty_generate(diff, object_nl: "\n", array_nl: "\n", indent: '  ')}
    JSONNET
  )
end

`make jsonnet-fmt JSONNET_FILES=#{crossover_file}`
