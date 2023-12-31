local redisHelpers = import './lib/redis-helpers.libsonnet';
local redisArchetype = import 'service-archetypes/redis-rails-archetype.libsonnet';
local metricsCatalog = import 'servicemetrics/metrics.libsonnet';

metricsCatalog.serviceDefinition(
  redisArchetype(
    type='redis-cluster-chat-cache',
    railsStorageSelector={ storage: 'chat' },
    descriptiveName='Redis Cluster Chat Cache',
    redisCluster=true
  )
  {
    monitoringThresholds+: {
      apdexScore: 0.9995,
    },
    // disable alerts until we are receiving production traffic
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
    },


  }
  + redisHelpers.gitlabcomObservabilityToolingForRedis('redis-cluster-chat-cache')
)
