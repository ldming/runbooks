local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;
local metricsCatalog = import 'servicemetrics/metrics-catalog.libsonnet';
local serviceAlertsGenerator = import 'slo-alerts/service-alerts-generator.libsonnet';
local separateGlobalRecordingFiles = (import './lib/separate-global-recording-files.libsonnet').separateGlobalRecordingFiles;

// Minimum operation rate thresholds:
// This is to avoid low-volume, noisy alerts.
// See docs/metrics-catalog/service-level-monitoring.md for more details
// of how minimumSamplesForMonitoring works
local minimumSamplesForMonitoring = 3600;
local minimumSamplesForNodeMonitoring = 1200;

// 300 requests in 30m required an hour ago before we trigger cessation alerts
// This is about 10 requests per minute, which is not that busy
// The difference between 0.1666 RPS and 0 PRS can occur on calmer periods
local minimumSamplesForTrafficCessation = 300;

// Most MWMBR alerts use a 2m period
// Initially for this alert, use a long period to ensure that
// it's not too noisy.
// Consider bringing this down to 2m after 1 Sep 2020
local nodeAlertWaitPeriod = '10m';

local alertDescriptors = [{
  predicate: function(service, sli) !sli.shardLevelMonitoring,
  alertSuffix: '',
  alertTitleTemplate: 'The %(sliName)s SLI of the %(serviceType)s service (`{{ $labels.stage }}` stage)',
  alertExtraDetail: null,
  aggregationSet: aggregationSets.componentSLIs,
  minimumSamplesForMonitoring: minimumSamplesForMonitoring,
  alertForDuration: null,  // Use default for window...
  trafficCessationSelector: { stage: 'main' },  // Don't alert on cny stage traffic cessation for now
  minimumSamplesForTrafficCessation: minimumSamplesForTrafficCessation,
}, {
  predicate: function(service, sli) service.nodeLevelMonitoring,
  alertSuffix: 'SingleNode',
  alertTitleTemplate: 'The %(sliName)s SLI of the %(serviceType)s service on node `{{ $labels.fqdn }}`',
  alertExtraDetail: 'Since the `{{ $labels.type }}` service is not fully redundant, SLI violations on a single node may represent a user-impacting service degradation.',
  aggregationSet: aggregationSets.nodeComponentSLIs,
  minimumSamplesForMonitoring: minimumSamplesForNodeMonitoring,  // Note: lower minimum sample rate for node-level monitoring
  alertForDuration: nodeAlertWaitPeriod,
  trafficCessationSelector: {},
  minimumSamplesForTrafficCessation: minimumSamplesForTrafficCessation,
}, {
  predicate: function(service, sli) service.regional,
  alertSuffix: 'Regional',
  alertTitleTemplate: 'The %(sliName)s SLI of the %(serviceType)s service in region `{{ $labels.region }}`',
  alertExtraDetail: 'Note that this alert is specific to the `{{ $labels.region }}` region.',
  aggregationSet: aggregationSets.regionalComponentSLIs,
  minimumSamplesForMonitoring: minimumSamplesForMonitoring,
  alertForDuration: null,  // Use default for window...
  trafficCessationSelector: { stage: 'main' },  // Don't alert on cny stage traffic cessation for now
  minimumSamplesForTrafficCessation: minimumSamplesForTrafficCessation,
}, {
  predicate: function(service, sli) sli.shardLevelMonitoring,
  alertSuffix: 'SingleShard',
  alertTitleTemplate: 'The %(sliName)s SLI of the %(serviceType)s service on shard `{{ $labels.shard }}`',
  alertExtraDetail: 'Since the `{{ $labels.type }}` service is not fully redundant, SLI violations on a single shard may represent a user-impacting service degradation.',
  aggregationSet: aggregationSets.shardComponentSLIs,
  minimumSamplesForMonitoring: minimumSamplesForMonitoring,
  alertForDuration: nodeAlertWaitPeriod,
  trafficCessationSelector: {},
  minimumSamplesForTrafficCessation: minimumSamplesForTrafficCessation,
}];

local groupsForService(service, selector) = {
  groups: serviceAlertsGenerator(service, alertDescriptors, groupExtras={ partial_response_strategy: 'warn' }, extraSelector=selector),
};

separateGlobalRecordingFiles(
  function(selector)
    std.foldl(
      function(docs, service)
        docs {
          ['service-level-alerts-%s' % [service.type]]: std.manifestYamlDoc(groupsForService(service, selector)),
        },
      metricsCatalog.services,
      {},
    )
)
