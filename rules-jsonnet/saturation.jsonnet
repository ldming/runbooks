local saturationResources = import './saturation-resources.libsonnet';

local saturationResourceNames = std.objectFields(saturationResources);

local rules = std.map(function(key) saturationResources[key].getRecordingRuleDefinition(key), saturationResourceNames);
local sloThresholdRecordingRules = std.flatMap(function(key) saturationResources[key].getSLORecordingRuleDefinition(key), saturationResourceNames);
local saturationMetadataRecordingRules = std.map(function(key) saturationResources[key].getMetadataRecordingRuleDefinition(key), saturationResourceNames);
local saturationAlerts = std.flatMap(function(key) saturationResources[key].getSaturationAlerts(key), saturationResourceNames);

{
  'saturation.yml':
    std.manifestYamlDoc({
      groups: [{
        // Recording rules for each saturation metric
        name: 'Saturation Rules (autogenerated)',
        interval: '1m',
        rules: rules,
      }, {
        // Recording rules defining the soft and hard SLO thresholds
        name: 'GitLab Component Saturation Max SLOs',
        interval: '5m',
        rules: sloThresholdRecordingRules,
      }, {
        // Metadata each of the saturation metrics
        name: 'GitLab Component Saturation Metadata',
        interval: '5m',
        rules: saturationMetadataRecordingRules,
      }, {
        // Alerts for saturation metrics being out of threshold
        name: 'GitLab Component Saturation 1w Quantiles',
        interval: '5m',
        rules: [{
          record: 'gitlab_component_saturation:ratio_quantile%(quantile_percent)d_1w'% {
            quantile_percent: quantile * 100
          },
          expr: 'quantile_over_time(%(quantile)g, gitlab_component_saturation:ratio[1w])' % {
            quantile: quantile,
          },
        } for quantile in [0.95, 0.99]],
      }, {
        name: 'GitLab Saturation Alerts',
        interval: '1m',
        rules: saturationAlerts,
      }],
    }),
}
