<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

#  Api Service
* [Service Overview](https://dashboards.gitlab.net/d/api-main/api-overview)
* **Alerts**: https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22api%22%2C%20tier%3D%22sv%22%7D
* **Label**: gitlab-com/gl-infra/production~"Service:API"

## Logging

* [Rails](https://log.gprd.gitlab.net/goto/0238ddb1480bb4bd19c09f0467b6e684)
* [Workhorse](https://log.gprd.gitlab.net/goto/eb99f28c17cfcdfd30969a1c85e209dc)
* [Unicorn](https://log.gprd.gitlab.net/goto/c8f89b2415788b46978fcd2910b4afec)
* [nginx](https://log.gprd.gitlab.net/goto/0d1c84486d6fb28a785f1c21473e5611)
* [Unstructured Rails](https://console.cloud.google.com/logs/viewer?project=gitlab-production&interval=PT1H&resource=gce_instance&advancedFilter=jsonPayload.hostname%3A%22api%22%0Alabels.tag%3D%22unstructured.production%22&customFacets=labels.%22compute.googleapis.com%2Fresource_name%22)
* [system](https://log.gprd.gitlab.net/goto/2b9679dab019791136cb8ae1535fb781)

## Troubleshooting Pointers

* [../ci-runners/ci-apdex-violating-slo.md](../ci-runners/ci-apdex-violating-slo.md)
* [../ci-runners/ci-runner-timeouts.md](../ci-runners/ci-runner-timeouts.md)
* [../ci-runners/create-runners-manager-node.md](../ci-runners/create-runners-manager-node.md)
* [../ci-runners/pipeline-deletion.md](../ci-runners/pipeline-deletion.md)
* [../cloudflare/logging.md](../cloudflare/logging.md)
* [../cloudflare/managing-traffic.md](../cloudflare/managing-traffic.md)
* [../cloudflare/services-locations.md](../cloudflare/services-locations.md)
* [../cloudflare/terraform.md](../cloudflare/terraform.md)
* [../config_management/chef-workflow.md](../config_management/chef-workflow.md)
* [../customers/api-key-rotation.md](../customers/api-key-rotation.md)
* [../elastic/elastic-cloud.md](../elastic/elastic-cloud.md)
* [../elastic/elasticsearch-integration-in-gitlab.md](../elastic/elasticsearch-integration-in-gitlab.md)
* [../frontend/haproxy.md](../frontend/haproxy.md)
* [../frontend/ssh-maxstartups-breach.md](../frontend/ssh-maxstartups-breach.md)
* [../git/deploy-gitlab-rb-change.md](../git/deploy-gitlab-rb-change.md)
* [../git/purge-git-data.md](../git/purge-git-data.md)
* [../gitaly/git-high-cpu-and-memory-usage.md](../gitaly/git-high-cpu-and-memory-usage.md)
* [../gitaly/gitaly-token-rotation.md](../gitaly/gitaly-token-rotation.md)
* [../gitaly/storage-rebalancing.md](../gitaly/storage-rebalancing.md)
* [../gitaly/storage-servers.md](../gitaly/storage-servers.md)
* [../kas/kubernetes-agent-basic-troubleshooting.md](../kas/kubernetes-agent-basic-troubleshooting.md)
* [../kas/kubernetes-agent-disable-integrations.md](../kas/kubernetes-agent-disable-integrations.md)
* [../monitoring/alertmanager-notification-failures.md](../monitoring/alertmanager-notification-failures.md)
* [../monitoring/alerts_manual.md](../monitoring/alerts_manual.md)
* [../monitoring/apdex-alerts-guide.md](../monitoring/apdex-alerts-guide.md)
* [../patroni/geo-patroni-cluster.md](../patroni/geo-patroni-cluster.md)
* [../patroni/patroni-management.md](../patroni/patroni-management.md)
* [../patroni/pg_collect_query_data.md](../patroni/pg_collect_query_data.md)
* [../patroni/pg_repack.md](../patroni/pg_repack.md)
* [../patroni/postgres.md](../patroni/postgres.md)
* [../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md](../pgbouncer/patroni-consul-postgres-pgbouncer-interactions.md)
* [../pgbouncer/pgbouncer-connections.md](../pgbouncer/pgbouncer-connections.md)
* [../pgbouncer/pgbouncer-saturation.md](../pgbouncer/pgbouncer-saturation.md)
* [../redis/redis-survival-guide-for-sres.md](../redis/redis-survival-guide-for-sres.md)
* [../sidekiq/large-sidekiq-queue.md](../sidekiq/large-sidekiq-queue.md)
* [../sidekiq/sidekiq-survival-guide-for-sres.md](../sidekiq/sidekiq-survival-guide-for-sres.md)
* [../uncategorized/blocked-user-logins.md](../uncategorized/blocked-user-logins.md)
* [../uncategorized/gemnasium_is_down.md](../uncategorized/gemnasium_is_down.md)
* [../uncategorized/k8s-oncall-setup.md](../uncategorized/k8s-oncall-setup.md)
* [../uncategorized/manage-workers.md](../uncategorized/manage-workers.md)
* [../uncategorized/namespace-restore.md](../uncategorized/namespace-restore.md)
* [../uncategorized/pingdom.md](../uncategorized/pingdom.md)
* [../uncategorized/ruby-profiling.md](../uncategorized/ruby-profiling.md)
* [../uncategorized/shared-configurations.md](../uncategorized/shared-configurations.md)
* [../uncategorized/tracing-app-db-queries.md](../uncategorized/tracing-app-db-queries.md)
* [../web/static-repository-objects-caching.md](../web/static-repository-objects-caching.md)
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
