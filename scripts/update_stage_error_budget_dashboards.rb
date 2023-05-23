#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/sync_dashboards'

##
# Generate Grafana dashboard error budget dashboards for each stage.
# Prerequisite: latest services/stage-group-mapping.jsonnet file generated from
# scripts/update_stage_groups_feature_categories.rb
class UpdateStageErrorBudgetDashboards
  include SyncDashboards

  DASHBOARDS_FOLDER = "product"
  DEFAULT_DASHBOARDS_DIR = File.expand_path(File.join(File.dirname(__FILE__), "../dashboards/#{DASHBOARDS_FOLDER}/"))
  DEFAULT_MAPPING_PATH = File.expand_path(File.join(File.dirname(__FILE__), '../services/stage-group-mapping.jsonnet'))

  def self.render_template(stage)
    raise 'Stage key is empty' if stage.nil? || stage.empty?

    <<~JSONNET
      // This file is autogenerated using scripts/update_stage_error_budget_dashboards.rb
      // Please feel free to customize this file.
      local errorBudgetsDashboards = import './error_budget_dashboards.libsonnet';

      errorBudgetsDashboards
      .dashboard('#{stage}')
      .trailer()
    JSONNET
  end

  attr_reader :dashboards_dir, :mapping_path, :output

  def initialize(dashboards_dir: DEFAULT_DASHBOARDS_DIR, mapping_path: DEFAULT_MAPPING_PATH, output: $stdout)
    @dashboards_dir = dashboards_dir
    @mapping_path = mapping_path
    @output = output
  end

  def call
    group_info = parse_jsonnet(@mapping_path)
    raise "#{@mapping_path} is invalid" unless group_info.is_a?(Hash)

    dashboards = group_info.map { |_k, v| v['stage'] }.compact.uniq.map(&:strip)
    sync_dashboards(@dashboards_dir, dashboards)
  end

  private

  def dashboard_extension
    '_error_budget.dashboard.jsonnet'
  end

  def dashboard_file(group)
    File.join(@dashboards_dir, "/#{group}#{dashboard_extension}")
  end

  def render_template(group)
    self.class.render_template(group)
  end
end

UpdateStageErrorBudgetDashboards.new.call if $PROGRAM_NAME == __FILE__
