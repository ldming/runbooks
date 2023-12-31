local services = (import 'gitlab-metrics-config.libsonnet').monitoredServices;
local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;
local prometheusServiceGroupGenerator = import 'servicemetrics/prometheus-service-group-generator.libsonnet';
local aggregationSetTransformer = import 'servicemetrics/aggregation-set-transformer.libsonnet';
local recordingRules = import 'recording-rules/recording-rules.libsonnet';
local saturationResources = import 'servicemetrics/saturation-resources.libsonnet';
local saturationRules = import 'servicemetrics/saturation_rules.libsonnet';
local kubeStateMetricsRecordingRules = import 'kube-state-metrics/recording-rules.libsonnet';
local sloAlertingRulesGroup = import './slo-alerting-rules.libsonnet';
local availabilityRateRuleGroups = import './availability-rate-rules.libsonnet';

local kubeStateMetricsGroups = kubeStateMetricsRecordingRules.groupsWithFilter(function(s) true);

local serviceSLOsRulesetGenerator = recordingRules.serviceSLORuleSetGenerator();
local serviceMappingRulesetGenerator = recordingRules.serviceMappingRuleSetGenerator();

local groupsForService(service) =
  prometheusServiceGroupGenerator.recordingRuleGroupsForService(
    service,
    componentAggregationSet=aggregationSets.componentSLIs,
    nodeAggregationSet=aggregationSets.nodeComponentSLIs,
    shardAggregationSet=aggregationSets.shardComponentSLIs
  );

local serviceSLISGroups =
  // Aggregate the component-level metrics to service-level
  aggregationSetTransformer.generateRecordingRuleGroups(
    sourceAggregationSet=aggregationSets.componentSLIs,
    targetAggregationSet=aggregationSets.serviceSLIs
  )
  +
  // Generate ratio SLIs for component-level metrics
  aggregationSetTransformer.generateReflectedRecordingRuleGroups(
    aggregationSet=aggregationSets.componentSLIs,
  );

local serviceSLOsGroups =
  [{
    name: 'Autogenerated Service SLOs',
    interval: '5m',
    rules:
      std.flatMap(
        function(serviceDefinition)
          serviceSLOsRulesetGenerator.generateRecordingRulesForService(serviceDefinition),
        services
      )
      +
      std.flatMap(
        function(serviceDefinition)
          serviceMappingRulesetGenerator.generateRecordingRulesForService(serviceDefinition),
        services
      ),
  }];

local saturationGroup = saturationRules.generateSaturationRulesGroup(
  evaluation='both',
  saturationResources=saturationResources,
  thanosSelfMonitoring=false,
);

local saturationMetadataGroup = saturationRules.generateSaturationMetadataRulesGroup(
  saturationResources=saturationResources,
  evaluation='both',
);

local saturationAuxGroup = saturationRules.generateSaturationAuxRulesGroup(
  evaluation='both',
  saturationResources=saturationResources,
);

{
  'prometheus-rules/rules.yml': {
    groups:
      std.flatMap(
        function(service)
          groupsForService(service),
        services
      ) +
      serviceSLISGroups +
      serviceSLOsGroups +
      saturationGroup +
      saturationMetadataGroup +
      saturationAuxGroup +
      kubeStateMetricsGroups +
      sloAlertingRulesGroup +
      availabilityRateRuleGroups,
  },
}
