<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

#  Console Service
* **Alerts**: https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22console%22%2C%20tier%3D%22sv%22%7D
* **Label**: gitlab-com/gl-infra/production~"Service:Console"

## Logging

* [history]()
* []()

## Troubleshooting Pointers

* [../bastions/gprd-bastions.md](../bastions/gprd-bastions.md)
* [../bastions/gstg-bastions.md](../bastions/gstg-bastions.md)
* [../bastions/pre-bastions.md](../bastions/pre-bastions.md)
* [../bastions/testbed-bastion.md](../bastions/testbed-bastion.md)
* [../ci-runners/ci-apdex-violating-slo.md](../ci-runners/ci-apdex-violating-slo.md)
* [../ci-runners/service-ci-runners.md](../ci-runners/service-ci-runners.md)
* [../cloudflare/logging.md](../cloudflare/logging.md)
* [../customers/api-key-rotation.md](../customers/api-key-rotation.md)
* [../elastic/elasticsearch-integration-in-gitlab.md](../elastic/elasticsearch-integration-in-gitlab.md)
* [../frontend/haproxy.md](../frontend/haproxy.md)
* [../git/purge-git-data.md](../git/purge-git-data.md)
* [../gitaly/find-project-from-hashed-storage.md](../gitaly/find-project-from-hashed-storage.md)
* [../gitaly/gitaly-down.md](../gitaly/gitaly-down.md)
* [../gitaly/gitaly-token-rotation.md](../gitaly/gitaly-token-rotation.md)
* [../gitaly/storage-rebalancing.md](../gitaly/storage-rebalancing.md)
* [../kas/kubernetes-agent-basic-troubleshooting.md](../kas/kubernetes-agent-basic-troubleshooting.md)
* [../license/license-gitlab-com.md](../license/license-gitlab-com.md)
* [../logging/logging_gcs_archive_bigquery.md](../logging/logging_gcs_archive_bigquery.md)
* [../monitoring/alertmanager-notification-failures.md](../monitoring/alertmanager-notification-failures.md)
* [../monitoring/alerts_gke.md](../monitoring/alerts_gke.md)
* [../monitoring/filesystem_alerts.md](../monitoring/filesystem_alerts.md)
* [../monitoring/prometheus-pod-crashlooping.md](../monitoring/prometheus-pod-crashlooping.md)
* [../monitoring/sentry-is-down.md](../monitoring/sentry-is-down.md)
* [../pages/pages-domain-lookup.md](../pages/pages-domain-lookup.md)
* [../pages/pages-letsencrypt.md](../pages/pages-letsencrypt.md)
* [../patroni/patroni-management.md](../patroni/patroni-management.md)
* [../patroni/performance-degradation-troubleshooting.md](../patroni/performance-degradation-troubleshooting.md)
* [../patroni/pg-ha.md](../patroni/pg-ha.md)
* [../patroni/postgres.md](../patroni/postgres.md)
* [../patroni/postgresql-backups-wale-walg.md](../patroni/postgresql-backups-wale-walg.md)
* [../patroni/rotating-rails-postgresql-password.md](../patroni/rotating-rails-postgresql-password.md)
* [../patroni/scale-down-patroni.md](../patroni/scale-down-patroni.md)
* [../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md](../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md)
* [../pgbouncer/pgbouncer-add-instance.md](../pgbouncer/pgbouncer-add-instance.md)
* [../pgbouncer/pgbouncer-connections.md](../pgbouncer/pgbouncer-connections.md)
* [../pgbouncer/pgbouncer-remove-instance.md](../pgbouncer/pgbouncer-remove-instance.md)
* [../pgbouncer/pgbouncer-saturation.md](../pgbouncer/pgbouncer-saturation.md)
* [../postgres-dr-delayed/postgres-dr-replicas.md](../postgres-dr-delayed/postgres-dr-replicas.md)
* [../praefect/praefect-database.md](../praefect/praefect-database.md)
* [../redis/clear_anonymous_sessions.md](../redis/clear_anonymous_sessions.md)
* [../redis/redis.md](../redis/redis.md)
* [../registry/gitlab-registry.md](../registry/gitlab-registry.md)
* [../sidekiq/large-sidekiq-queue.md](../sidekiq/large-sidekiq-queue.md)
* [../sidekiq/sidekiq-inspection.md](../sidekiq/sidekiq-inspection.md)
* [../sidekiq/sidekiq-survival-guide-for-sres.md](../sidekiq/sidekiq-survival-guide-for-sres.md)
* [../sidekiq/sidekiq_error_rate_high.md](../sidekiq/sidekiq_error_rate_high.md)
* [../sidekiq/sidekiq_stats_no_longer_showing.md](../sidekiq/sidekiq_stats_no_longer_showing.md)
* [../sidekiq/silent-project-exports.md](../sidekiq/silent-project-exports.md)
* [../uncategorized/about-gitlab-com.md](../uncategorized/about-gitlab-com.md)
* [../uncategorized/block-high-load-project.md](../uncategorized/block-high-load-project.md)
* [../uncategorized/debug-failed-chef-provisioning.md](../uncategorized/debug-failed-chef-provisioning.md)
* [../uncategorized/delete-projects-manually.md](../uncategorized/delete-projects-manually.md)
* [../uncategorized/deleted-project-restore.md](../uncategorized/deleted-project-restore.md)
* [../uncategorized/domain-registration.md](../uncategorized/domain-registration.md)
* [../uncategorized/gcloud-cli.md](../uncategorized/gcloud-cli.md)
* [../uncategorized/gcp-network-intelligence.md](../uncategorized/gcp-network-intelligence.md)
* [../uncategorized/gemnasium_is_down.md](../uncategorized/gemnasium_is_down.md)
* [../uncategorized/geo-recover-repo-from-azure.md](../uncategorized/geo-recover-repo-from-azure.md)
* [../uncategorized/granting-rails-or-db-access.md](../uncategorized/granting-rails-or-db-access.md)
* [../uncategorized/k8s-cluster-upgrade.md](../uncategorized/k8s-cluster-upgrade.md)
* [../uncategorized/k8s-oncall-setup.md](../uncategorized/k8s-oncall-setup.md)
* [../uncategorized/k8s-operations.md](../uncategorized/k8s-operations.md)
* [../uncategorized/kubernetes.md](../uncategorized/kubernetes.md)
* [../uncategorized/manage-cog.md](../uncategorized/manage-cog.md)
* [../uncategorized/missing_repos.md](../uncategorized/missing_repos.md)
* [../uncategorized/namespace-restore.md](../uncategorized/namespace-restore.md)
* [../uncategorized/node_cpu.md](../uncategorized/node_cpu.md)
* [../uncategorized/project-export.md](../uncategorized/project-export.md)
* [../uncategorized/reindex-package-in-packagecloud.md](../uncategorized/reindex-package-in-packagecloud.md)
* [../uncategorized/ruby-profiling.md](../uncategorized/ruby-profiling.md)
* [../uncategorized/shared-configurations.md](../uncategorized/shared-configurations.md)
* [../uncategorized/staging-environment.md](../uncategorized/staging-environment.md)
* [../uncategorized/uploads.md](../uncategorized/uploads.md)
* [../uncategorized/workers-high-load.md](../uncategorized/workers-high-load.md)
* [../vault/vault.md](../vault/vault.md)
* [../version/version-gitlab-com.md](../version/version-gitlab-com.md)
* [../web/web-rotate-object-storage-service-key.md](../web/web-rotate-object-storage-service-key.md)
<!-- END_MARKER -->


<!-- ## Summary -->

<!-- ## Architecture -->

<!-- ## Performance -->

<!-- ## Scalability -->

<!-- ## Availability -->

<!-- ## Durability -->

<!-- ## Security/Compliance -->

<!-- ## Monitoring/Alerting -->

<!-- ## Links to further Documentation -->
