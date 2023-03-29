<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

# Frontend Service

* [Service Overview](https://dashboards.gitlab.net/d/frontend-main/frontend-overview)
* **Alerts**: <https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22frontend%22%2C%20tier%3D%22lb%22%7D>
* **Label**: gitlab-com/gl-infra/production~"Service::HAProxy"

## Logging

* [haproxy](https://console.cloud.google.com/logs/viewer?project=gitlab-production&organizationId=769164969568&interval=PT1H&resource=gce_instance%2Finstance_id%2F1812745190666049211&scrollTimestamp=2019-01-22T15:27:18.915253748Z&advancedFilter=resource.type%3D%22gce_instance%22%0Alabels.tag%3D%22haproxy%22)

## Troubleshooting Pointers

* [Chef Guidelines](../config_management/chef-guidelines.md)
* [Disk space alerts (production)](../customersdot/disk-space.md)
* [Frontend (HAProxy) Logging](haproxy-logging.md)
* [HAProxy management at GitLab](haproxy.md)
* [Deploying a change to gitlab.rb](../git/deploy-gitlab-rb-change.md)
* [GitLab Hosted CodeSandbox](../git/gitlab-hosted-codesandbox.md)
* [Gitaly latency is too high](../gitaly/gitaly-latency.md)
* [Tuning and Modifying Alerts](../monitoring/alert_tuning.md)
* [An impatient SRE's guide to deleting alerts](../monitoring/deleting-alerts.md)
* [Thanos Query and Stores](../monitoring/thanos-query.md)
* [Block specific pages domains through HAproxy](../pages/block-pages-domain.md)
* [../pgbouncer/service-pgbouncer.md](../pgbouncer/service-pgbouncer.md)
* [../registry/gitlab-registry.md](../registry/gitlab-registry.md)
* [Sentry is down and gives error 500](../sentry/sentry-is-down.md)
* [Life of a Web Request](../tutorials/overview_life_of_a_web_request.md)
* [Alert about SSL certificate expiration](../uncategorized/alert-for-ssl-certificate-expiration.md)
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
