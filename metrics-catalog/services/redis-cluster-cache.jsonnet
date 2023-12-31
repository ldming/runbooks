local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local redisArchetype = import 'service-archetypes/redis-rails-archetype.libsonnet';
local redisHelpers = import './lib/redis-helpers.libsonnet';

metricsCatalog.serviceDefinition(
  redisArchetype(
    type='redis-cluster-cache',
    railsStorageSelector=redisHelpers.storageSelector('cluster_cache'),
    descriptiveName='Redis Cache in Redis Cluster',
    redisCluster=true
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
      # TODO: add rails_cache SLI after migration
    },
  }
  + redisHelpers.gitlabcomObservabilityToolingForRedis('redis-cluster-cache')
)
