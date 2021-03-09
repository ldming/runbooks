local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local rateMetric = metricsCatalog.rateMetric;
local toolingLinks = import 'toolinglinks/toolinglinks.libsonnet';

metricsCatalog.serviceDefinition({
  type: 'kas',
  tier: 'sv',
  monitoringThresholds: {
    // apdexScore: 0.95,
    errorRatio: 0.99,
  },
  serviceDependencies: {
    gitaly: true,
  },
  provisioning: {
    kubernetes: true,
    vms: false,
  },
  kubeResources: {
    kas: {
      kind: 'Deployment',
      containers: [
        'kas',
      ],
    },
  },
  serviceLevelIndicators: {
    grpc_requests: {
      userImpacting: true,
      featureCategory: 'not_owned',
      team: 'sre_coreinfra',
      local baseSelector = {
        job: 'gitlab-kas',
      },
      //apdex: histogramApdex(
      //histogram='',
      //selector=baseSelector
      //),
      requestRate: rateMetric(
        counter='grpc_server_handled_total',
        selector=baseSelector
      ),

      errorRate: rateMetric(
        counter='grpc_server_handled_total',
        selector=baseSelector { grpc_code: { ne: 'OK' }, grpc_method: 'GetConfiguration' }
      ),
      significantLabels: [],
      toolingLinks: [
        toolingLinks.sentry(slug='gitlab/kas'),
        toolingLinks.kibana(title='Kubernetes Agent Server', index='kas', type='kas'),
      ],
    },
  },
})