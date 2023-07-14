## Summary

This contains the relevant information for Disaster Recovery on GitLab.com as it relates to testing, validation, and current gaps that would prevent recovery.

[GitLab backups](https://about.gitlab.com/handbook/engineering/infrastructure/production/#backups) are designed to be tolerant for both zonal and regional outages by storing data in global (multi-region) object storage.

The [DR strategy](https://internal-handbook.gitlab.io/handbook/engineering/disaster-recovery/) for SaaS is based on our current backup strategy:

- [Postgresql backups using WAL-G](/docs/patroni/postgresql-backups-wale-walg.md)
- [GCP disk snapshots](/docs/disaster-recovery/gcp-snapshots.md)

Validation of restores happen in CI pipelines for both the Postgresql database and disk snapshots:

- [Postgresql restore testing](https://about.gitlab.com/handbook/engineering/infrastructure/database/disaster_recovery.html#restore-testing)
- [GitLab production snapshot restores](https://gitlab.com/gitlab-com/gl-infra/gitlab-restore/gitlab-production-snapshots)

## Recovery from a regional outage

GitLab.com is deployed in single region, [us-east1 in GCP](https://about.gitlab.com/handbook/engineering/infrastructure/production/architecture/), a regional outage is not currently in scope for Infrastructure disaster recovery validation.
In the [discovery issue for regional recovery](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/16250) we proposed what steps would be necessary to validate a regional recovery.

## Recovery from a zonal outage

The Reliability team validates the ability of recovery from a disaster that impacts a single availability zone.

### Zonal recovery checklist

The following steps should be completed in the following order in the unlikely scenario of a zonal outage on GitLab.com:

- [ ] Drain the corresponding zonal Kubernetes cluster using [`set-server-state`](/docs/frontend/haproxy.md#set-server-state) for the failed zone, and evaluate recovery of the other zonal clusters.
- [ ] Drain the canary environment with [GitLab Chatops](https://gitlab.com/gitlab-org/release/docs/blob/master/general/deploy/canary.md#how-to-stop-all-production-traffic-to-canary).
- [ ] Reconfigure the regional cluster to exclude the affected zone by setting `regional_cluster_zones` in Terraform to a list of zones that are not impacted ([example MR](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/merge_requests/4862)).
- [ ] Provision new database replicas in the affected zone.
- [ ] Provision new Gitaly servers from snapshot in the affected zone ([example MR](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/merge_requests/4863)).
- [ ] (optional) Provision new Redis VMs to add additional capacity.

**Note**: When the outage ends, it is not recommended to fail back or use the old infrastructure (if it is available) to avoid losing additional data.

#### Draining frontend traffic to divert traffic away from the affected zone

Frontend traffic is divided into multiple Kubernetes clusters by zone.
Services like `web`, `api`, `registry`, `pages` run in these clusters and do not require any data recovery since they are stateless.
In the case of a zonal outage, it is expected that checks will fail on the corresponding cluster and traffic will be routed to the unaffected zones which will trigger a scaling event.
To ensure that traffic does not reach the failed zone, it is recommended to divert traffic away from it using the [`set-server-state`](/docs/frontend/haproxy.md#set-server-state) HAProxy script.

#### Drain canary and reconfigure regional node pools to exclude the affected zone

The regional cluster hosts the [Canary infrastructure](https://about.gitlab.com/handbook/engineering/infrastructure/environments/canary-stage/) and is responsible all backend workloads including Sidekiq.
In the case of a zonal outage, the quickest way to prevent canary impact will be to [remove all traffic canary environment](https://gitlab.com/gitlab-org/release/docs/blob/master/general/deploy/canary.md#how-to-stop-all-production-traffic-to-canary).

To reconfigure the regional node pools, set `regional_cluster_zones` to the list of zones that are not affected by the zonal outage in Terraform for the regional cluster. For example, if there is an outage in `us-east1-d`:

[Example MR](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/merge_requests/4862)

```

  module "gitlab-gke" {
    source  = "ops.gitlab.net/gitlab-com/gke/google"
    ...
    regional_cluster_zones = ['us-east1-b', 'us-east1-c']
    ...
  }


```

#### Database recovery using snapshots and WAL-G

- Patroni clusters are deployed across multiple zones within the `us-east1` region. In the case of a zonal failure, it is possible that the primary will fail over to a new zone resulting in a short interruption of service.
- When a zone is lost, up to 1/3rd of the replica capacity will be removed resulting in a severe degradation of service. To recover, it will be necessary to provision a new replicas in one of the zones that are available.

To recover from a zonal outage, configure a new replica in Terraform with a zone override ([example](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/merge_requests/4603)).
The latest snapshot will be used automatically when the machine is provisioned.
As of `2022-12-01`, it is expected that it will take approximately [2 hours for the new replica to catch up to the primary](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/16792) using a disk snapshot that is 1 hour old.

To see how old the latest snapshots are for Postgres use the `glsh snapshots list` helper script:

```

$ glsh snapshots list -e gprd -z us-east1-d -t 'file'
Shows the most recent snapshot for each disk that matches the filter looking back 1 day, and provides the self link.

Fetching snapshot data, opts: env=gprd days=1 bucket_duration=hour zone=us-east1-d terraform=true filter=file..

╭─────────────────────────────────┬──────────────────────┬────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ disk                            │ timestamp            │ delta  │ selfLink                                                                                                                                 │
╞═════════════════════════════════╪══════════════════════╪════════╪══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
│ file-23-stor-gprd-data          │ 2023-04-06T14:02:53Z │ 01h60m │ https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-23-stor-gprd-d-us-east1-d-20230406140252-crc9hy33 │
│ file-26-stor-gprd-data          │ 2023-04-06T13:04:27Z │ 02h60m │ https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-26-stor-gprd-d-us-east1-d-20230406130426-pt2f6fwl │
...

```

**Note**: Snapshot age may be anywhere from minutes to 6 hours.

#### Gitaly recovery using disk snapshots

- The first 20 Gitaly VMs are deployed in `us-east1-c` due to a limitation of capacity when nodes were migrated from Azure to GCP. The remaining Gitaly servers alternate in all available zones in `us-east1`.
- When a zone is lost, all projects on the affected node will fail. There is no Gitaly data replication strategy on GitLab.com. In the case of a zone failure, there will be both a significant service interruption and data loss.

To recovery from a zonal outage, new Gitaly nodes can be provisioned from disk snaphots.
Snapshots are used to minimize data loss which will be anywhere from minutes to 6 hours depending on when the last snapshot was taken.

**Note**: Recovering a large number of Gitaly nodes into a single zone [may result in GCP capacity issues](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/16665#note_1159152178).
It will be necessary to spread the new Gitaly servers across all zones that are available.
For example, if there is a failure in `us-east1-b`, set `zones = ['us-east1-c', 'us-east1-d']`.

The `glsh snapshots list` helper script can be used to aid setting the latest snapshot for the failed Gitaly nodes.
For example, for a `us-east1-d` failure this will find the latest snapshots for all Gitaly nodes in that zone:

```
$ glsh snapshots list -e gprd -z us-east1-d -t 'file'
Searching for snapshots filter=file-\d+-stor env=gprd zone=us-east1-d project=gitlab-production
-
2023-01-23:08:37 (-2h37m)  file-23-stor-gprd-data  https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-23-stor-gprd-d-us-east1-d-20230123083755-xdbrvfee
2023-01-23:08:37 (-2h37m)  file-26-stor-gprd-data  https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-26-stor-gprd-d-us-east1-d-20230123083755-llnyzo3r
...

per_node_data_disk_snapshot = {
  1 = "https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-23-stor-gprd-d-us-east1-d-20230123083755-xdbrvfee" # file-23-stor-gprd-data
  2 = "https://www.googleapis.com/compute/v1/projects/gitlab-production/global/snapshots/file-26-stor-gprd-d-us-east1-d-20230123083755-llnyzo3r" # file-26-stor-gprd-data
  ...
}

```

Following this, the recovery requires two configuration changes:

1. `per_node_data_disk_snaphot` needs to be copied into a new `generic-stor` Terraform module that will be used for the restored Gitaly servers
([example MR](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/merge_requests/4863)).
2. [`git_data_dirs`](https://gitlab.com/gitlab-com/gl-infra/chef-repo/-/blob/f9154f7956376ac3eb801f51c2a505051d24595b/roles/gprd-base.json#L206) in the application's `gitlab.yml` will need to be updated so that the replacement nodes are used for the corresponding storages.

#### Redis

The majority of load from the GitLab application is on the Redis primary.
After a zone failure, we may want to start provisioning a new Redis node in each cluster to make up for lost capacity.
This can be done in Terraform with a zone override (setting `zone`) on the corresponding modules in Terraform.

One of the Redis clusters, "Registry Cache" is is Kubernetes. To remove the failed zone, reconfigure the regional cluster with `regional_cluster_zones` as explained in the Kubernetes section above.

**Warning**: Provisioning new Redis secondaries may [put additional load on the primary](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/16791#note_1229590289) and should be done with care and only if required to add capacity due to saturation issues on the remaining secondaries.

## Testing

### Test environment

For testing recovery of snapshots the [`dr-testing`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/tree/master/environments/dr-testing) environment can be used, this environment holds examples of different recovery types including Gitaly snapshot recovery.

### Denying network traffic to an availability zone

A helper script is available to help simulate a zonal outage by setting up firewall rules that prevent both ingress and egress traffic, currently this is available to run in our non-prod environments for the zones `us-east1-b` and `us-east1-d`.
The zone `us-east1-c` has [SPOFs like the deploy and console nodes](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/16251#us-east1-c-outage) so we should avoid running tests on this zone until they have been resolved in the [epic tracking critical work related to zonal failures](https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/800).

#### Setting firewall rules

**Note**: Run this script with care! All changes should go through [change management](https://about.gitlab.com/handbook/engineering/infrastructure/change-management/), even for non-prod environments!

```
$ ./zone-denier -h
Usage: ./zone-denier [-e <environment> (gstg|pre) -a <action> (deny|allow) -z <zone> -d]

  -e : Environment to target, must be a non-prod env
  -a : deny or allow traffic for the specified zone
  -z : availability zone to target
  -d (optional): run in dry-run mode

Examples:

  # Use the dry-run option to see what infra will be denied
  ./zone-denier -e pre -z us-east1-b -a deny -d

  # Deny both ingress and egress traffic in us-east1-b in PreProd
  ./zone-denier -e pre -z us-east1-b -a deny

  # Revert the deny to allow traffic
  ./zone-denier -e pre -z us-east1-b -a allow
```

The script is configured to exclude a static list of known SPOFs for each environment.
