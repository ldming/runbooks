local selectors = import 'promql/selectors.libsonnet';
local metricsCatalog = import 'servicemetrics/metrics-catalog.libsonnet';
local misc = import 'utils/misc.libsonnet';

local getSelectorHash(
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
      ) =
  if includeDangerouslyThanosEvaluated && !includePrometheusEvaluated then
    { monitor: 'global' }
  else
    {};

// Returns true if at least one of the services in the list has
// dangerouslyThanosEvaluated true
local appliesToAnyThanosEvaluatedService(serviceTypes) =
  misc.any(
    function(serviceType)
      local s = metricsCatalog.getServiceOptional(serviceType);
      s != null && s.dangerouslyThanosEvaluated,
    serviceTypes
  );

local filterSaturationDefinitions(
  saturationResources,
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
  thanosSelfMonitoring
      ) =
  local saturationResourceNames = std.objectFields(saturationResources);
  std.filter(
    function(key)
      local definition = saturationResources[key];
      // Not all saturation metrics will match all architectures, filter our non-matches
      (std.length(definition.appliesTo) > 0)
      &&
      (
        (thanosSelfMonitoring && appliesToAnyThanosEvaluatedService(definition.appliesTo))
        ||
        (includePrometheusEvaluated && !definition.dangerouslyThanosEvaluated)
        ||
        (includeDangerouslyThanosEvaluated && definition.dangerouslyThanosEvaluated)
      ),
    saturationResourceNames
  );

local prepareGroups(
  groups,
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
      ) =
  // When generating thanos-only rules, we need to add partial_response_strategy
  local groupBase =
    if !includePrometheusEvaluated && includeDangerouslyThanosEvaluated then
      { partial_response_strategy: 'warn' }
    else
      {};

  std.foldl(
    function(memo, group)
      local rules = std.prune(group.rules);
      if std.length(rules) == 0 then
        // Skip this group
        memo
      else
        memo + [groupBase + group {
          rules: rules,
        }],
    groups,
    []
  );

local generateSaturationAuxRulesGroup(
  saturationResources,
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
  extraSelector={},
  thanosSelfMonitoring=false,  // Include Thanos self-monitor saturation rules in the alert groups
      ) =
  local selectorHash = getSelectorHash(includePrometheusEvaluated, includeDangerouslyThanosEvaluated) + extraSelector;
  local selector = selectors.serializeHash(selectorHash);

  local filtered = filterSaturationDefinitions(saturationResources, includePrometheusEvaluated, includeDangerouslyThanosEvaluated, thanosSelfMonitoring);

  local saturationAlerts = std.flatMap(function(key) saturationResources[key].getSaturationAlerts(key, selectorHash), filtered);
  local recordedQuantiles = [0.95, 0.99];

  prepareGroups([{
    // Alerts for saturation metrics being out of threshold
    name: 'GitLab Component Saturation Statistics',
    interval: '5m',
    rules:
      [
        {
          record: 'gitlab_component_saturation:ratio_quantile%(quantile_percent)d_1w' % {
            quantile_percent: quantile * 100,
          },
          expr: 'quantile_over_time(%(quantile)g, gitlab_component_saturation:ratio{%(selector)s}[1w])' % {
            selector: selector,
            quantile: quantile,
          },
        }
        for quantile in recordedQuantiles
      ]
      +
      [
        {
          record: 'gitlab_component_saturation:ratio_quantile%(quantile_percent)d_1h' % {
            quantile_percent: quantile * 100,
          },
          expr: 'quantile_over_time(%(quantile)g, gitlab_component_saturation:ratio{%(selector)s}[1h])' % {
            selector: selector,
            quantile: quantile,
          },
        }
        for quantile in recordedQuantiles
      ]
      +
      [
        {
          record: 'gitlab_component_saturation:ratio_avg_1h',
          expr: 'avg_over_time(gitlab_component_saturation:ratio{%(selector)s}[1h])' % {
            selector: selector,
          },
        },
      ],
  }, {
    name: 'GitLab Saturation Alerts',
    interval: '1m',
    rules: saturationAlerts,
  }], includePrometheusEvaluated, includeDangerouslyThanosEvaluated);

local generateSaturationMetadataRulesGroup(
  saturationResources,
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
  thanosSelfMonitoring=false,
      ) =
  local filtered = filterSaturationDefinitions(saturationResources, includePrometheusEvaluated, includeDangerouslyThanosEvaluated, thanosSelfMonitoring);
  local sloThresholdRecordingRules = std.flatMap(function(key) saturationResources[key].getSLORecordingRuleDefinition(key), filtered);
  local saturationMetadataRecordingRules = std.map(function(key) saturationResources[key].getMetadataRecordingRuleDefinition(key), filtered);

  prepareGroups([{
    // Recording rules defining the soft and hard SLO thresholds
    name: 'GitLab Component Saturation Max SLOs',
    interval: '5m',
    rules: sloThresholdRecordingRules,
  }, {
    // Metadata each of the saturation metrics
    name: 'GitLab Component Saturation Metadata',
    interval: '5m',
    rules: saturationMetadataRecordingRules,
  }], includePrometheusEvaluated, includeDangerouslyThanosEvaluated);

local generateSaturationRulesGroup(
  includePrometheusEvaluated,
  includeDangerouslyThanosEvaluated,
  saturationResources,
  extraSourceSelector={},
  thanosSelfMonitoring=false,
  staticLabels={},
      ) =
  local selectorHash = getSelectorHash(includePrometheusEvaluated, includeDangerouslyThanosEvaluated);

  local saturationResourceNames = std.objectFields(saturationResources);
  local filtered = filterSaturationDefinitions(saturationResources, includePrometheusEvaluated, includeDangerouslyThanosEvaluated, thanosSelfMonitoring);

  local resourceAutoscalingRuleFiltered = std.filter(
    function(key) std.get(saturationResources[key], 'resourceAutoscalingRule', false),
    filtered
  );

  local rules = std.map(
    function(key)
      saturationResources[key].getRecordingRuleDefinition(
        key,
        thanosSelfMonitoring=thanosSelfMonitoring,
        staticLabels=staticLabels,
        extraSelector=extraSourceSelector,
      ),
    filtered
  );

  local resourceAutoscalingRules = std.map(
    function(key)
      saturationResources[key].getResourceAutoscalingRecordingRuleDefinition(
        key,
        thanosSelfMonitoring=thanosSelfMonitoring,
        staticLabels=staticLabels,
        extraSelector=extraSourceSelector
      ),
    resourceAutoscalingRuleFiltered
  );

  local namePrefix = if thanosSelfMonitoring then 'Thanos Self-Monitoring ' else '';

  prepareGroups([{
    // Recording rules for each saturation metric
    name: namePrefix + 'Saturation Rules (autogenerated)',
    interval: '1m',
    rules: rules,
  }, {
    // Recording rules for each resource saturation metric for autoscaling
    name: namePrefix + 'Resource Saturation Rules (autogenerated)',
    interval: '1m',
    rules: resourceAutoscalingRules,
  }], includePrometheusEvaluated, includeDangerouslyThanosEvaluated);

{
  generateSaturationRulesGroup:: generateSaturationRulesGroup,
  generateSaturationAuxRulesGroup:: generateSaturationAuxRulesGroup,
  generateSaturationMetadataRulesGroup:: generateSaturationMetadataRulesGroup,
}
