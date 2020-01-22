local basic = import 'basic.libsonnet';
local capacityPlanning = import 'capacity_planning.libsonnet';
local colors = import 'colors.libsonnet';
local commonAnnotations = import 'common_annotations.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local keyMetrics = import 'key_metrics.libsonnet';
local layout = import 'layout.libsonnet';
local nodeMetrics = import 'node_metrics.libsonnet';
local platformLinks = import 'platform_links.libsonnet';
local promQuery = import 'prom_query.libsonnet';
local seriesOverrides = import 'series_overrides.libsonnet';
local serviceCatalog = import 'service_catalog.libsonnet';
local templates = import 'templates.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local annotation = grafana.annotation;
local serviceHealth = import 'service_health.libsonnet';
local saturationDetail = import 'saturation_detail.libsonnet';
local metricsCatalogDashboards = import 'metrics_catalog_dashboards.libsonnet';

local selector = 'environment="$environment", type="nfs", stage="$stage"';

basic.dashboard(
  'Overview',
  tags=['overview'],
)
.addTemplate(templates.stage)
.addPanels(keyMetrics.headlineMetricsRow('nfs', '$stage', startRow=0))
.addPanel(serviceHealth.row('nfs', '$stage'), gridPos={ x: 0, y: 500 })
.addPanel(keyMetrics.keyServiceMetricsRow('nfs', '$stage'), gridPos={ x: 0, y: 4000 })
.addPanel(nodeMetrics.nodeMetricsDetailRow(selector), gridPos={ x: 0, y: 6000 })
.addPanel(metricsCatalogDashboards.componentDetailMatrix('nfs', 'nfs_service', selector, [
  { title: 'Overall', aggregationLabels: '', legendFormat: 'server' },
  { title: 'per Node', aggregationLabels: 'fqdn', legendFormat: '{{ fqdn }}' },
]), gridPos={ x: 0, y: 7000 })
.addPanel(saturationDetail.saturationDetailPanels(selector, components=[
            'cpu',
            'disk_space',
            'disk_sustained_read_iops',
            'disk_sustained_read_throughput',
            'disk_sustained_write_iops',
            'disk_sustained_write_throughput',
            'memory',
            'open_fds',
          ]),
          gridPos={ x: 0, y: 7000, w: 24, h: 1 })
.addPanel(capacityPlanning.capacityPlanningRow('nfs', '$stage'), gridPos={ x: 0, y: 8000 })
+ {
  links+: platformLinks.triage + serviceCatalog.getServiceLinks('nfs') + platformLinks.services,
}
