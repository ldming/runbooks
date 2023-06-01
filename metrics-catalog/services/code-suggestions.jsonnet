local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local histogramApdex = metricsCatalog.histogramApdex;
local toolingLinks = import 'toolinglinks/toolinglinks.libsonnet';

local baseSelector = { type: 'code_suggestions' };

metricsCatalog.serviceDefinition({
  type: 'code_suggestions',
  tier: 'sv',
  monitoringThresholds: {
    apdexScore: 0.95,
    errorRatio: 0.999,
  },
  provisioning: {
    vms: false,
    kubernetes: true,
  },
  serviceDependencies: {
    api: true,
  },
  serviceIsStageless: true,

  // This is evaluated in Thanos because the prometheus uses thanos-receive to
  // get its metrics available.
  // Our recording rules are currently not deployed to the external cluster that runs
  // code-suggestions.
  // We should get rid of this to be in line with other services when we can
  dangerouslyThanosEvaluated: true,

  serviceLevelIndicators: {
    model_gateway: {
      local modelGatewaySelector = baseSelector { container: 'model-gateway' },
      severity: 's4',  // NOTE: Do not page on-call SREs until production ready
      userImpacting: true,
      team: 'ai_assisted',
      featureCategory: 'code_suggestions',

      requestRate: rateMetric(
        counter='http_request_duration_seconds_count',
        selector=modelGatewaySelector,
        useRecordingRuleRegistry=false,
      ),

      errorRate: rateMetric(
        counter='http_requests_total',
        selector=modelGatewaySelector { status: '5xx' },
        useRecordingRuleRegistry=false,
      ),

      apdex: histogramApdex(
        histogram='http_request_duration_seconds_bucket',
        selector=modelGatewaySelector { status: { noneOf: ['4xx', '5xx'] } },
        satisfiedThreshold='10.0',
      ),

      significantLabels: ['status', 'handler', 'method'],

      toolingLinks: [
        toolingLinks.kibana(title='MLOps', index='mlops'),
      ],
    },

    ingress: {
      local ingressSelector = baseSelector { container: 'controller', path: { ne: '/' } },
      severity: 's4',  // NOTE: Do not page on-call SREs until production ready
      userImpacting: true,
      team: 'ai_assisted',
      featureCategory: 'code_suggestions',
      serviceAggregation: false,

      requestRate: rateMetric(
        counter='nginx_ingress_controller_requests',
        selector=ingressSelector,
        useRecordingRuleRegistry=false,
      ),

      errorRate: rateMetric(
        counter='nginx_ingress_controller_requests',
        selector=ingressSelector {
          status: { re: '^5.*' },
        },
        useRecordingRuleRegistry=false,
      ),

      apdex: histogramApdex(
        histogram='nginx_ingress_controller_request_duration_seconds_bucket',
        selector=ingressSelector { status: { noneOf: ['4.*', '5.*'] } },
        satisfiedThreshold=5,
        toleratedThreshold=10
      ),

      significantLabels: ['path', 'status', 'method'],

      toolingLinks: [],
    },
  },
})
