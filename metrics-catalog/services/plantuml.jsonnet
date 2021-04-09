local googleLoadBalancerComponents = import './lib/google_load_balancer_components.libsonnet';
local metricsCatalog = import 'servicemetrics/metrics.libsonnet';
local histogramApdex = metricsCatalog.histogramApdex;
local rateMetric = metricsCatalog.rateMetric;

metricsCatalog.serviceDefinition({
  type: 'plantuml',
  tier: 'sv',
  monitoringThresholds: {
    errorRatio: 0.999,
  },
  serviceDependencies: {
  },
  provisioning: {
    kubernetes: true,
    vms: false,
  },
  kubeResources: {
    plantuml: {
      containers: [
        'plantuml',
      ],
    },
  },
  serviceLevelIndicators: {
    loadbalancer: googleLoadBalancerComponents.googleLoadBalancer(
      userImpacting=true,
      loadBalancerName='k8s-um-plantuml-plantuml--58df01f69d082883',  // This LB name seems to be auto-generated, but appears to be stable
      targetProxyName='k8s-tps-plantuml-plantuml--58df01f69d082883',  // This LB name seems to be auto-generated, but appears to be stable
      projectId='gitlab-production',
    ),
  },
})