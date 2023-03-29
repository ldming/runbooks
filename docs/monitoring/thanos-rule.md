# Thanos Rule

Docs: <https://thanos.io/tip/components/rule.md/>

Thanos Rule acts similar to a Prometheus server. It evalutes Prometheus
recording and alerting rules and prodcues TSDB adata and alerts to the
Alertmanager.

Our rules evaluated by the ruler are in [runbooks/rules](https://gitlab.com/gitlab-com/runbooks/-/tree/master/rules)
Rules are deployed to thanos via a GCS bucket as noted in the `deploy-thanos-rules` ci job.
Thanos ruler then reads the rules from the GCS bucket as configured in [ruler template](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-helmfiles/-/blob/master/releases/thanos/ops.yaml.gotmpl)
