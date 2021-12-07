local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local crCommon = import 'gitlab-dashboards/container_registry_graphs.libsonnet';
local template = grafana.template;
local templates = import 'grafana/templates.libsonnet';
local row = grafana.row;
local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';
local graphPanel = grafana.graphPanel;
local promQuery = import 'grafana/prom_query.libsonnet';

basic.dashboard(
  'Database Detail',
  tags=['container registry', 'docker', 'registry'],
)
.addTemplate(templates.gkeCluster)
.addTemplate(templates.stage)
.addTemplate(templates.namespaceGitlab)
.addTemplate(
  template.custom(
    'Deployment',
    'gitlab-registry,',
    'gitlab-registry',
    hide='variable',
  )
)
.addTemplate(template.new(
  'cluster',
  '$PROMETHEUS_DS',
  'label_values(go_sql_dbstats_connections_in_use{app="registry", environment="$environment"}, cluster)',
  current=null,
  refresh='load',
  sort=true,
  multi=true,
  includeAll=true,
  allValues='.*',
))
.addTemplate(template.new(
  'shard',
  '$PROMETHEUS_DS',
  'label_values(gitlab_database_bloat_btree_bloat_size{type="patroni-registry", environment="$environment"}, shard)',
  current='default',
  refresh='load',
  sort=true,
  multi=true,
  includeAll=true,
  allValues='.*',
))
.addPanel(
  row.new(title='Connection Pool (Aggregate)'),
  gridPos={
    x: 0,
    y: 0,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    basic.queueLengthTimeseries(
      title='Open',
      description='The total number of established connections both in use and idle.',
      yAxisLabel='Connections',
      query='sum(max_over_time(go_sql_dbstats_connections_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=5,
    ),
    basic.queueLengthTimeseries(
      title='In Use',
      description='The total number of connections currently in use.',
      yAxisLabel='Connections',
      query='sum(max_over_time(go_sql_dbstats_connections_in_use{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=5,
    ),
    basic.queueLengthTimeseries(
      title='Idle',
      description='The total aggregated number of idle connections.',
      yAxisLabel='Connections',
      query='sum(max_over_time(go_sql_dbstats_connections_idle{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=5,
    ),
    basic.saturationTimeseries(
      title='Saturation',
      description='Saturation. Lower is better.',
      yAxisLabel='Utilization',
      query=|||
        sum (go_sql_dbstats_connections_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"})
        /
        sum (go_sql_dbstats_connections_max_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"})
      |||,
      interval='30s',
      intervalFactor=3,
    ),
    basic.latencyTimeseries(
      title='Wait Time',
      description='The total aggregated time blocked waiting for a new connection. Lower is better.',
      query='sum(rate(go_sql_dbstats_connections_wait_seconds_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      format='s',
      yAxisLabel='Latency',
      interval='1m',
      intervalFactor=1,
    ),
    basic.timeseries(
      title='Waits',
      description='The total number of connections waited for.',
      yAxisLabel='Connections',
      query='sum(rate(go_sql_dbstats_connections_waits_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=2,
    ),
    basic.timeseries(
      title='Closed (Max Idle Count)',
      description='The total number of connections closed due to the maximum idle count limit.',
      yAxisLabel='Connections',
      query='sum(rate(go_sql_dbstats_connections_max_idle_closed_count_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=2,
    ),
    basic.timeseries(
      title='Closed (Max Idle Time)',
      description='The total number of connections closed due to the maximum idle time limit.',
      yAxisLabel='Connections',
      query='sum(rate(go_sql_dbstats_connections_max_idle_time_closed_count_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=2,
    ),
    basic.timeseries(
      title='Closed (Max Lifetime)',
      description='The total number of connections closed due to the maximum lifetime limit.',
      yAxisLabel='Connections',
      query='sum(rate(go_sql_dbstats_connections_max_lifetime_closed_count_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval]))',
      intervalFactor=2,
    ),
  ], cols=3, rowHeight=10, startRow=1),
)

.addPanel(
  row.new(title='Connection Pool (Per Pod)'),
  gridPos={
    x: 0,
    y: 1000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Open',
      description='The number of established connections both in use and idle per pod.',
      query='sum(go_sql_dbstats_connections_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}) by (pod)',
      legendFormat='{{ pod }}',
      interval='1m',
      intervalFactor=2,
      yAxisLabel='Connections',
      linewidth=1
    ),
    basic.timeseries(
      title='In Use',
      description='The number of connections currently in use per pod.',
      query='sum(go_sql_dbstats_connections_in_use{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}) by (pod)',
      legendFormat='{{ pod }}',
      interval='1m',
      intervalFactor=2,
      yAxisLabel='Connections',
      linewidth=1
    ),
    basic.timeseries(
      title='Idle',
      description='The number of idle connections per pod.',
      query='sum(go_sql_dbstats_connections_idle{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}) by (pod)',
      legendFormat='{{ pod }}',
      interval='1m',
      intervalFactor=2,
      yAxisLabel='Connections',
      linewidth=1
    ),
    basic.saturationTimeseries(
      title='Saturation',
      description='Saturation per pod. Lower is better.',
      yAxisLabel='Utilization',
      query=|||
        sum by (pod) (go_sql_dbstats_connections_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"})
        /
        sum by (pod) (go_sql_dbstats_connections_max_open{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"})
      |||,
      legendFormat='{{ pod }}',
      interval='30s',
      intervalFactor=3,
    ),
    basic.latencyTimeseries(
      title='Wait Time',
      description='The aggregated time blocked waiting for a new connection per pod. Lower is better.',
      query='sum(rate(go_sql_dbstats_connections_wait_seconds_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval])) by (pod)',
      legendFormat='{{ pod }}',
      format='s',
      yAxisLabel='Latency',
      interval='1m',
      intervalFactor=1,
    ),
    basic.timeseries(
      title='Waits',
      description='The number of connections waited for per pod.',
      query='sum(max_over_time(go_sql_dbstats_connections_waits_total{app="registry", environment="$environment", cluster=~"$cluster", stage="$stage"}[$__interval])) by (pod)',
      legendFormat='{{ pod }}',
      interval='1m',
      intervalFactor=2,
      yAxisLabel='Connections',
    ),
  ], cols=3, rowHeight=10, startRow=1001),
)

.addPanel(
  row.new(title='Table Bloat'),
  gridPos={
    x: 0,
    y: 2000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    basic.saturationTimeseries(
      title='Saturation (Aggregate)',
      description='The aggregate table bloat saturation.',
      query=|||
        max_over_time(
          gitlab_component_saturation:ratio{type="patroni-registry", environment="$environment", component="pg_table_bloat"}[$__interval]
        )
      |||,
      legend_show=false
    ),
    graphPanel.new(
      'Saturation (Per Table)',
      description='The table bloat saturation. Limited to the top 20 entries.',
      format='percent',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_table_bloat_ratio{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
    graphPanel.new(
      'Bloat Size',
      description='The table bloat size. Limited to the top 20 entries.',
      format='bytes',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_table_bloat_size{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
    graphPanel.new(
      'Real Size',
      description='The table real size. Limited to the top 20 entries.',
      format='bytes',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_table_real_size{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
  ], cols=4, rowHeight=13, startRow=2001),
)

.addPanel(
  row.new(title='B-tree Bloat'),
  gridPos={
    x: 0,
    y: 3000,
    w: 24,
    h: 1,
  }
)
.addPanels(
  layout.grid([
    basic.saturationTimeseries(
      title='Saturation (Aggregate)',
      description='The aggregate B-tree bloat saturation.',
      query=|||
        max_over_time(
          gitlab_component_saturation:ratio{type="patroni-registry", environment="$environment", component="pg_btree_bloat"}[$__interval]
        )
      |||,
      legend_show=false
    ),
    graphPanel.new(
      'Saturation (Per Index)',
      description='The B-tree bloat saturation per index. Limited to the top 20 entries.',
      format='percent',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_btree_bloat_ratio{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
    graphPanel.new(
      'Bloat Size',
      description='The B-tree bloat size per index. Limited to the top 20 entries.',
      format='bytes',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_btree_bloat_size{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
    graphPanel.new(
      'Real Size',
      description='The B-tree real size per index. Limited to the top 20 entries.',
      format='bytes',
      linewidth=1,
      nullPointMode='connected',
      fill=0,
      legend_alignAsTable=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_sort='current',
      legend_sortDesc=true,
    )
    .addTarget(
      promQuery.target(
        |||
          topk (
            20,
            max by (query_name) (gitlab_database_bloat_btree_real_size{type="patroni-registry", environment="$environment", shard=~"$shard", query_name!~"pg_.*"})
          )
        |||,
        legendFormat='{{ query_name }}',
      )
    ),
  ], cols=4, rowHeight=13, startRow=3001),
)

.addPanel(
  row.new(title='CloudSQL (pre only)', collapse=true)
  .addPanels(
    layout.grid([
      basic.timeseries(
        title='CPU Utilization',
        description=|||
          CPU utilization.

          See https://cloud.google.com/monitoring/api/metrics_gcp#gcp-cloudsql for
          more details.
        |||,
        query='stackdriver_cloudsql_database_cloudsql_googleapis_com_database_cpu_utilization{database_id=~".+:registry-db.+", environment="$environment"}',
        legendFormat='{{ database_id }}',
        format='percent'
      ),
      basic.timeseries(
        title='Memory Utilization',
        description=|||
          Memory utilization.

          See https://cloud.google.com/monitoring/api/metrics_gcp#gcp-cloudsql for
          more details.
        |||,
        query='stackdriver_cloudsql_database_cloudsql_googleapis_com_database_memory_utilization{database_id=~".+:registry-db.+", environment="$environment"}',
        legendFormat='{{ database_id }}',
        format='percent'
      ),
      basic.timeseries(
        title='Disk Utilization',
        description=|||
          Data utilization in bytes.

          See https://cloud.google.com/monitoring/api/metrics_gcp#gcp-cloudsql for
          more details.
        |||,
        query='stackdriver_cloudsql_database_cloudsql_googleapis_com_database_disk_bytes_used{database_id=~".+:registry-db.+", environment="$environment"}',
        legendFormat='{{ database_id }}',
        format='bytes'
      ),
      basic.timeseries(
        title='Transactions',
        description=|||
          Delta count of number of transactions. Sampled every 60 seconds.

          See https://cloud.google.com/monitoring/api/metrics_gcp#gcp-cloudsql for
          more details.
        |||,
        query=|||
          sum by (database_id) (
            avg_over_time(stackdriver_cloudsql_database_cloudsql_googleapis_com_database_postgresql_transaction_count{database_id=~".+:registry-db.+", environment="$environment"}[$__interval])
          )
        |||,
        legendFormat='{{ database_id }}',
      ),
    ], cols=3, rowHeight=10, startRow=4001)
  ),
  gridPos={
    x: 0,
    y: 4000,
    w: 24,
    h: 1,
  },
)
