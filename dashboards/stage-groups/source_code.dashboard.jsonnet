// This file is autogenerated using scripts/update_stage_groups_dashboards.rb
// Please feel free to customize this file.
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';

stageGroupDashboards
.dashboard('source_code', components=['web', 'api', 'git', 'sidekiq'])
.stageGroupDashboardTrailer()
