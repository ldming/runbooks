# Google Cloud Snapshots

GCP [Scheduled Snapshots](https://cloud.google.com/compute/docs/disks/scheduled-snapshots)
automate the creation and the cleaning-up of disk snapshots.

- For all Gitaly storage nodes our default policy is to take a disk snapshot every 1 hour
- For database nodes a cron is used to take a disk snapshot every 1 hour
- For all other nodes that take scheduled snapshots we default to every 4 hours

The default retention for disk snapshots is 14 days.

GCP snapshots are necessary to meet our RPO/RTO targets for the Gitaly service and our RTO for Patroni since using them speeds up recovery.

## Manual Snapshots (initiated through the API)

For Patroni we take manual snapshots with cronjob that is configured in the Patroni Chef cookbook.
For more details see the [gcs-snapshot runbook for Patroni](/docs/patroni/gcs-snapshots.md)

## Scheduled Snapshots (configured through the [scheduled-snapshot](https://cloud.google.com/compute/docs/disks/scheduled-snapshots) feature)

### Troubleshooting

If there is an alert for `GCPScheduledSnapshots`, check to see if one of the nodes is missing a snapshot by checking the log metrics.
If it isn't clear why a snapshot is missing, check the Stackdriver in the GCP console for more details.

### Log metrics

- [Successful snapshots by disk in Production](https://thanos.gitlab.net/graph?g0.expr=sum(stackdriver_gce_disk_logging_googleapis_com_user_scheduled_snapshots%7Benv%3D%22gprd%22%7D)%20by%20(disk_name)&g0.tab=0&g0.stacked=0&g0.range_input=4h&g0.max_source_resolution=0s&g0.deduplicate=1&g0.partial_response=0&g0.store_matches=%5B%5D)
- [Snapshot errors by disk in Production](https://thanos.gitlab.net/graph?g0.expr=sum(stackdriver_gce_disk_logging_googleapis_com_user_scheduled_snapshots_errors%7Benv%3D%22gprd%22%7D)%20by%20(disk_name)&g0.tab=0&g0.stacked=0&g0.range_input=4h&g0.max_source_resolution=0s&g0.deduplicate=1&g0.partial_response=0&g0.store_matches=%5B%5D)

### Logs

- [Stackdriver logs for successful snapshots](https://cloudlogging.app.goo.gl/QZKFCd1Sc8dmm2UM6)
- [Stackdriver logs for snapshot errors](https://cloudlogging.app.goo.gl/Jgoop8sQdcaXD6bu9)

One possible for reason for snapshot errors is if we are at max quota for `Snapshots`. Check this by navigating to the [All Quotas](https://console.cloud.google.com/iam-admin/quotas?referrer=search&project=gitlab-production) page in the GCP console.
