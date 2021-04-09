local basic = import 'grafana/basic.libsonnet';
local keyMetrics = import 'key_metrics.libsonnet';
local patroniService = (import 'metrics-catalog.libsonnet').getService('patroni');

local patroniOverview(startRow, rowHeight) =
  keyMetrics.headlineMetricsRow(
    patroniService.type,
    selectorHash={
      type: patroniService.type,
      tier: patroniService.tier,
      environment: '$environment',
      stage: '$stage',
    },
    showApdex=true,
    showErrorRatio=true,
    showOpsRate=true,
    showSaturationCell=true,
    showDashboardListPanel=false,
    compact=true,
    rowTitle=null,
    startRow=startRow,
    rowHeight=rowHeight,
  );

local totalDeadTuples =
  basic.timeseries(
    'Total dead tuples',
    format='short',
    legendFormat='{{relname}}',
    query=|||
      pg_stat_user_tables_n_dead_tup{env="$environment",fqdn="$db_instance",datname="$db_database",relname=~"$db_top_dead_tup"}
    |||,
  );

local deadTuplesPercentage =
  basic.timeseries(
    'Dead tuples percentage',
    format='percentunit',
    legendFormat='{{relname}}',
    query=|||
      pg_stat_user_tables_n_dead_tup{env="$environment",fqdn="$db_instance",datname="$db_database",relname=~"$db_top_dead_tup"}
      /
      (
        pg_stat_user_tables_n_live_tup{env="$environment",fqdn="$db_instance",datname="$db_database",relname=~"$db_top_dead_tup"}
        +
        pg_stat_user_tables_n_dead_tup{env="$environment",fqdn="$db_instance",datname="$db_database",relname=~"$db_top_dead_tup"}
      )
    |||,
  );

local slowQueries =
  basic.timeseries(
    'Slow queries',
    format='opm',
    legendFormat='{{fqdn}}',
    query=|||
      rate(pg_slow_queries{environment="$environment",fqdn=~"$db_instances"}[$__interval]) * 60
    |||,
  );

{
  patroniOverview:: patroniOverview,
  totalDeadTuples:: totalDeadTuples,
  deadTuplesPercentage:: deadTuplesPercentage,
  slowQueries:: slowQueries,
}
