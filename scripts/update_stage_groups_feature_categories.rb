#! /usr/bin/env ruby
# frozen_string_literal: true
require 'net/http'
require 'yaml'
require 'json'
require 'fileutils'
require 'logger'

##
# Generate a slim jsonnet stage group file from Gitlab's stages data.
# This jsonnet file is mostly used to generate Grafana dashboards for each group.
class UpdateStageGroupsFeatureCategories
  DEFAULT_STAGE_URL = 'https://gitlab.com/gitlab-com/www-gitlab-com/-/raw/master/data/stages.yml'
  DEFAULT_MAPPING_PATH = File.expand_path(File.join(File.dirname(__FILE__), '../services/stage-group-mapping.jsonnet'))

  def initialize(stages_url = DEFAULT_STAGE_URL, mapping_path = DEFAULT_MAPPING_PATH, logger = Logger.new($stdout))
    @stages_url = stages_url
    @mapping_path = mapping_path
    @logger = logger
  end

  def call
    response = Net::HTTP.get(URI(@stages_url))
    stages_yml = YAML.safe_load(response)

    resulting_group_info = {}
    known_category_map = {}

    stages_yml['stages'].each do |stage, stage_info|
      stage_info['groups'].each do |group, group_info|
        # Group key is only used to to lookup inside information, sanitizing
        # group name prevents later headaches such as "ML/AI" group.
        # The convention for group key is <group-key>
        group_key = group.downcase.gsub(/[^a-z0-9\-_]/, '-')

        categories_in_group = group_info['categories'] || []
        categories = categories_in_group - known_category_map.keys

        if categories.size != group_info['categories'].size
          duplicates = categories_in_group & known_category_map.keys

          msg = duplicates.map do |duplicate|
            "#{duplicate} was already in #{known_category_map[duplicate]} not adding to #{group_key}"
          end.join("\n")

          @logger.warn(msg)
        end

        known_category_map.merge!(categories.map { |category| [category, group_key] }.to_h)

        resulting_group_info[group_key] = {
          name: group_info['name'],
          stage: stage,
          section: stage_info['section'],
          feature_categories: categories
        }
      end
    end

    write_group_info(resulting_group_info)
    format_group_info_file
  end

  private

  def write_group_info(resulting_group_info)
    FileUtils.mkdir_p(File.dirname(@mapping_path))
    File.open(@mapping_path, "w") do |f|
      f.write(
        <<~JSONNET
          // This file is autogenerated using scripts/update_stage_groups_feature_categories.rb
          // Please don't update manually
          #{JSON.pretty_generate(resulting_group_info, object_nl: "\n", array_nl: "\n", indent: '  ')}
        JSONNET
      )
    end
  end

  def format_group_info_file
    # The generated JSON doesn't look right in jsonnet, so running our fmt cleans it
    # up
    Kernel.system("make jsonnet-fmt JSONNET_FILES=#{@mapping_path}", exception: true)
  end
end

UpdateStageGroupsFeatureCategories.new.call if $PROGRAM_NAME == __FILE__
