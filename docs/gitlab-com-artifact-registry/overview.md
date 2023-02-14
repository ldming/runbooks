## Artifact Registry for GitLab.com

### Overview

The Artifact Registry for GitLab.com is used as an alternate private Docker Registry for K8s clusters for GitLab.com.
This Registry is used as a reliable alternative to the Registry registry.gitlab.com and dev.gitlab.org, which isolates from the availability issues on both of these environments.

### Configuration

Configuration of the Artifact Registry is done in Terraform in the [`gitlab-com-artifact-registry`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/tree/master/environments/gitlab-com-artifact-registry) environment.

There is one service account `artifact-registry-rw@gitlab-com-artifact-registry.iam.gserviceaccount.com` that has a key set as a CI variable `ARTIFACT_REGISTRY_SA_FILE` in the CNG pipeline [CI variables on dev.gitlab.org](https://dev.gitlab.org/gitlab/charts/components/images/-/settings/ci_cd).

For the Kubernetes clusters, access is granted with IAM at the project level for [PreProd, Ops, Staging and Production](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/blob/1a2608a4574241f804728971f3458042110603e3/environments/gitlab-com-artifact-registry/service-accounts.tf#L20-27).
This access allows all Kubernetes clusters to read from the Artirfact Registry without any secrets configuration.

**Note**: This does not allow you to use `docker` or `crictl` on the nodes to pull images, you must authenticate to access the registry from a shell or container.

### Troubleshooting

#### Images are not present in the Artifact Registry

If an image not present in the Artifact Registry it is most likely that either the image wasn't synchronized correctly from dev.gitlab.org, or that the image was deleted.

Images are synchronized from dev.gitlab.org in the [CNG pipeline](https://dev.gitlab.org/gitlab/charts/components/images/-/pipelines).

The `sync-images-artifact-registry` job runs at the end of the CNG pipeline for all tagged builds on dev.gitlab.org, check the job output for the appropriate tag to see if the sync was done properly (e.g.: [sync job](https://dev.gitlab.org/gitlab/charts/components/images/-/jobs/14796448))

#### Accessing the Artifact Registry

See the [docs](https://cloud.google.com/artifact-registry/docs/docker/authentication) for different ways of authenticating to the Artifact Registry.

The easiest way to authenticate and access images is authenticating using your own account.

```
gcloud auth login # if necessary

gcloud auth configure-docker us-east1-docker.pkg.dev
docker pull us-east1-docker.pkg.dev/gitlab-com-artifact-registry/images/gitlab-container-registry:v3.64.0-gitlab
```

#### Image cleanup

[gcr-cleaner](https://github.com/GoogleCloudPlatform/gcr-cleaner) is running as cron-job in the Ops Kubernetes environment.
It is configured to keep the latest 300 images and is configured in [gitlab-helmfiles](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-helmfiles/-/tree/master/releases/gcr-cleaner).
