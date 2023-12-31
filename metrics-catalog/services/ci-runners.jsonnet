local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local toolingLinks = import 'toolinglinks/toolinglinks.libsonnet';
local haproxyComponents = import './lib/haproxy_components.libsonnet';
local dependOnRedisSidekiq = import 'inhibit-rules/depend_on_redis_sidekiq.libsonnet';

metricsCatalog.serviceDefinition({
  type: 'ci-runners',
  tier: 'runners',
  contractualThresholds: {
    apdexRatio: 0.95,
    errorRatio: 0.05,
  },
  monitoringThresholds: {
    apdexScore: 0.97,
    errorRatio: 0.999,
  },
  otherThresholds: {
    mtbf: {
      apdexScore: 0.985,
      errorRatio: 0.9999,
    },
  },
  serviceDependencies: {
    api: true,
  },
  serviceLevelIndicators: {
    loadbalancer: haproxyComponents.haproxyHTTPLoadBalancer(
      userImpacting=true,
      featureCategory='runner',
      selector={ type: 'ci' },
      stageMappings={
        main: { backends: ['https_git', 'api', 'ci_gateway_catch_all'], toolingLinks: [] },
      },
      dependsOn=dependOnRedisSidekiq.railsClientComponents,
    ),
    polling: {
      userImpacting: true,
      featureCategory: 'runner',
      description: |||
        This SLI monitors job polling operations from runners, via
        Workhorse's `/api/v4/jobs/request` route.

        5xx responses are considered to be errors, and could indicate postgres timeouts (after 15s) on the main query
        used in assigning jobs to runners.
      |||,

      local baseSelector = {
        route: '^/api/v4/jobs/request\\\\z',
      },

      requestRate: rateMetric(
        counter='gitlab_workhorse_http_requests_total',
        selector=baseSelector,
      ),

      errorRate: rateMetric(
        counter='gitlab_workhorse_http_requests_total',
        selector=baseSelector { code: { re: '5..' } },
      ),

      significantLabels: ['code'],

      toolingLinks: [
        toolingLinks.kibana(
          title='Workhorse',
          index='workhorse',
          matches={ 'json.uri.keyword': '/api/v4/jobs/request' },
          includeMatchersForPrometheusSelector=false,

        ),
        toolingLinks.kibana(
          title='Postgres Slowlog',
          index='postgres',
          matches={ 'json.endpoint_id.keyword': 'POST /api/:version/jobs/request' },
          includeMatchersForPrometheusSelector=false
        ),
      ],
    },

    saas_runner_queues: {
      userImpacting: true,
      featureCategory: 'runner',
      description: |||
        This SLI monitors the shared runner queues on GitLab.com. Each job is an operation.

        Apdex uses queueing latencies for jobs which are considered to be fair-usage (less than 5 concurrently running jobs).

        Jobs marked as failing with runner system failures are considered to be in error.
      |||,

      apdex: histogramApdex(
        histogram='job_queue_duration_seconds_bucket',
        selector={ shared_runner: 'true', jobs_running_for_project: { re: '^(0|1|2|3|4)$' } },
        satisfiedThreshold=60,
      ),

      requestRate: rateMetric(
        counter='gitlab_runner_jobs_total',
        selector={
          job: 'runners-manager',
          shard: { re: 'shared-gitlab-org|private|saas-.*|windows-shared' },
        },
      ),

      errorRate: rateMetric(
        counter='gitlab_runner_failed_jobs_total',
        selector={
          job: 'runners-manager',
          shard: { re: 'shared-gitlab-org|private|saas-.*|windows-shared' },
          failure_reason: 'runner_system_failure'
        },
      ),

      significantLabels: ['jobs_running_for_project'],

      toolingLinks: [
        toolingLinks.kibana(title='CI Runners', index='runners', slowRequestSeconds=60),
      ],
    },

    saas_linux_runner_image_pull_failures: {
      serviceAggregation: false,
      monitoringThresholds+: {
        errorRatio: 0.95,
      },

      userImpacting: true,
      featureCategory: 'runner',
      description: |||
        This SLI monitors the saas runner queues on GitLab.com. Each job is an operation.

        Jobs marked as failing with image pull failures are considered to be in error.
      |||,

      requestRate: rateMetric(
        counter='gitlab_runner_jobs_total',
        selector={
          job: 'runners-manager',
          shard: { re: 'shared-gitlab-org|private|saas-linux-.*' },
        },
      ),

      errorRate: rateMetric(
        counter='gitlab_runner_failed_jobs_total',
        selector={
          job: 'runners-manager',
          shard: { re: 'shared-gitlab-org|private|saas-linux-.*' },
          failure_reason: 'image_pull_failure'
        },
      ),

      significantLabels: ['jobs_running_for_project'],

      toolingLinks: [
        toolingLinks.kibana(title='CI Runners', index='runners', slowRequestSeconds=60),
      ],
    },

    queuing_queries_duration: {
      userImpacting: false,
      featureCategory: 'continuous_integration',
      team: 'pipeline_execution',
      description: |||
        This SLI monitors the queuing queries duration. Everything above 1
        second is considered to be unexpected and needs investigation.

        These database queries are executed in the Rails application when a
        runner requests a new build to process in `POST /api/v4/jobs/request`.
      |||,

      apdex: histogramApdex(
        histogram='gitlab_ci_queue_retrieval_duration_seconds_bucket',
        satisfiedThreshold=0.5,
      ),

      requestRate: rateMetric(
        counter='gitlab_ci_queue_retrieval_duration_seconds_count',
      ),

      monitoringThresholds+: {
        apdexScore: 0.999,
      },

      significantLabels: ['runner_type'],
      toolingLinks: [],
    },

    // Trace archive jobs do not mark themselves as failed
    // when a job fails, instead they increment the job_trace_archive_failed_total counter
    // For this reason, our normal Sidekiq job monitoring doesn't alert us to these failures.
    // Instead, track this as a component of the CI service
    // https://gitlab.com/gitlab-org/gitlab/blob/master/app/services/ci/archive_trace_service.rb
    trace_archiving_ci_jobs: {
      userImpacting: true,
      featureCategory: 'continuous_integration',
      description: |||
        This SLI monitors CI job archiving, via Sidekiq jobs.
      |||,

      requestRate: rateMetric(
        counter='sidekiq_jobs_completion_seconds_count',
        selector={ worker: 'Ci::ArchiveTraceWorker' }
      ),

      errorRate: rateMetric(
        counter='job_trace_archive_failed_total',
      ),

      significantLabels: [],

      toolingLinks: [
        toolingLinks.grafana(title='ArchiveTraceWorker Detail', dashboardUid='sidekiq-queue-detail', vars={ queue: 'pipeline_background:ci_archive_trace' }),
        toolingLinks.kibana(
          title='Sidekiq ArchiveTraceWorker',
          index='sidekiq',
          matches={ 'json.class.keyword': 'Ci::ArchiveTraceWorker' }
        ),
      ],
    },
  },
})
