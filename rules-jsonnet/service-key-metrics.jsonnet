local services = (import 'gitlab-metrics-config.libsonnet').monitoredServices;
local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;
local filesForServices = (import 'recording-rules/service-key-metrics-rule-files.libsonnet').filesForServices;

/**
 * The source SLI recording rules are each kept in their own files, generated from this
 */
local prometheusEvaluatedServices = std.filter(function(service) !service.dangerouslyThanosEvaluated, services);

filesForServices(
  services=prometheusEvaluatedServices,
  componentAggregationSet=aggregationSets.promSourceSLIs,
  nodeAggregationSet=aggregationSets.promSourceNodeComponentSLIs,
  featureCategoryAggregationSet=aggregationSets.featureCategorySourceSLIs,
  shardAggregationSet=aggregationSets.promSourceShardComponentSLIs,
)
