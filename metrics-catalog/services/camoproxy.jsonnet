local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;
local haproxyComponents = import './lib/haproxy_components.libsonnet';
local toolingLinks = import 'toolinglinks/toolinglinks.libsonnet';

metricsCatalog.serviceDefinition({
  type: 'camoproxy',
  tier: 'sv',
  monitoringThresholds: {
    apdexScore: 0.999,
    errorRatio: 0.995,
  },
  serviceDependencies: {
    // If Camoproxy has any dependencies, we should add them here
  },
  serviceLevelIndicators: {
    loadbalancer: haproxyComponents.haproxyHTTPLoadBalancer(
      featureCategory='not_owned',
      stageMappings={
        main: { backends: ['camoproxy'], toolingLinks: [] },
      },
      selector={ type: 'camoproxy' },
    ),

    server: {
      featureCategory: 'not_owned',
      teams: ['sre_coreinfra'],
      description: |||
        This SLI monitors the camoproxy server via its HTTP interface.
        5xx responses are considered to be failures. Note that this SLI
        is highly dependent on upstream proxy targets, not under the control
        of GitLab. We are unable to distinguish problems in the proxy from
        upstream problems. This should be taken into account for this SLI.
      |||,

      apdex: histogramApdex(
        histogram='camo_response_duration_seconds_bucket',
        satisfiedThreshold=5,
        toleratedThreshold=10
      ),

      requestRate: rateMetric(
        counter='camo_response_duration_seconds_bucket',
        selector={ le: '+Inf' },
      ),

      errorRate: rateMetric(
        counter='camo_proxy_reponses_failed_total',
      ),

      significantLabels: ['fqdn'],

      toolingLinks: [
        toolingLinks.kibana(title='Camoproxy', index='camoproxy'),
      ],
    },
  },
})
