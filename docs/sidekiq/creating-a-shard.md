# Creating a Sidekiq Shard

This document will outline the necessary items when considering and building a
new Sidekiq shard.

## Considerations

* If the workers are being proposed to migrate to a new shard, we must ensure we
  have a plan of action to bring online the new shard, and move those workers
  off the old shard.
* If this is a new worker, we should perform a readiness review such that all
  engineers fully understand any implications
* Where possible, we should utilize the new queue routing mechanism to configure
  which workers run where
* We need to understand the workload of this new shard.  This means we need to
  know how the Sidekiq workers operate, their urgency level, the speed of job
  execution, etc.
* Much of the above will be found while working with the appropriate engineering
  team.  Our [documentation for Engineers for
  Sidekiq](https://docs.gitlab.com/ee/development/sidekiq_style_guide.html) is an
  excellent resource.

## Shard Characteristics

With the above information readily available we can then make a few
configuration choices:

* Picking a good obvious name of the shard that will be easy for other SREs to
  interpret the meaning of.
* Develop the appropriate Sidekiq worker configuration/selector query
  * This may be done via tagging our workers in the gitlab code base or via a
    highly sophisticated query.  We should avoid the latter
* How many Pods are necessary?
* If it is safe to utilize the Horizontal Pod Autoscaler, we can set our min
  and max pod values
  * If not, both values would be set to the same number
  * In [runbooks], we need to ensure that we note this shard is not subject to HPA
    saturation
* Attempt to choose the recommended CPU resource requests and Memory resource
  requests and limits

## To Create the Shard

* Modify the necessary items in [runbooks] to ensure the new shard will have it's
  own dedicated metrics.  Includes at least the following:
  * Add an entry in `shards` in [metrics-catalog/services/lib/sidekiq-helpers.libsonnet](https://gitlab.com/gitlab-com/runbooks/-/blob/master/metrics-catalog/services/lib/sidekiq-helpers.libsonnet)
  * Add a line to `services` in [dashboards/delivery/k8s_migration_overview.dashboard.jsonnet](https://gitlab.com/gitlab-com/runbooks/-/blob/master/dashboards/delivery/k8s_migration_overview.dashboard.jsonnet)
  * Here is [an example of how to add a new service shard](https://gitlab.com/gitlab-com/runbooks/-/merge_requests/4773/diffs).
* Modify the necessary items in [k8s-workloads/gitlab-helmfiles] such that logging is configured for the new shard.
  * Add a new section in [`lib/fluentd/logging-config.yaml`](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/tanka-deployments/-/blob/master/lib/fluentd/logging-config.yaml).
    * Here is [an example of how to add new logging configuration for a shard](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/tanka-deployments/-/merge_requests/440/diffs).
* If necessary create a new dedicated node pool
  * Add in terraform; currently in `environments/ENV/gke-regional.tf`; generally
      look for the other node pool definitions and duplicate/extend
* Modify [k8s-workloads/gitlab-com] adding the new sidekiq shard by adding a new section
  in [`gitlab.sidekiq.pods`](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab/values/gstg.yaml.gotmpl) with settings determined above
  * This prepares a place for the jobs to run but does not cause anything to be routed
    to them just yet. The  "queues" value is the list of queues (probably just one) that
    this shard will listen on (used in the next step).
    * Here is [an example of how to add a shard to a pod](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/merge_requests/1938/diffs#21a2743843174713a5692d172e40c08ce3a80383_505_505).
  * Also add a new entry in the [`auto-deploy-image-check` list](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/auto-deploy-image-check/gstg.json).
    * Here is [an example of how to add a auto-deploy image definition](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/merge_requests/1938/diffs#42cbaf891b66f60a3a592f89140cb1409607642f_61_61)
* Modify [`global.appConfig.sidekiq.routingRules`](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab/values/gstg.yaml.gotmpl) in [k8s-workloads/gitlab-com] to select
  the jobs you want (by name or other characteristics) in the first array value, and
  route them to the new queue (the second value in the array, being the name of the queue
  that the new shard is listening on)
  * When deployed, this is what will cause the jobs to be put into the named queue to be picked
    up by the new shard
    * Note: During the deploy, pods are slowly cycled over a period of time.  Due to this, there's a window of time for which the old and new shard will process the same work queue.

[k8s-workloads/gitlab-helmfiles]: https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-helmfiles
[k8s-workloads/gitlab-com]: https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com
[runbooks]: https://gitlab.com/gitlab-com/runbooks
