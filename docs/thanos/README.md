<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

# Thanos Service

* [Service Overview](https://dashboards.gitlab.net/d/thanos-main/thanos-overview)
* **Alerts**: <https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22thanos%22%2C%20tier%3D%22inf%22%7D>
* **Label**: gitlab-com/gl-infra/production~"Service::Thanos"

## Logging

* [system](https://log.gprd.gitlab.net/goto/3a0b51d10d33c9558765e97640acb325)
* [gstg](https://nonprod-log.gitlab.net/goto/73178d30-ab9a-11ed-9af2-6131f0ee4ce6)
* [ops](https://nonprod-log.gitlab.net/goto/c3052140-ab9a-11ed-9af2-6131f0ee4ce6)
* [pre](https://nonprod-log.gitlab.net/goto/f5420010-ab9a-11ed-9af2-6131f0ee4ce6)

## Troubleshooting Pointers

* [How to detect CI Abuse](../ci-runners/ci-abuse-handling.md)
* [../ci-runners/ci-apdex-violating-slo.md](../ci-runners/ci-apdex-violating-slo.md)
* [Chef troubleshooting](../config_management/chef-troubleshooting.md)
* [ErrorTracking main troubleshooting document](../errortracking/overview.md)
* [Gitaly token rotation](../gitaly/gitaly-token-rotation.md)
* [GitLab.com on Kubernetes](../kube/k8s-new-cluster.md)
* [How to resize Persistent Volumes in Kubernetes](../kube/k8s-pvc-resize.md)
* [StatefulSet Guidelines](../kube/sts-guidelines.md)
* [Alertmanager Notification Failures](../monitoring/alertmanager-notification-failures.md)
* [Alerting](../monitoring/alerts_manual.md)
* [../monitoring/apdex-alerts-guide.md](../monitoring/apdex-alerts-guide.md)
* [../monitoring/prometheus-is-down.md](../monitoring/prometheus-is-down.md)
* [Prometheus pod crashlooping](../monitoring/prometheus-pod-crashlooping.md)
* [Thanos Compact](../monitoring/thanos-compact.md)
* [Deleting series over a given interval from thanos](../monitoring/thanos-delete-series-interval.md)
* [Thanos Query and Stores](../monitoring/thanos-query.md)
* [Thanos Rule](../monitoring/thanos-rule.md)
* [Thanos Store](../monitoring/thanos-store.md)
* [Stackdriver tracing for the Thanos stack](../monitoring/thanos-tracing.md)
* [Thanos General Alerts](../monitoring/thanos.md)
* [Upgrading Monitoring Components](../monitoring/upgrades.md)
* [Diagnosis with Kibana](../onboarding/kibana-diagnosis.md)
* [Block specific pages domains through HAproxy](../pages/block-pages-domain.md)
* [Steps to Recreate/Rebuild the CI CLuster using a Snapshot from the Master cluster (instead of pg_basebackup)](../patroni-ci/rebuild_ci_cluster_from_prod.md)
* [Recovering from CI Patroni cluster lagging too much or becoming completely broken](../patroni-ci/recovering_patroni_ci_intense_lagging_or_replication_stopped.md)
* [../patroni/database_peak_analysis.md](../patroni/database_peak_analysis.md)
* [Geo Patroni Cluster Management](../patroni/geo-patroni-cluster.md)
* [Mapping Postgres Statements, Slowlogs, Activity Monitoring and Traces](../patroni/mapping_statements.md)
* [../patroni/pg_collect_query_data.md](../patroni/pg_collect_query_data.md)
* [`pg_txid_xmin_age` Saturation Alert](../patroni/pg_xid_xmin_age_alert.md)
* [../patroni/postgres.md](../patroni/postgres.md)
* [../patroni/postgresql-backups-wale-walg.md](../patroni/postgresql-backups-wale-walg.md)
* [Rails SQL Apdex alerts](../patroni/rails-sql-apdex-slow.md)
* [Handling Unhealthy Patroni Replica](../patroni/unhealthy_patroni_node_handling.md)
* [Postgres Replicas](../postgres-dr-delayed/postgres-dr-replicas.md)
* [Praefect replication is lagging or has stopped](../praefect/praefect-replication.md)
* [../redis/redis-functional-partitioning.md](../redis/redis-functional-partitioning.md)
* [A survival guide for SREs to working with Redis at GitLab](../redis/redis-survival-guide-for-sres.md)
* [../redis/redis.md](../redis/redis.md)
* [Container Registry Database Index Bloat](../registry/db-index-bloat.md)
* [GET Monitoring Setup](../staging-ref/get-monitoring-setup.md)
* [Vault Secrets Management](../vault/vault.md)
* [Diagnostic Reports](../web/diagnostic-reports.md)
* [Workhorse Image Scaler](../web/workhorse-image-scaler.md)
<!-- END_MARKER -->

## Environment Labels for Thanos

Unlike all other services running GitLab.com, the Thanos service uses a unique environment label, `environment="thanos"`.

This is because, while Thanos runs in pods and VMs hosted within different environments, it is _a single interconnected service_, running across all environments simultaneously. In order for it to perform correctly, it needs to interact with subcomponents running in all other environments.

Breaking Thanos metrics down with an environment label is unhelpful and leads to metrics being incorrectly decomposed across services, and reducing our ability to measure the complete health of the service.

### Alerts for `environment="thanos"`

When Thanos generates alerts, they will use the `environment="thanos"` label. This is unique to Thanos. The Thanos dashboards will automatically display metrics for this environment, and operators do not need to switch between different environments in the Grafana dashboards to investigate these alerts.

In AlertManager, `environment="thanos"` are routed in the same way as `environment="gprd"` alerts.

<!-- ## Summary -->

<!-- ## Architecture -->

<!-- ## Performance -->

<!-- ## Scalability -->

<!-- ## Availability -->

<!-- ## Durability -->

<!-- ## Security/Compliance -->

<!-- ## Monitoring/Alerting -->

<!-- ## Links to further Documentation -->
