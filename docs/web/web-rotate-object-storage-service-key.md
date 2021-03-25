# Web Rotate Object Storage Service Key
This runbook outlines the process to rotate the GCP service account key used
by Gitlab web/api nodes/pods to talk to GCS for artifact storage.

The name of the service account used is `gitlab-object-storage@gitlab-${env}.iam.gserviceaccount.com`

* [ ] Generate a new API Key
At the moment this needs to be done manually (outside of terraform) using the following
command.

```
gcloud --project gitlab-${env} iam service-accounts keys create gcs-creds-new.json --iam-account=gitlab-object-storage@${project}.iam.gserviceaccount.com
```

* [ ] Base64 encode the service-account key file as it needs to be stored in the
chef data bag

```
base64 gcs-creds-new.json > gcs-creds-new-encoded.json
```

* [ ] Upload the new service account key in base64 encoded format into the chef
data bag in GCS using the `gkms-update.sh` tool in `chef-repo`  

```
# First confirm you see the old key for the right service account using
cd chef-repo
./bin/gkms-vault-cat gitlab-omnibus-secrets pre | jq -r '.["gitlab-server"]["google-creds"].json_base64' | base64 -d

# Copy of the contents of gcs-creds-new-encoded.json into your clipboard and edit
# vault to replace gitlab-server.google-creds.json_base64
./bin/gkms-vault-edit gitlab-omnibus-secrets pre

# Confirm that the new key is now in the correct place
./bin/gkms-vault-cat gitlab-omnibus-secrets pre | jq -r '.["gitlab-server"]["google-creds"].json_base64' | base64 -d
```

* [ ] Wait for chef to roll out the new credentials file over the next 30 minutes. Note that chef changing this file
**will not** cause any services to be restarted, so it is safe to do without draining nodes

* [ ] Wait for a regular deploy to happen which will restart all web/api nodes.
This will naturally pick up the new GCS key to use

* [ ] Open an MR against https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com
With an addition to the file https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/CHEF_CONFIG_UPDATE
noting a new GCS key to be synced from chef. e.g.

```
2021-03-25

* GPRD - re-sync GCS service account key from chef

```

Merge the MR and make sure the merged pipeline succeeds and appl gprd apply jobs
have been manually run

* [ ] Go to the GCP console for the service account e.g. https://console.cloud.google.com/iam-admin/serviceaccounts/
(make sure you are in the correct project, and find the correct service account)
then click on the metrics tab at the top. Look at the Graph at the bottom titled
'Authentication traffic per key' and make sure the traffic for the key you are
rotating out goes down to zero consistently for 24 hours and traffic for the new
key you generated is going up

* [ ] Remove the old service account key
Once you have confirmed that the old service account key is no longer in use,
you are safe to remove it using either the CLI or webui (make sure you are removing
the correct one!)
