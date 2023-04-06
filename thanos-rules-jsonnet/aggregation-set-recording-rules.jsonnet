local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;
local aggregationSetTransformer = import 'servicemetrics/aggregation-set-transformer.libsonnet';
local applicationSlis = (import 'gitlab-slis/library.libsonnet').all;
local applicationSliAggregations = import 'gitlab-slis/aggregation-sets.libsonnet';
local separateGlobalRecordingFiles = (import './lib/separate-global-recording-files.libsonnet').separateGlobalRecordingFiles;

local defaultsForRecordingRuleGroup = { partial_response_strategy: 'warn' };

local outputPromYaml(groups) =
  std.manifestYamlDoc({
    groups: groups,
  });

local transformRuleGroups(sourceAggregationSet, targetAggregationSet, extraSourceSelector, extrasForGroup=defaultsForRecordingRuleGroup) =
  aggregationSetTransformer.generateRecordingRuleGroups(
    sourceAggregationSet=sourceAggregationSet { selector+: extraSourceSelector },
    targetAggregationSet=targetAggregationSet,
    extrasForGroup=extrasForGroup,
  );

local groupsForApplicationSli(sli, extraSelector) =
  local targetAggregationSet = applicationSliAggregations.targetAggregationSet(sli);
  local sourceAggregationSet = applicationSliAggregations.sourceAggregationSet(sli);
  transformRuleGroups(sourceAggregationSet, targetAggregationSet, extraSelector);

/**
 * This file defines all the aggregation recording rules that will aggregate in Thanos to a single global view
 */
local filesForSeparateSelector(selector) = {
  /**
   * Aggregates from multiple "split-brain" prometheus SLIs to a global/single-view SLI metrics
   */
  'aggregated-component-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceSLIs,
        targetAggregationSet=aggregationSets.componentSLIs,
        extraSourceSelector=selector,
      )
    ),

  /**
   * Aggregates from multiple "split-brain" prometheus SLIs to a global/single-view service-level aggregated metrics
   */
  'aggregated-service-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceSLIs,
        targetAggregationSet=aggregationSets.serviceSLIs,
        extraSourceSelector=selector,
      )
    ),

  /**
   * Aggregates from multiple "split-brain" prometheus per-node SLIs to a global/single-view SLI-node-level aggregated metrics
   */
  'aggregated-sli-node-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceNodeComponentSLIs,
        targetAggregationSet=aggregationSets.nodeComponentSLIs,
        extraSourceSelector=selector,
      ),
    ),

  /**
   * Aggregates from multiple "split-brain" prometheus per-shard SLIs to a global/single-view SLI-shard-level aggregated metrics
   */
  'aggregated-sli-shard-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceShardComponentSLIs,
        targetAggregationSet=aggregationSets.shardComponentSLIs,
        extraSourceSelector=selector,
      ),
    ),

  /**
   * Aggregates from multiple "split-brain" prometheus SLIs to a global/single-view service-node-level aggregated metrics
   * TODO: consider whether this aggregation is neccessary and useful.
   */
  'aggregated-service-node-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceNodeComponentSLIs,
        targetAggregationSet=aggregationSets.nodeServiceSLIs,
        extraSourceSelector=selector,
      ),
    ),

  /**
   * Regional SLIS
   */
  'aggregated-sli-regional-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceSLIs,
        targetAggregationSet=aggregationSets.regionalComponentSLIs,
        extraSourceSelector=selector,
      ),
    ),

  /**
   * Regional SLIs, aggregated to the service level
   */
  'aggregated-service-regional-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.promSourceSLIs,
        targetAggregationSet=aggregationSets.regionalServiceSLIs,
        extraSourceSelector=selector,
      ),
    ),

  'aggregated-feature-category-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.featureCategorySourceSLIs,
        targetAggregationSet=aggregationSets.featureCategorySLIs,
        extraSourceSelector=selector,
        extrasForGroup={ partial_response_strategy: 'abort' },
      ),
    ),

  'aggregated-service-component-stage-group-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.featureCategorySourceSLIs,
        targetAggregationSet=aggregationSets.serviceComponentStageGroupSLIs,
        extraSourceSelector=selector,
        extrasForGroup={ partial_response_strategy: 'abort' },
      ),
    ),


  local services = (import 'gitlab-metrics-config.libsonnet').monitoredServices,
  local dangerouslyThanosEvaluatedServices = std.filter(
    function(service) service.dangerouslyThanosEvaluated && service.hasFeatureCategorySLIs(),
    services
  ),
  local thanosEvaluatedServiceNames = std.map(function(s) s.type, dangerouslyThanosEvaluatedServices),

  'globally-aggregated-service-component-stage-group-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.featureCategorySLIs,
        targetAggregationSet=aggregationSets.serviceComponentStageGroupSLIs,
        extraSourceSelector=selector {
          type: { oneOf: thanosEvaluatedServiceNames },
        },
        extrasForGroup={ partial_response_strategy: 'abort' },
      ),
    ),

  'aggregated-stage-group-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.featureCategorySourceSLIs,
        targetAggregationSet=aggregationSets.stageGroupSLIs,
        extraSourceSelector=selector,
        extrasForGroup={ partial_response_strategy: 'abort' },
      ),
    ),

  'globally-aggregated-stage-group-metrics':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.featureCategorySLIs,
        targetAggregationSet=aggregationSets.stageGroupSLIs,
        extraSourceSelector=selector {
          type: { oneOf: thanosEvaluatedServiceNames },
        },
        extrasForGroup={ partial_response_strategy: 'abort' },
      ),
    ),

  // Application SLIs not used in the service catalog  will be aggregated here.
  // These aggregations allow us to see what the metrics look like before adding
  // an them, so we can validate they would not trigger alerts.
  // If the application SLI is added to the service catalog, it will automatically
  // generate `sli_aggregation:` recordings that can be reused everywhere. So no
  // real need to duplicate them.
  'aggregated-application-sli-metrics':
    outputPromYaml(
      std.flatMap(
        function(sli)
          groupsForApplicationSli(sli, selector),
        applicationSlis
      ),
    ),

  /**
   * Aggregates component SLIs that are evaluated only in Thanos
   * Used for Thanos self-monitoring
   */
  'aggregated-global-component-slis':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.globallyEvaluatedSourceSLIs,
        targetAggregationSet=aggregationSets.globallyEvaluatedSLIs,
        extraSourceSelector=selector,
      ),
    ),


  /**
   * Aggregates component SLIs to service level that are evaluated only in Thanos
   * Used for Thanos self-monitoring
   */
  'aggregated-global-service-slis':
    outputPromYaml(
      transformRuleGroups(
        sourceAggregationSet=aggregationSets.globallyEvaluatedSourceSLIs,
        targetAggregationSet=aggregationSets.globallyEvaluatedServiceSLIs,
        extraSourceSelector=selector,
      ),
    ),
};

separateGlobalRecordingFiles(filesForSeparateSelector)
