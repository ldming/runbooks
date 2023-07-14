<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

# Console Service

* **Alerts**: <https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22console%22%2C%20tier%3D%22sv%22%7D>
* **Label**: gitlab-com/gl-infra/production~"Service::Console"

## Logging

* [history]()
* []()

## Troubleshooting Pointers

* [../bastions/gprd-bastions.md](../bastions/gprd-bastions.md)
* [../bastions/gstg-bastions.md](../bastions/gstg-bastions.md)
* [../bastions/ops-bastions.md](../bastions/ops-bastions.md)
* [../bastions/pre-bastions.md](../bastions/pre-bastions.md)
* [Set up bastions for Release managers](../bastions/rm-bastion-access.md)
* [../bastions/testbed-bastion.md](../bastions/testbed-bastion.md)
* [../certificates/chef_hybrid.md](../certificates/chef_hybrid.md)
* [../certificates/chef_vault.md](../certificates/chef_vault.md)
* [../certificates/fastly.md](../certificates/fastly.md)
* [../certificates/forum.md](../certificates/forum.md)
* [../certificates/gcp.md](../certificates/gcp.md)
* [../certificates/gkms.md](../certificates/gkms.md)
* [../certificates/zendesk.md](../certificates/zendesk.md)
* [How to detect CI Abuse](../ci-runners/ci-abuse-handling.md)
* [../ci-runners/ci_constantnumberoflongrunningrepeatedjobs.md](../ci-runners/ci_constantnumberoflongrunningrepeatedjobs.md)
* [../ci-runners/service-ci-runners.md](../ci-runners/service-ci-runners.md)
* [Cloud SQL Troubleshooting](../cloud-sql/cloud-sql.md)
* [Cloudflare Logs](../cloudflare/logging.md)
* [customers.gitlab.com](../customersdot/api-key-rotation.md)
* [CustomersDot main troubleshoot documentation](../customersdot/overview.md)
* [Google Cloud Snapshots](../disaster-recovery/gcp-snapshots.md)
* [What is Programmable Search Engine?](../docs.gitlab.com/programmableSearch.md)
* [Elastic Nodes Disk Space Saturation](../elastic/disk_space_saturation.md)
* [../elastic/elasticsearch-integration-in-gitlab.md](../elastic/elasticsearch-integration-in-gitlab.md)
* [Frontend (HAProxy) Logging](../frontend/haproxy-logging.md)
* [HAProxy management at GitLab](../frontend/haproxy.md)
* [Purge Git data](../git/purge-git-data.md)
* [Find a project from its hashed storage path](../gitaly/find-project-from-hashed-storage.md)
* [Gitaly is down](../gitaly/gitaly-down.md)
* [Gitaly profiling](../gitaly/gitaly-profiling.md)
* [Gitaly Repository Export](../gitaly/gitaly-repositry-export.md)
* [Gitaly token rotation](../gitaly/gitaly-token-rotation.md)
* [Moving repositories from one Gitaly node to another](../gitaly/move-repositories.md)
* [GitLab Storage Re-balancing](../gitaly/storage-rebalancing.md)
* [Kubernetes-Agent Basic Troubleshooting](../kas/kubernetes-agent-basic-troubleshooting.md)
* [GKE Cluster Upgrade Procedure](../kube/k8s-cluster-upgrade.md)
* [../kube/k8s-oncall-setup.md](../kube/k8s-oncall-setup.md)
* [../kube/k8s-operations.md](../kube/k8s-operations.md)
* [How to resize Persistent Volumes in Kubernetes](../kube/k8s-pvc-resize.md)
* [How to take a snapshot of an application running in a StatefulSet](../kube/k8s-sts-snapshot.md)
* [Kubernetes](../kube/kubernetes.md)
* [../logging/logging_gcs_archive_bigquery.md](../logging/logging_gcs_archive_bigquery.md)
* [Scaling Elastic Cloud Clusters](../logging/scaling.md)
* [Alertmanager Notification Failures](../monitoring/alertmanager-notification-failures.md)
* [Accessing a GKE Alertmanager](../monitoring/alerts_gke.md)
* [Filesystem errors are reported in LOG files](../monitoring/filesystem_alerts.md)
* [Thanos Compact](../monitoring/thanos-compact.md)
* [Stackdriver tracing for the Thanos stack](../monitoring/thanos-tracing.md)
* [Session: Application architecture](../onboarding/architecture.md)
* [Gitlab.com on Kubernetes](../onboarding/gitlab.com_on_k8s.md)
* [Re-indexing a package](../packagecloud/reindex-package.md)
* [Determine The GitLab Project Associated with a Domain](../pages/pages-domain-lookup.md)
* [Troubleshooting LetsEncrypt for Pages](../pages/pages-letsencrypt.md)
* [Steps to create (or recreate) a Standby CLuster using a Snapshot from a Production cluster as Master cluster (instead of pg_basebackup)](../patroni/build_cluster_from_snapshot.md)
* [Patroni Cluster Management](../patroni/patroni-management.md)
* [../patroni/performance-degradation-troubleshooting.md](../patroni/performance-degradation-troubleshooting.md)
* [PostgreSQL HA](../patroni/pg-ha.md)
* [Diagnosing long running transactions](../patroni/postgres-long-running-transaction.md)
* [../patroni/postgres.md](../patroni/postgres.md)
* [../patroni/postgresql-backups-wale-walg.md](../patroni/postgresql-backups-wale-walg.md)
* [How to provision the benchmark environment](../patroni/provisioning_bench_env.md)
* [Rotating Rails' PostgreSQL password](../patroni/rotating-rails-postgresql-password.md)
* [Scale Down Patroni](../patroni/scale-down-patroni.md)
* [Handling Unhealthy Patroni Replica](../patroni/unhealthy_patroni_node_handling.md)
* [../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md](../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md)
* [Add a new PgBouncer instance](../pgbouncer/pgbouncer-add-instance.md)
* [PgBouncer connection management and troubleshooting](../pgbouncer/pgbouncer-connections.md)
* [Removing a PgBouncer instance](../pgbouncer/pgbouncer-remove-instance.md)
* [Sidekiq or Web/API is using most of its PgBouncer connections](../pgbouncer/pgbouncer-saturation.md)
* [Praefect Database](../praefect/praefect-database.md)
* [Praefect Database User Password Rotation](../praefect/praefect-password-rotation.md)
* [Removing cache entries from Redis](../redis-cache/remove-cache-entries.md)
* [Clearing sessions for anonymous users](../redis/clear_anonymous_sessions.md)
* [Provisioning Redis Cluster](../redis/provisioning-redis-cluster.md)
* [Redis-Sidekiq catchall workloads reduction](../redis/redis-sidekiq-catchall-workloads-reduction.md)
* [../redis/redis.md](../redis/redis.md)
* [Container Registry database post-deployment migrations](../registry/db-post-deployment-migrations.md)
* [../registry/gitlab-registry.md](../registry/gitlab-registry.md)
* [Sentry is down and gives error 500](../sentry/sentry-is-down.md)
* [Sidekiq Queue Out of Control](../sidekiq/large-sidekiq-queue.md)
* [Poking around at sidekiq's running state](../sidekiq/sidekiq-inspection.md)
* [A survival guide for SREs to working with Sidekiq at GitLab](../sidekiq/sidekiq-survival-guide-for-sres.md)
* [../sidekiq/sidekiq_error_rate_high.md](../sidekiq/sidekiq_error_rate_high.md)
* [../sidekiq/sidekiq_stats_no_longer_showing.md](../sidekiq/sidekiq_stats_no_longer_showing.md)
* [../sidekiq/silent-project-exports.md](../sidekiq/silent-project-exports.md)
* [../spamcheck/index.md](../spamcheck/index.md)
* [How to connect to a Database console using Teleport](../teleport/Connect_to_Database_Console_via_Teleport.md)
* [How to connect to a Rails Console using Teleport](../teleport/Connect_to_Rails_Console_via_Teleport.md)
* [Teleport Administration](../teleport/teleport_admin.md)
* [Teleport Approver Workflow](../teleport/teleport_approval_workflow.md)
* [How to use flamegraphs for performance profiling](../tutorials/how_to_use_flamegraphs_for_perf_profiling.md)
* [about.gitlab.com](../uncategorized/about-gitlab-com.md)
* [Access Requests](../uncategorized/access-requests.md)
* [Blocking a project causing high load](../uncategorized/block-high-load-project.md)
* [Debug failed chef provisioning](../uncategorized/debug-failed-chef-provisioning.md)
* [Deleting a project manually](../uncategorized/delete-projects-manually.md)
* [Deleted Project Restoration](../uncategorized/deleted-project-restore.md)
* [Domain Registration](../uncategorized/domain-registration.md)
* [Getting setup with Google gcloud CLI](../uncategorized/gcloud-cli.md)
* [../uncategorized/gcp-network-intelligence.md](../uncategorized/gcp-network-intelligence.md)
* [Gemnasium is down](../uncategorized/gemnasium_is_down.md)
* [../uncategorized/granting-rails-or-db-access.md](../uncategorized/granting-rails-or-db-access.md)
* [Missing Repositories](../uncategorized/missing_repos.md)
* [../uncategorized/namespace-restore.md](../uncategorized/namespace-restore.md)
* [Node CPU alerts](../uncategorized/node_cpu.md)
* [../uncategorized/osquery.md](../uncategorized/osquery.md)
* [Project exports](../uncategorized/project-export.md)
* [Ruby profiling](../uncategorized/ruby-profiling.md)
* [Shared Configurations](../uncategorized/shared-configurations.md)
* [GitLab staging environment](../uncategorized/staging-environment.md)
* [Uploads](../uncategorized/uploads.md)
* [Workers under heavy load because of being used as a CDN](../uncategorized/workers-high-load.md)
* [Troubleshooting Hashicorp Vault](../vault/troubleshooting.md)
* [Vault Secrets Management](../vault/vault.md)
* [version.gitlab.com Runbook](../version/version-gitlab-com.md)
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
