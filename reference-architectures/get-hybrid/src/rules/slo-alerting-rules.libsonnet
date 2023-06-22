local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;
local metricsCatalog = import 'servicemetrics/metrics-catalog.libsonnet';
local serviceAlertsGenerator = import 'slo-alerts/service-alerts-generator.libsonnet';

// Minimum operation rate thresholds:
// This is to avoid low-volume, noisy alerts.
// See docs/metrics-catalog/service-level-monitoring.md for more details
// of how minimumSamplesForMonitoring works
local minimumSamplesForMonitoring = 3600;
local minimumSamplesForTrafficCessation = 300;

local alertDescriptors = [{
  predicate: function(service, sli) true,
  alertSuffix: '',
  alertTitleTemplate: 'The %(sliName)s SLI of the %(serviceType)s service',
  alertExtraDetail: null,
  aggregationSet: aggregationSets.componentSLIs,
  minimumSamplesForMonitoring: minimumSamplesForMonitoring,
  alertForDuration: null,  // Use default for window...
  trafficCessationSelector: {},
  minimumSamplesForTrafficCessation: minimumSamplesForTrafficCessation,
}];

std.flatMap(
  function(service)
    serviceAlertsGenerator(service, alertDescriptors),
  metricsCatalog.services,
)
