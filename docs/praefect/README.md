<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

# Praefect Service

* [Service Overview](https://dashboards.gitlab.net/d/praefect-main/praefect-overview)
* **Alerts**: <https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22praefect%22%2C%20tier%3D%22stor%22%7D>
* **Label**: gitlab-com/gl-infra/production~"Service::Praefect"

## Logging

* [system](https://log.gprd.gitlab.net/goto/769b1e96dc189470332cd7005dd6f878)

## Troubleshooting Pointers

* [Cloud SQL Troubleshooting](../cloud-sql/cloud-sql.md)
* [Upgrading the OS of Gitaly VMs](../gitaly/gitaly-os-upgrade.md)
* [Tuning and Modifying Alerts](../monitoring/alert_tuning.md)
* [../monitoring/apdex-alerts-guide.md](../monitoring/apdex-alerts-guide.md)
* [Diagnosis with Kibana](../onboarding/kibana-diagnosis.md)
* [Bypass Praefect](praefect-bypass.md)
* [Praefect Database](praefect-database.md)
* [Praefect error rate is too high](praefect-error-rate.md)
* [Add and remove file storages to praefect](praefect-file-storages.md)
* [Praefect Database User Password Rotation](praefect-password-rotation.md)
* [Praefect replication is lagging or has stopped](praefect-replication.md)
* [Praefect is down](praefect-startup.md)
* [Praefect has unavailable repositories](praefect-unavailable-repo.md)
* [Life of a Git Request](../tutorials/overview_life_of_a_git_request.md)
* [Gitaly version mismatch](../version/gitaly-version-mismatch.md)
<!-- END_MARKER -->

## How To

* [Add and remove file storages to praefect](praefect-file-storages.md)
* [Upgrade OS for praefect servers](https://gitlab.com/gitlab-com/gl-infra/ansible-workloads/praefect-ansible-scripts/-/blob/main/playbooks/praefect-os-upgrade/README.md#change-management-plan)

<!-- ## Summary -->

## Architecture

### File storage locations

Praefect itself is a transparent proxy with no local storage.

The praefect nodes that run praefect are named in the format praefect-XX-stor-ENV.

The file storage nodes that contain the data praefect reads is a normal gitaly node
and named in the format file-praefect-XX-stor-ENV. The server numbers correspond to the praefect node that uses it.

<!-- ## Performance -->

<!-- ## Scalability -->

<!-- ## Availability -->

<!-- ## Durability -->

<!-- ## Security/Compliance -->

<!-- ## Monitoring/Alerting -->

<!-- ## Links to further Documentation -->
