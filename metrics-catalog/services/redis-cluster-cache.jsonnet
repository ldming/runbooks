local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local redisArchetype = import 'service-archetypes/redis-rails-archetype.libsonnet';
local redisHelpers = import './lib/redis-helpers.libsonnet';

local railsCacheSelector = redisHelpers.storeSelector('RedisCacheStore');

metricsCatalog.serviceDefinition(
  redisArchetype(
    type='redis-cluster-cache',
    railsStorageSelector=redisHelpers.storageSelector('cluster_cache'),
    descriptiveName='Redis Cache in Redis Cluster'
  )
  {
    monitoringThresholds+: {
      apdexScore: 0.9995,
    },
    serviceLevelIndicators+: {
      rails_redis_client+: {
        userImpacting: true,
        severity: 's4',
      },
      primary_server+: {
        userImpacting: true,
        severity: 's4',
      },
      secondary_servers+: {
        userImpacting: true,
        severity: 's4',
      },
      // Rails Cache uses metrics from the main application to guage to performance of the Redis cache
      // This is useful since it's not easy for us to directly calculate an apdex from the Redis metrics
      // directly
      rails_cache: {
        apdexSkip: 'rails_cache is a subset of rails_redis_client',
        severity: 's4',
        userImpacting: true,
        featureCategory: 'not_owned',
        description: |||
          Rails ActiveSupport Cache operations against the Redis Cache
        |||,

        apdex: histogramApdex(
          histogram='gitlab_cache_operation_duration_seconds_bucket',
          selector=railsCacheSelector,
          satisfiedThreshold=0.1,
          toleratedThreshold=0.25
        ),

        requestRate: rateMetric(
          counter='gitlab_cache_operation_duration_seconds_count',
          selector=railsCacheSelector,
        ),

        significantLabels: [],
      },
    },
  }
  + redisHelpers.gitlabcomObservabilityToolingForRedis('redis-cluster-cache')
)
