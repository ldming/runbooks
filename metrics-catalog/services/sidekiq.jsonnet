local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local sidekiqHelpers = import './lib/sidekiq-helpers.libsonnet';
local perWorkerRecordingRules = (import './lib/sidekiq-per-worker-recording-rules.libsonnet').perWorkerRecordingRules;
local combined = metricsCatalog.combined;
local toolingLinks = import 'toolinglinks/toolinglinks.libsonnet';
local kubeLabelSelectors = metricsCatalog.kubeLabelSelectors;
local sliLibrary = import 'gitlab-slis/library.libsonnet';

local baseSelector = { type: 'sidekiq' };
local highUrgencySelector = { urgency: 'high' };
local lowUrgencySelector = { urgency: 'low' };
local throttledUrgencySelector = { urgency: 'throttled' };

metricsCatalog.serviceDefinition({
  type: 'sidekiq',
  tier: 'sv',
  tags: ['rails'],
  shardLevelMonitoring: true,  // SLIs will inherit shard-level monitoring by default

  contractualThresholds: {
    apdexRatio: 0.9,
    errorRatio: 0.005,
  },
  monitoringThresholds: {
    apdexScore: 0.995,
    errorRatio: 0.995,
  },
  otherThresholds: {
    // Deployment thresholds are optional, and when they are specified, they are
    // measured against the same multi-burn-rates as the monitoring indicators.
    // When a service is in violation, deployments may be blocked or may be rolled
    // back.
    deployment: {
      apdexScore: 0.995,
      errorRatio: 0.995,
    },
  },
  serviceDependencies: {
    gitaly: true,
    'redis-tracechunks': true,
    'redis-sidekiq': true,
    'redis-cache': true,
    redis: true,
    patroni: true,
    pgbouncer: true,
    praefect: true,
    pvs: true,
    search: true,
    consul: true,
    'google-cloud-storage': true,
  },
  provisioning: {
    kubernetes: true,
    vms: false,
  },
  // Use recordingRuleMetrics to specify a set of metrics with known high
  // cardinality. The metrics catalog will generate recording rules with
  // the appropriate aggregations based on this set.
  // Use sparingly, and don't overuse.
  recordingRuleMetrics: [
    'sidekiq_jobs_completion_seconds_bucket',
    'sidekiq_jobs_queue_duration_seconds_bucket',
    'sidekiq_jobs_failed_total',
  ] + sliLibrary.get('sidekiq_execution').recordingRuleMetrics,
  kubeConfig: {
    labelSelectors: kubeLabelSelectors(
      ingressSelector=null,  // no ingress for sidekiq
      nodeSelector={ type: 'sidekiq' },
      // Sidekiq nodes don't present a stage label at present, so\
      // we hardcode to main stage
      nodeStaticLabels={ stage: 'main' },
    ),
  },
  kubeResources: std.foldl(
    function(memo, shard)
      memo {
        // Deployment tags follow the convention sidekiq-catchall etc
        ['sidekiq-' + shard.name]: {
          kind: 'Deployment',
          containers: [
            'sidekiq',
          ],
        },
      },
    sidekiqHelpers.shards.listAll(),
    {},
  ),
  serviceLevelIndicators: {
    ['shard_' + std.strReplace(shard.name, '-', '_')]: {
      local shardSelector = baseSelector { shard: shard.name, external_dependencies: { ne: 'yes' } },

      userImpacting: shard.userImpacting,
      featureCategory: 'not_owned',
      team: 'scalability',
      trafficCessationAlertConfig: shard.trafficCessationAlertConfig,
      upscaleLongerBurnRates: true,
      monitoringThresholds+: shard.monitoringThresholds,
      shardLevelMonitoring: false,

      description: |||
        Aggregation of all jobs for the %(shard)s Sidekiq shard.
      ||| % shardSelector,
      apdex: combined(
        [
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=highUrgencySelector + shardSelector,
            satisfiedThreshold=sidekiqHelpers.slos.urgent.executionDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_queue_duration_seconds_bucket',
            selector=highUrgencySelector + shardSelector,
            satisfiedThreshold=sidekiqHelpers.slos.urgent.queueingDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=lowUrgencySelector + shardSelector,
            satisfiedThreshold=sidekiqHelpers.slos.lowUrgency.executionDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_queue_duration_seconds_bucket',
            selector=lowUrgencySelector + shardSelector,
            satisfiedThreshold=sidekiqHelpers.slos.lowUrgency.queueingDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=throttledUrgencySelector + shardSelector,
            satisfiedThreshold=sidekiqHelpers.slos.throttled.executionDurationSeconds,
          ),
          // No queueing apdex for throttled jobs
        ]
      ),

      requestRate: rateMetric(
        counter='sidekiq_jobs_completion_seconds_bucket',
        selector=shardSelector { le: '+Inf' },
      ),

      errorRate: rateMetric(
        counter='sidekiq_jobs_failed_total',
        selector=shardSelector,
      ),

      // Note: these labels will also be included in the
      // intermediate recording rules specified in the
      // `recordingRuleMetrics` stanza above
      significantLabels: ['feature_category', 'queue', 'urgency', 'worker'],

      // We don't have an `urgency` field in Sidekiq logs. Improve this in
      // https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/700
      local slowRequestSeconds =
        if shard.urgency == 'high' then
          sidekiqHelpers.slos.urgent.executionDurationSeconds
        else if shard.urgency == 'low' then
          sidekiqHelpers.slos.lowUrgency.executionDurationSeconds
        else if shard.urgency == 'throttled' then
          sidekiqHelpers.slos.throttled.executionDurationSeconds
        else
          // Default to low urgency threshold
          sidekiqHelpers.slos.lowUrgency.executionDurationSeconds,

      toolingLinks: [
        // Improve sentry link once https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/532 arrives
        toolingLinks.sentry(slug='gitlab/gitlabcom', type='sidekiq'),
        toolingLinks.kibana(title=shard.name, index='sidekiq', type='sidekiq', shard=shard.name, slowRequestSeconds=slowRequestSeconds),
      ] + (
        if std.objectHas(shard, 'gkeDeployment') then
          [
            toolingLinks.gkeDeployment(shard.gkeDeployment, type='sidekiq', shard=shard.name, containerName='sidekiq'),
          ]
        else
          []
      ),
    }
    for shard in sidekiqHelpers.shards.listAll()
  } + {
    external_dependency: {
      local externalDependencySelector = baseSelector { external_dependencies: 'yes' },
      serviceAggregation: false,
      userImpacting: true,
      severity: 's3',
      feature_category: 'not_owned',
      team: 'sre_reliability',
      description: |||
        Jobs with external dependencies across all shards.
      |||,
      shardLevelMonitoring: false,

      apdex: combined(
        [
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=highUrgencySelector + externalDependencySelector,
            satisfiedThreshold=sidekiqHelpers.slos.urgent.executionDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_queue_duration_seconds_bucket',
            selector=highUrgencySelector + externalDependencySelector,
            satisfiedThreshold=sidekiqHelpers.slos.urgent.queueingDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=lowUrgencySelector + externalDependencySelector,
            satisfiedThreshold=sidekiqHelpers.slos.lowUrgency.executionDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_queue_duration_seconds_bucket',
            selector=lowUrgencySelector + externalDependencySelector,
            satisfiedThreshold=sidekiqHelpers.slos.lowUrgency.queueingDurationSeconds,
          ),
          histogramApdex(
            histogram='sidekiq_jobs_completion_seconds_bucket',
            selector=throttledUrgencySelector + externalDependencySelector,
            satisfiedThreshold=sidekiqHelpers.slos.throttled.executionDurationSeconds,
          ),
          // No queueing apdex for throttled jobs
        ]
      ),

      requestRate: rateMetric(
        counter='sidekiq_jobs_completion_seconds_bucket',
        selector=externalDependencySelector { le: '+Inf' },
      ),

      errorRate: rateMetric(
        counter='sidekiq_jobs_failed_total',
        selector=externalDependencySelector,
      ),

      monitoringThresholds+: {
        errorRatio: 0.9,
      },

      significantLabels: ['feature_category', 'queue', 'urgency', 'worker'],
    },
  } + {
    email_receiver: {
      userImpacting: true,
      severity: 's3',
      featureCategory: 'service_desk',
      team: 'product_planning',
      description: |||
        Monitors ratio between all received emails and received emails which
        could not be processed for some reason.
      |||,
      shardLevelMonitoring: false,

      requestRate: rateMetric(
        counter='sidekiq_jobs_completion_seconds_count',
        selector=baseSelector { worker: { re: 'EmailReceiverWorker|ServiceDeskEmailReceiverWorker' } }
      ),

      errorRate: rateMetric(
        counter='gitlab_transaction_event_email_receiver_error_total',
        selector=baseSelector { 'error': { ne: 'Gitlab::Email::AutoGeneratedEmailError' } }
      ),

      monitoringThresholds+: {
        errorRatio: 0.7,
      },

      significantLabels: ['error'],

      toolingLinks: [
        toolingLinks.kibana(title='Email receiver errors', index='sidekiq', type='sidekiq', message='Error processing message'),
      ],
    },
  } + sliLibrary.get('global_search_indexing').generateServiceLevelIndicator(baseSelector, {
    serviceAggregation: false,  // Don't add this to the request rate of the service
    severity: 's3',  // Don't page SREs for this SLI
    shardLevelMonitoring: false,
  }) + sliLibrary.get('sidekiq_execution').generateServiceLevelIndicator(baseSelector { external_dependencies: { ne: 'yes' } }, {
    // TODO: change serviceAggregation to true and increase severity to s2 once the SLI per shard has been removed
    serviceAggregation: false,  // Don't add this to the request rate of the service
    severity: 's4',  // Don't page SREs for this SLI
    toolingLinks: [
      toolingLinks.kibana(title='Sidekiq execution', index='sidekiq', type='sidekiq'),
    ],
  }),

  // Special per-worker recording rules
  extraRecordingRulesPerBurnRate: [
    // Adds per-work queuing/execution apdex, plus error rates etc
    // across multiple burn rates
    perWorkerRecordingRules,
  ],
})
