// This file is autogenerated using scripts/update_stage_groups_dashboards.rb
// Please feel free to customize this file.
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';
local template = grafana.template;
local row = grafana.row;

stageGroupDashboards.dashboard('fulfillment_platform')
.addPanels(
  layout.rowGrid('⏱️  Stack Component Uptime and Maintenance', [
    basic.statPanel(
      '',
      'Gitlab-triggered maintenance',
      query='((avg_over_time(customers_dot_maintenance_mode{environment="$environment", trigger="GitLab"}[$__range])) * $__range_s)',
      legendFormat='',
      color='green',
      noValue='0 min',
      unit='s',
    ),
    basic.statPanel(
      '',
      'Zuora-triggered maintenance',
      query='((avg_over_time(customers_dot_maintenance_mode{environment="$environment", trigger="Zuora"}[$__range])) * $__range_s)',
      legendFormat='',
      color='green',
      noValue='0 min',
      unit='s',
    ),
    basic.statPanel(
      '',
      'Manually triggered maintenance',
      query='((avg_over_time(customers_dot_maintenance_mode{environment="$environment", trigger="Manual"}[$__range])) * $__range_s)',
      legendFormat='',
      color='green',
      noValue='0 min',
      unit='s',
    ),
    basic.slaStats(
      title='CustomersDot probe result',
      query='avg_over_time(probe_success{instance="$instance", environment="$environment", job="blackbox"}[$__interval])'
    ),
    basic.slaStats(
      title='Puma uptime',
      query='1-(avg_over_time(last_scrape_error{environment="$environment", type="customersdot", job="prometheus-puma-exporter"}[$__interval]))',
    ),
  ], startRow=1, rowHeight=4)
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(probe_success{environment="$environment", type="blackbox"}, instance)',
    current='https://customers.gitlab.com/-/liveness/database,migrations,cache',
    refresh='load',
  )
)
.stageGroupDashboardTrailer()
