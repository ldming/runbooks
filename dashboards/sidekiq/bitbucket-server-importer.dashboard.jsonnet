local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';

basic.dashboard(
  'Bitbucket Server Importer',
  tags=['sidekiq'],
)
.addPanels(
  layout.grid([
    basic.singlestat(
      title='Total Imported Projects',
      query='sum(increase(bitbucket_server_importer_imported_projects_total{env="$environment"}[$__interval]))',
      format='locale',
      valueName='total'
    ),
    basic.singlestat(
      title='Total Imported Merge (Pull) Requests',
      query='sum(increase(bitbucket_server_importer_imported_merge_requests_total{env="$environment"}[$__interval]))',
      format='locale',
      valueName='total'
    ),
    basic.singlestat(
      title='Total Imported Issues',
      query='sum(increase(bitbucket_server_importer_imported_issues_total{env="$environment"}[$__interval]))',
      format='locale',
      valueName='total'
    ),
  ], cols=3, rowHeight=5, startRow=1)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Imported Projects Per Hour',
      query='sum(rate(bitbucket_server_importer_imported_projects_total{env="$environment"}[$__interval])) * 3600',
      legendFormat='Amount',
      interval='1h'
    ),
    basic.timeseries(
      title='Imported Merge (Pull) Requests Per Hour',
      query='sum(rate(bitbucket_server_importer_imported_merge_requests_total{env="$environment"}[$__interval])) * 3600',
      legendFormat='Amount',
      interval='1h'
    ),
    basic.timeseries(
      title='Imported Issues Per Hour',
      query='sum(rate(bitbucket_server_importer_imported_issues_total{env="$environment"}[$__interval])) * 3600',
      legendFormat='Amount',
      interval='1h'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
.addPanels(
  layout.grid([
    basic.multiTimeseries(
      title='Import Duration',
      description='Import duration. Lower is better.',
      queries=[
        {
          query: |||
            histogram_quantile(0.50,
              sum(
                rate(bitbucket_server_importer_total_duration_seconds_bucket{
                  env="$environment"
                }[$__interval])
              ) by (le, environment))
          |||,
          legendFormat: 'p50',
        },
        {
          query: |||
            histogram_quantile(0.90,
              sum(
                rate(bitbucket_server_importer_total_duration_seconds_bucket{
                  env="$environment"
                }[$__interval])
              ) by (le, environment))
          |||,
          legendFormat: 'p90',
        },
        {
          query: |||
            histogram_quantile(0.95,
              sum(
                rate(bitbucket_server_importer_total_duration_seconds_bucket{
                  env="$environment"
                }[$__interval])
              ) by (le, environment))
          |||,
          legendFormat: 'p95',
        },
        {
          query: |||
            histogram_quantile(0.99,
              sum(
                rate(bitbucket_server_importer_total_duration_seconds_bucket{
                  env="$environment"
                }[$__interval])
              ) by (le, environment))
          |||,
          legendFormat: 'p99',
        },
      ],
      format='s',
      yAxisLabel='Duration',
      interval='30m',
      intervalFactor=3,
      legend_show=true,
      linewidth=1,
    ),
  ], cols=1, rowHeight=11, startRow=3)
)
