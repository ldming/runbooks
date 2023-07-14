<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

# Patroni Service

* [Service Overview](https://dashboards.gitlab.net/d/patroni-main/patroni-overview)
* **Alerts**: <https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22patroni%22%2C%20tier%3D%22db%22%7D>
* **Label**: gitlab-com/gl-infra/production~"Service::Patroni"

## Logging

* [Postgres](https://log.gprd.gitlab.net/goto/d0f8993486c9007a69d85e3a08f1ea7c)
* [system](https://log.gprd.gitlab.net/goto/3669d551a595a3a5cf1e9318b74e6c22)

## Troubleshooting Pointers

* [../ci-runners/ci-apdex-violating-slo.md](../ci-runners/ci-apdex-violating-slo.md)
* [../ci-runners/service-ci-runners.md](../ci-runners/service-ci-runners.md)
* [Interacting with Consul](../consul/interaction.md)
* [Google Cloud Snapshots](../disaster-recovery/gcp-snapshots.md)
* [Alerting](../monitoring/alerts_manual.md)
* [../monitoring/prometheus-failing-rule-evaluations.md](../monitoring/prometheus-failing-rule-evaluations.md)
* [Diagnosis with Kibana](../onboarding/kibana-diagnosis.md)
* [Recovering from CI Patroni cluster lagging too much or becoming completely broken](../patroni-ci/recovering_patroni_ci_intense_lagging_or_replication_stopped.md)
* [Steps to create (or recreate) a Standby CLuster using a Snapshot from a Production cluster as Master cluster (instead of pg_basebackup)](build_cluster_from_snapshot.md)
* [Check the status of transaction wraparound Runbook](check_wraparound.md)
* [Custom PostgreSQL Package Build Process for Ubuntu Xenial 16.04](custom_postgres_packages.md)
* [database_peak_analysis.md](database_peak_analysis.md)
* [Patroni GCS Snapshots](gcs-snapshots.md)
* [Geo Patroni Cluster Management](geo-patroni-cluster.md)
* [gitlab-com-wale-backups.md](gitlab-com-wale-backups.md)
* [gitlab-com-walg-backups.md](gitlab-com-walg-backups.md)
* [Log analysis on PostgreSQL, Pgbouncer, Patroni and consul Runbook](log_analysis.md)
* [Making a manual clone of the DB for the data team](manual_data_team_clone.md)
* [Mapping Postgres Statements, Slowlogs, Activity Monitoring and Traces](mapping_statements.md)
* [OS Upgrade Reference Architecture](os_upgrade_reference_architecture.md)
* [Patroni Cluster Management](patroni-management.md)
* [performance-degradation-troubleshooting.md](performance-degradation-troubleshooting.md)
* [PostgreSQL HA](pg-ha.md)
* [pg_collect_query_data.md](pg_collect_query_data.md)
* [Postgresql minor upgrade](pg_minor_upgrade.md)
* [Pg_repack using gitlab-pgrepack](pg_repack.md)
* [pgbadger Runbook](pgbadger_report.md)
* [GitLab application-side reindexing](postgres-automatic-reindexing.md)
* [postgres-backups-verification-failures.md](postgres-backups-verification-failures.md)
* [postgres-checkup.md](postgres-checkup.md)
* [Dealing with Data Corruption in PostgreSQL](postgres-data-corruption.md)
* [Diagnosing long running transactions](postgres-long-running-transaction.md)
* [postgres.md](postgres.md)
* [postgresql-backups-wale-walg.md](postgresql-backups-wale-walg.md)
* [PostgreSQL](postgresql-disk-space.md)
* [postgresql-locking.md](postgresql-locking.md)
* [Adding a PostgreSQL replica](postgresql-replica.md)
* [Credential rotation](postgresql-role-credential-rotation.md)
* [PostgreSQL VACUUM](postgresql-vacuum.md)
* [Postgresql](postgresql.md)
* [How to provision the benchmark environment](provisioning_bench_env.md)
* [Rails SQL Apdex alerts](rails-sql-apdex-slow.md)
* [Rotating Rails' PostgreSQL password](rotating-rails-postgresql-password.md)
* [Scale Down Patroni](scale-down-patroni.md)
* [Scale Up Patroni](scale-up-patroni.md)
* [Handling Unhealthy Patroni Replica](unhealthy_patroni_node_handling.md)
* [Roles/Users grants and permission Runbook](user_grants_permission.md)
* [using-wale-gpg.md](using-wale-gpg.md)
* [../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md](../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md)
* [Add a new PgBouncer instance](../pgbouncer/pgbouncer-add-instance.md)
* [PgBouncer connection management and troubleshooting](../pgbouncer/pgbouncer-connections.md)
* [Removing a PgBouncer instance](../pgbouncer/pgbouncer-remove-instance.md)
* [../pgbouncer/service-pgbouncer.md](../pgbouncer/service-pgbouncer.md)
* [Postgres Replicas](../postgres-dr-delayed/postgres-dr-replicas.md)
* [Container Registry Database Index Bloat](../registry/db-index-bloat.md)
* [Container Registry database post-deployment migrations](../registry/db-post-deployment-migrations.md)
* [How to use flamegraphs for performance profiling](../tutorials/how_to_use_flamegraphs_for_perf_profiling.md)
* [Deleted Project Restoration](../uncategorized/deleted-project-restore.md)
* [Application Database Queries](../uncategorized/tracing-app-db-queries.md)
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
