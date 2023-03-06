local redisHelpers = import './lib/redis-helpers.libsonnet';
local redisArchetype = import 'service-archetypes/redis-rails-archetype.libsonnet';
local metricsCatalog = import 'servicemetrics/metrics.libsonnet';

local rateMetric = metricsCatalog.rateMetric;


// TODO: switch to `rate_limiting` after Rails app drops ClusterRateLimiting class
local railsStorageSelector = { storage: 'cluster_rate_limiting' };
local descriptiveName = 'Redis Cluster Rate-Limiting';

metricsCatalog.serviceDefinition(
  redisArchetype(
    type='redis-cluster-ratelimiting',
    railsStorageSelector=railsStorageSelector,
    descriptiveName=descriptiveName,
  )
  {
    monitoringThresholds+: {
      apdexScore: 0.9995,
    },
    // disable alerts until we are receiving production traffic
    serviceLevelIndicators+: {
      rails_redis_client+: {
        userImpacting: false,
        severity: 's4',
      },
      primary_server+: {
        userImpacting: false,
        severity: 's4',
      },
      secondary_servers+: {
        userImpacting: false,
        severity: 's4',
      },
      cluster_redirections: {
        userImpacting: false,  // set as true with above after prod traffic is received
        severity: 's4',

        featureCategory: 'not_owned',
        description: |||
          Redirections on the Redis Cluster nodes for the %(descriptiveName)s instance.
          The client automatically retries with another server-prescribed target node.
        ||| % { descriptiveName: descriptiveName },
        significantLabels: ['redirection_type'],

        requestRate: rateMetric(
          counter='gitlab_redis_client_requests_total',
          selector=railsStorageSelector,
        ),

        errorRate: rateMetric(
          counter='gitlab_redis_client_redirections_total',
          selector=railsStorageSelector,
        ),
        serviceAggregation: false,
      },
    },
  }
  + redisHelpers.gitlabcomObservabilityToolingForRedis('redis-cluster-ratelimiting')
)
