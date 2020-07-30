local basic = import 'grafana/basic.libsonnet';
local capacityPlanning = import 'capacity_planning.libsonnet';
local colors = import 'grafana/colors.libsonnet';
local commonAnnotations = import 'grafana/common_annotations.libsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local keyMetrics = import 'key_metrics.libsonnet';
local layout = import 'grafana/layout.libsonnet';
local nodeMetrics = import 'node_metrics.libsonnet';
local platformLinks = import 'platform_links.libsonnet';
local promQuery = import 'grafana/prom_query.libsonnet';
local saturationDetail = import 'saturation_detail.libsonnet';
local seriesOverrides = import 'grafana/series_overrides.libsonnet';
local serviceCatalog = import 'service_catalog.libsonnet';
local templates = import 'grafana/templates.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local annotation = grafana.annotation;
local serviceHealth = import 'service_health.libsonnet';
local metricsCatalogDashboards = import 'metrics_catalog_dashboards.libsonnet';
local gitalyCommon = import 'gitaly/gitaly_common.libsonnet';
local selectors = import 'promql/selectors.libsonnet';
local processExporter = import 'process_exporter.libsonnet';

local selectorHash = {
  environment: '$environment',
  fqdn: { re: '$fqdn' },
};

local selector = selectors.serializeHash(selectorHash);

basic.dashboard(
  'Host Detail',
  tags=['type:gitaly'],
)
.addTemplate(templates.fqdn(query='gitlab_version_info{type="gitaly", component="gitaly", environment="$environment"}', current='file-01-stor-gprd.c.gitlab-production.internal'))
.addPanel(
  row.new(title='Node Performance'),
  gridPos={
    x: 0,
    y: 2000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    gitalyCommon.perNodeApdex(selector),
    gitalyCommon.inflightGitalyCommandsPerNode(selector),
  ], startRow=2001)
)
.addPanel(
  row.new(title='Gitaly Safety Mechanisms'),
  gridPos={
    x: 0,
    y: 3000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    gitalyCommon.gitalySpawnTimeoutsPerNode(selector),
    gitalyCommon.ratelimitLockPercentage(selector),
  ], startRow=3001)
)
.addPanel(nodeMetrics.nodeMetricsDetailRow(selector), gridPos={ x: 0, y: 6000 })
.addPanel(
  saturationDetail.saturationDetailPanels(selectorHash, components=[
    'cgroup_memory',
    'cpu',
    'disk_space',
    'disk_sustained_read_iops',
    'disk_sustained_read_throughput',
    'disk_sustained_write_iops',
    'disk_sustained_write_throughput',
    'memory',
    'open_fds',
    'single_node_cpu',
    'go_memory',
  ]),
  gridPos={ x: 0, y: 6000, w: 24, h: 1 }
)
.addPanel(
  metricsCatalogDashboards.componentDetailMatrix(
    'gitaly',
    'goserver',
    selectorHash,
    [
      { title: 'Overall', aggregationLabels: '', legendFormat: 'goserver' },
    ],
  ), gridPos={ x: 0, y: 7000 }
)
.addPanel(
  metricsCatalogDashboards.componentDetailMatrix(
    'gitaly',
    'gitalyruby',
    selectorHash,
    [
      { title: 'Overall', aggregationLabels: '', legendFormat: 'gitalyruby' },
    ],
  ), gridPos={ x: 0, y: 7100 }
)
.addPanel(
  row.new(title='git process activity'),
  gridPos={
    x: 0,
    y: 8000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  processExporter.namedGroup(
    'git processes',
    selectorHash
    {
      groupname: { re: 'git.*' },
    },
    aggregationLabels=['groupname'],
    startRow=8001
  )
)
+ {
  links+: platformLinks.triage + serviceCatalog.getServiceLinks('gitaly') + platformLinks.services +
          [platformLinks.dynamicLinks('Gitaly Detail', 'type:gitaly')],
}
