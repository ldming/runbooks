// This file is autogenerated using scripts/update_stage_groups_dashboards.rb
// Please feel free to customize this file.
local stages = import '../../services/stages.libsonnet';
local stageGroupDashboards = import './stage-group-dashboards.libsonnet';
local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';
local platformLinks = import 'platform_links.libsonnet';
local groupKey = 'package';
local featureCategories = stages.categoriesForStageGroup(groupKey);
local featureCategoriesSelector = std.join('|', featureCategories);

local packageRegex(packageType) = '.*/%(packageType)s/.*' % { packageType: packageType };

local packageRequestRate(packageType) =
  basic.timeseries(
    title='API Request Rate',
    yAxisLabel='Requests per Second',
    legendFormat='{{action}}',
    decimals=2,
    query=|||
      sum by (controller, action) (
        avg_over_time(controller_action:gitlab_transaction_duration_seconds_count:rate1m{
          environment='$environment',
          stage='$stage',
          feature_category=~'(%(featureCategories)s)',
          type='api',
          controller=~'$controller',
          action=~'%(packageType)s'
        }[$__interval])
      )
    ||| % {
      packageType: packageRegex(packageType),
      featureCategories: featureCategoriesSelector,
    }
  );

local packageP95RequestLatency(packageType) =
  basic.timeseries(
    title='API 95th Percentile Request Latency',
    decimals=2,
    format='s',
    legendFormat='{{action}}',
    query=|||
      avg(
        avg_over_time(
          controller_action:gitlab_transaction_duration_seconds:p95{
            environment="$environment",
            stage='$stage',
            action=~'%(packageType)s',
            feature_category=~'(%(featureCategories)s)',
            type='api',
            controller=~'$controller'
          }[$__interval]
        )
      ) by (action, controller)
    ||| % {
      packageType: packageRegex(packageType),
      featureCategories: featureCategoriesSelector,
    }
  );

local packageDashboard = std.foldl(
  function(dashboard, packageType)
    local packageTypeSelector = std.asciiLower(packageType.name);
    dashboard.addPanels(
      layout.rowGrid(
        packageType.name,
        [packageRequestRate(packageTypeSelector), packageP95RequestLatency(packageTypeSelector)],
        startRow=1001 + 100 * packageType.i
      )
    ),
  std.mapWithIndex(
    function(i, name) { i: i, name: name },
    [
      'Composer',
      'Conan',
      'Go',
      'Maven',
      'NPM',
      'NuGet',
      'PyPI',
      'RubyGems',
      'Debian',
      'Generic',
    ]
  ),
  stageGroupDashboards.dashboard(groupKey, ['api', 'sidekiq', 'web'])
);

packageDashboard.stageGroupDashboardTrailer() + {
  links+: [
    platformLinks.dynamicLinks('Container Registry Detail', 'type:registry'),
  ],
}
