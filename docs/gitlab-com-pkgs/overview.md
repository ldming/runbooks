## GCS Bucket for GitLab.com Omnibus Packages

### Overview

To reduce our dependency on packages.gitlab.com, we sync all Omnibus packages to a bucket in GCP that can be used by [Deployer](https://ops.gitlab.net/gitlab-com/gl-infra/deployer) for Omnibus installations.

### Buckets

There are two buckets used internally for storing Omnibus packages, `gitlab-com-pkgs-builds` and `gitlab-com-pkgs-release`:
- `gitlab-com-pkgs-builds`: Used for Omnibus branch builds or all builds that are not tagged in the Omnibus pipeline
- `gitlab-com-pkgs-release`: Used for Omnibus release builds, all builds that are tagged including auto-deploy and official self-managed releases

### Configuration

Configuration of the bucket is done in Terraform in the [`gitlab-com-pkgs`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/tree/master/environments/gitlab-com-pkgs) environment.

There is one service account `gitlab-com-pkgs-rw@gitlab-com-pkgs.iam.gserviceaccount.com` that has a key set as a CI variable `GITLAB_COM_PKGS_SA_FILE` in the omnibus-gitlab pipeline [CI variables on dev.gitlab.org](https://dev.gitlab.org/gitlab/omnibus-gitlab/-/settings/ci_cd).

For Deployer, access is granted using the service account [`terraform@<account>.iam.gserviceaccount.com`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/blob/1a2608a4574241f804728971f3458042110603e3/environments/gitlab-com-pkgs/main.tf#L41-47) which is the service account associated to all VMs that require the Omnibus package for installations.
Deployer first checks to see if a package is available in the `gitlab-com-pkgs-release` bucket, if it isn't, we fallback to packages.gitlab.com for installation.
The logic to use the bucket for installation can be disabled, by removing the `DEB_INSTALL_ENABLE` env variable in [CI variables for Deployer](https://ops.gitlab.net/gitlab-com/gl-infra/deployer/-/settings/ci_cd).

### Troubleshooting

#### Packages are not available for download

If a package is not available for download, it is likely that `rsync` job that copies packages to the bucket didn't run or failed in some way.
Check [omnibus jobs](https://dev.gitlab.org/gitlab/omnibus-gitlab/-/jobs) for the corresponding version tag.
The `rsync` happens in the `package` stage (e.g.: [rsync job](https://dev.gitlab.org/gitlab/omnibus-gitlab/-/jobs/14815874)).
Look for the `build-package-sync` section, there you should see the following in the job output:

```
GCS Sync: Activating service account
Activated service account credentials for: [gitlab-com-pkgs-rw@gitlab-com-pkgs.iam.gserviceaccount.com]
GCS Sync: Copying pkg/ contents to gitlab-com-pkgs
Building synchronization state...
...
```

#### Package cleanup

Because these buckets are only used internally, all packages older than 1 year will be deleted.
Additionally, we change the storage class for older packages which is [configured in Terraform](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/blob/ffbddb464f90f70c2dd43ddc8686c88ea08925ed/environments/gitlab-com-pkgs/buckets.tf).
