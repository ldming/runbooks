local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';
local template = grafana.template;
local templates = import 'grafana/templates.libsonnet';
local promQuery = import 'grafana/prom_query.libsonnet';
// local thresholds = import 'gitlab-dashboards/thresholds.libsonnet';
local row = grafana.row;


local searchRate(title, metric) =
  basic.timeseries(
    title=title,
    yAxisLabel='searches',
    stableId='gitlab-zoekt-%s' % std.asciiLower(title),
    query=|||
      rate(zoekt_search_requests_total{env="gprd"}[1m])
    ||| % { metric: metric },
  );

local diskUtilization(title, pvc) =
  basic.timeseries(
    title=title,
    yAxisLabel='% utilization',
    stableId='gitlab-zoekt-%s' % std.asciiLower(title),
    legendFormat=pvc,
    query=|||
      max without(instance,node) (
      (
      topk(1, kubelet_volume_stats_capacity_bytes{cluster="gprd-gitlab-gke", job="kubelet", namespace="gitlab", persistentvolumeclaim="%(pvc)s"})
      -
      topk(1, kubelet_volume_stats_available_bytes{cluster="gprd-gitlab-gke", job="kubelet", namespace="gitlab", persistentvolumeclaim="%(pvc)s"})
      )
      /
      topk(1, kubelet_volume_stats_capacity_bytes{cluster="gprd-gitlab-gke", job="kubelet", namespace="gitlab", persistentvolumeclaim="%(pvc)s"})
      * 100)
    ||| % { pvc: pvc },
  )
  .addTarget(
    promQuery.target('80', legendFormat='80% Alerting Threshold')
  )
  .addSeriesOverride({
    alias: '80% Alerting Threshold',
    color: 'red',
    dashes: true,
    dashLength: 2,
    spaceLength: 1,
    stack: true,
  })
;

basic.dashboard(
  'Zoekt Info',
  tags=['zoekt', 'search'],
)
.addPanels(
  layout.rowGrid(
    'Search',
    [
      searchRate('Search Rate 1m', 'zoekt_search_requests_total'),
    ],
    startRow=10,
  ),
)
.addPanels(
  layout.rowGrid(
    'Indexing',
    [
      diskUtilization('Persistent Volumes', 'zoekt-index-gitlab-gitlab-zoekt-0'),

    ],
    startRow=20,
  )
)
