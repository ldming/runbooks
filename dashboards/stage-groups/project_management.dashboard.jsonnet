local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';

local stageGroupDashboards = import './stage-group-dashboards.libsonnet';

local banzaiRequestCount() =
  basic.multiTimeseries(
    stableId='rendering_requests_count',
    title='Rendering Requests',
    decimals=2,
    yAxisLabel='Requests per Second',
    description=|||
      Number of Banzai rendering requests per second.

      `Cacheless` requests are those that are not cached in Redis (most requests).
      `Cached` requests attempt to use the Redis cache.
    |||,
    queries=[{
      query: |||
        sum(
          rate(
            gitlab_banzai_cacheless_render_real_duration_seconds_count{
              environment="$environment",
              stage='$stage',
            }[$__interval]
          )
        )
      |||,
      legendFormat: 'Cacheless',
    }, {
      query: |||
        sum(
          rate(
            gitlab_banzai_cached_render_real_duration_seconds_count{
              environment="$environment",
              stage='$stage',
            }[$__interval]
          )
        )
      |||,
      legendFormat: 'Cached',
    }],
  );

local banzaiAvgRenderingDuration() =
  basic.timeseries(
    title='Avg Rendering Time',
    decimals=2,
    format='s',
    yAxisLabel='',
    description=|||
      Average time of Banzai pipeline rendering
    |||,
    query=|||
      sum(rate(gitlab_banzai_cacheless_render_real_duration_seconds_sum[1m]))
      /
      sum(rate(gitlab_banzai_cacheless_render_real_duration_seconds_count[1m]))
    |||,
  );

stageGroupDashboards.dashboard('project_management')
.addPanels(
  layout.rowGrid(
    'Banzai Pipelines',
    [
      banzaiRequestCount(),
      banzaiAvgRenderingDuration(),
    ],
    startRow=1001
  ),
)
.stageGroupDashboardTrailer()
