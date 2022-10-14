local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';

// This file is autogenerated using scripts/update_stage_groups_dashboards.rb
// Please feel free to customize this file.
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';

local sastArtifactBuildsCompleted() =
  basic.timeseries(
    stableId='sast_artifact_builds_completed',
    title='SAST Artifact Builds Completed',
    decimals=2,
    yAxisLabel='Count',
    description=|||
      Number of CI Builds completed with SAST report artifacts
    |||,
    query=|||
      sum by (status) (
        increase(
          artifact_report_codequality_builds_completed_total{
            env="$environment"
          }[$__interval])
      )
    |||,
  );

stageGroupDashboards
.dashboard('static_analysis')
.addPanels(
  layout.rowGrid(
    'SAST Artifact Builds Completed',
    [
      sastArtifactBuildsCompleted(),
    ],
    startRow=1001,
  )
)
.stageGroupDashboardTrailer()
