local services = (import 'gitlab-metrics-config.libsonnet').monitoredServices;

local filesForServices = (import 'recording-rules/service-key-metrics-rule-files.libsonnet').filesForServices;

local aggregationSets = (import 'gitlab-metrics-config.libsonnet').aggregationSets;

/**
 * The source SLI recording rules are each kept in their own files, generated from this
 */
local dangerouslyThanosEvaluatedServices = std.filter(function(service) service.dangerouslyThanosEvaluated, services);

/**
 *  These are not separated by environment, as they are only globally evaluated.
 * Currently, this is only used for 2 services:
 *
 * - Thanos: This service has a static environment configured in the recording rules
 * - code-suggestions: this service currently only runs in a gprd-environment. We don't
 *   have metrics for any other environment
 *
 * When more service start using thanos-receive to get their metrics into our global
 * view, we'll need to extend this to record per separate environment.
 */
filesForServices(
  services=dangerouslyThanosEvaluatedServices,
  // This is using `promSource` as the aggregation sets here, which is not entirely
  // accurate since this is a global view, and not a source view.
  // However, the aggregation sets aren't exactly the same
  componentAggregationSet=aggregationSets.promSourceSLIs,
  nodeAggregationSet=aggregationSets.promSourceNodeComponentSLIs,
  featureCategoryAggregationSet=aggregationSets.featureCategorySLIs,
  shardAggregationSet=aggregationSets.promSourceShardComponentSLIs,
  groupExtras={ partial_response_strategy: 'warn' }
)
