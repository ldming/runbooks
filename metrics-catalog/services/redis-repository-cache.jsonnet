local redisHelpers = import './lib/redis-helpers.libsonnet';
local redisArchetype = import 'service-archetypes/redis-rails-archetype.libsonnet';
local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;

metricsCatalog.serviceDefinition(
  redisArchetype(
    type='redis-repository-cache',
    railsStorageSelector={ storage: 'repository_cache' },
    descriptiveName='Redis Repository Cache'
  )
  {
    monitoringThresholds+: {
      apdexScore: 0.9995,
    },
    serviceLevelIndicators+: {
      rails_cache: {
        userImpacting: true,
        featureCategory: 'not_owned',
        description: |||
          Rails ActiveSupport Cache operations against the Redis Repository Cache
        |||,

        apdex: histogramApdex(
          histogram='gitlab_cache_operation_duration_seconds_bucket',
          selector={ store: 'RedisRepositoryCache' },
          satisfiedThreshold=0.01,
          toleratedThreshold=0.1
        ),

        requestRate: rateMetric(
          counter='gitlab_cache_operation_duration_seconds_count',
          selector={ store: 'RedisRepositoryCache' },
        ),

        significantLabels: [],
      },
    },
  }
  + redisHelpers.gitlabcomObservabilityToolingForRedis('redis-repository-cache')
)
