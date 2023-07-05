# How to Use Vault for Secrets Management in Infrastructure

[[_TOC_]]

## Accessing Vault

### Web UI

* Go to <https://vault.gitlab.net/>
* Select `oidc`, leave `Role` empty and click `Sign in with Okta`
* Don't forget to allow pop-ups for this site in your browser.
* You should now be logged in

Your session token is valid for 24 hours, renewable for up to 7 days and automatically renewed when you use the Web UI before the 24 hours TTL runs out.

Members of the Infrastructure team can also login with admin privileges by entering `admin` in the `Role` input. The admin session token is valid for a maximum of 1 hour (non renewable), as its usage should be limited to troubleshooting.

#### Authentication alternative

If the OIDC authentication fails for any reason, the CLI token (using the method below) can be reused to login in the UI.

* Execute `vault token lookup`

```
Key                            Value
---                            -----
...
id                             <mytoken>
...
ttl                            21h39m34s
```

* Copy the `id` key value, which is the session token
* In the UI, select `Other`, Method `Token`, paste the above token and `Sign In`

### CLI

#### Installing the client

The Hashicorp Vault client is available for most OSes and package managers, see <https://developer.hashicorp.com/vault/downloads> for more information.

The non-official client [`safe`](https://github.com/starkandwayne/safe) is also more user-friendly and convenient for key/value secrets operations, however you will still need the official client above to be able to login. See the [releases](https://github.com/starkandwayne/safe/releases) for pre-built binaries, and MacOS users will want to read <https://github.com/starkandwayne/safe#attention-homebrew-users> for installing via Homebrew.

#### Access

*Access via Teleport is not implemented yet at the time of this writing (see <https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/15898>) but will eventually be the preferred method for accessing Vault from CLI.*

```shell
eval "$(glsh vault init -)"
glsh vault proxy

# In a new shell
eval "$(glsh vault init -)"
export VAULT_PROXY_ADDR="socks5://localhost:18200"
glsh vault login
```

There are alternative ways for you to connect as well if `glsh` doesn't work for you:

<details>
<summary> SOCKS5 proxy via SSH </summary>

```shell
# In a separate shell session
ssh -D 18200 bastion-01-inf-ops.c.gitlab-ops.internal
# In your first session
export VAULT_ADDR=https://vault.ops.gke.gitlab.net
export VAULT_PROXY_ADDR=socks5://localhost:18200
# If using safe:
alias safe='HTTPS_PROXY="${VAULT_PROXY_ADDR}" safe'
safe target ${VAULT_ADDR} ops
```

</details>

<details>
<summary> port-forwarding via `kubectl` </summary>

```shell
# In a separate shell session
kubectl -n vault port-forward svc/vault-active 8200
# In your first session
export VAULT_ADDR=https://localhost:8200
export VAULT_TLS_SERVER_NAME=vault.ops.gke.gitlab.net
# If using safe:
safe target ${VAULT_ADDR} ops
```

</details>

<details>
<summary> Users of fish shell can use this function </summary>

```shell
# Copy to ~/.config/fish/functions/vault-proxy.fish
function vault-proxy -d 'Set up a proxy to run vault commands'
 set -f BASTION_HOST "lb-bastion.ops.gitlab.com"
 set -Ux VAULT_ADDR "https://vault.ops.gke.gitlab.net"
 set -f VAULT_PROXY_PORT "18200"
 set -Ux VAULT_PROXY_ADDR "socks5://localhost:$VAULT_PROXY_PORT"
 set msg "[vault] Starting SOCKS5 proxy on $BASTION_HOST via $VAULT_PROXY_ADDR"
 if test -n "$TMUX"
  tmux split-pane -d -v -l 3 "echo \"$msg\"; ssh -D \"$VAULT_PROXY_PORT\" \"$BASTION_HOST\" 'echo \"Connected! Press Enter to disconnect.\"; read disconnect'; set -e VAULT_PROXY_ADDR VAULT_ADDR; echo Disconnected ; sleep 3"
 else
  echo >&2 "Open a new shell before using Vault:"
  echo >&2 "$msg"
  ssh -D "$VAULT_PROXY_PORT" "$BASTION_HOST" 'echo "Connected! Press Enter to disconnect."; read disconnect' >&2
  set -e VAULT_PROXY_ADDR VAULT_ADDR
 end
end
```

</details>

Then you can login via the OIDC method:

```shell
vault login -method oidc
```

If you are using `safe`, you will also have to run the following to login with your new token created above:

```shell
vault print token | safe auth token
```

Members of the Infrastructure team can also login with admin privileges (token TTL max of 1 hour, non renewable) with the following:

```shell
vault login -method oidc role=admin
```

After logging in, your Vault token is stored in `~/.vault-token` by default. Alternatively it can be set with the environment variable `VAULT_TOKEN`.

Your token is valid for 24 hours, renewable for up to 7 days using `vault token renew` before the 24 hours TTL runs out.

## Secrets Management

### Secrets Engines

There are currently 4 [KV Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2) configured in Vault:

* `ci`: secrets accessed from GitLab CI
* `k8s`: secrets accessed by the [External Secrets operator](https://external-secrets.io/) from the GKE clusters
* `shared`: secrets that can be accessed from both GitLab CI and the External Secrets operator on a case by case basis
* `chef`: secrets accessed by Chef Client on VM instances.

The structure of the `ci`, `k8s` and `chef` secrets is described in their respective sections below.

The `shared` secrets don't have a well-defined structure at the time of this writing.

We are using the `kv` secret store version 2, which has secret versioning enabled. This means that when updating a secret, any previous secret versions can be retrieved by its version number until it is deleted (⚠️  deleting the last version does not delete the previous ones), and they can be undeleted as well. On the other hand, *destroying* a secret will effectively delete it permanently.

See [the Vault documentation about KV version 2](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2#usage) to learn how to create/read/update/delete secrets and manage their versions.

There is also another secret engine named `cubbyhole`, this is a temporary secret engine scoped to a token, and destroyed when the token expires. It is especially useful for response wrapping, see the Vault documentation about [Cubbyhole](https://developer.hashicorp.com/vault/docs/secrets/cubbyhole) and [response wrapping](https://developer.hashicorp.com/vault/docs/concepts/response-wrapping) for more information.

### GitLab CI Secrets

#### Structure

CI secrets are available under the following paths:

* `ci/<gitlab-instance>/<project-full-path>/<environment>/...`: to be used for secrets scoped to an environment (when the `environment` attribute is set for a CI job), which are only accessible for this particular environment and none other;
* `ci/<gitlab-instance>/<project-full-path>/shared/...`: to be used for secrets shared for all environments or when no environments are defined in the pipeline;
* `ci/<gitlab-instance>/<project-full-path>/protected/<environment>/...`: to be used for protected secrets scoped to an environment, this path is only readable from CI jobs running for protected branches/environments;
* `ci/<gitlab-instance>/<project-full-path>/protected/shared/...`: to be used for protected secrets shared for all environments or when no environments are defined in the pipeline, this path is only readable from CI jobs running for protected branches/environments.
* `ci/<gitlab-instance>/<project-full-path>/<environment>/outputs/...`: to be used for *writing* secrets to Vault scoped to an environment (primarily from Terraform but it can be from other tools), this path is only readable/writable from CI jobs running for protected branches/environments;
* `ci/<gitlab-instance>/<project-full-path>/outputs/...`: to be used for *writing* secrets to Vault (primarily from Terraform but it can be from other tools), this path is only readable/writable by CI jobs running from protected branches;

Additional, a Transit key is created under `transit/ci/<gitlab-instance>-<project-full-path>`, which can be used for encryption, decryption and signing of CI artifacts and anything else. Decryption and signing is restricted to the project, while encryption and signature verification is allowed for all, this can be useful for sharing artifacts securely between projects. See [the Vault documentation about the Transit secrets engine](https://developer.hashicorp.com/vault/docs/secrets/transit) to learn more about it.

_Terminology:_

* `gitlab instance`: the GitLab instance using Vault secrets in CI
  * `gitlab-com`: our primary `GitLab.com` SaaS environment
  * `ops-gitlab-net`: our ops instance `ops.gitlab.net`
* `project-full-path`: the full path of a project hosted on a GitLab instance, slashes are replaced with underscores in the transit key, role and policy names
* `environment`: the short name of the environment the CI job fetching the secrets is running for: `gprd`, `gstg`, `ops`, ...

Examples:

* `ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/gprd/foo` is a secret named `foo` for the environment `gprd` only from the project `gitlab-com/gl-infra/my-project` on `ops.gitlab.net`
* `ci/gitlab-com/gitlab-com/gl-infra/some-group/my-other-project/shared/bar` is a secret named `bar` for all environments from the project `gitlab-com/gl-infra/some-group/my-other-project` on `gitlab.com`
* `ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/outputs/qux` is a secret named `qux` created by Terraform in a CI job from a protected branch or environment from the project `gitlab-com/gl-infra/my-project` on `ops.gitlab.net`

#### Authorizing a GitLab Project

To enable a GitLab project to access Vault from CI, add the following to its project definition in [`infra-mgmt`](https://gitlab.com/gitlab-com/gl-infra/infra-mgmt):

```terraform
module "project_my-project" {
  ...

  vault = {
    enabled   = true
    auth_path = local.vault_auth_path
  }
}
```

⚠️ Note: if your project doesn't exist yet in `infra-mgmt`, you will need to add and import it (documentation for this to be added later at the time of this writing).

There are additional attributes that you can set to allow access to more secrets paths and policies, see [the project module documentation](https://gitlab.com/gitlab-com/gl-infra/infra-mgmt/-/tree/main/modules/project#input_vault) to learn more about those.

Terraform will then create 2 JWT roles in Vault named `<project-full-path>` for read-only access and `<project-full-path>-rw` for read/write access from protected branches/environments, along with their associated policies:

```
❯ vault read auth/ops-gitlab-net/role/gitlab-com_gl-infra_k8s-workloads_tanka-deployments
Key                        Value
---                        -----
[...]
bound_claims               map[project_id:[401]]
claim_mappings             map[environment:environment]
token_policies             [ops-gitlab-net-project-gitlab-com_gl-infra_k8s-workloads_tanka-deployments]
[...]
❯ vault read auth/ops-gitlab-net/role/gitlab-com_gl-infra_k8s-workloads_tanka-deployments-rw
Key                        Value
---                        -----
[...]
bound_claims               map[project_id:[401] ref_protected:[true]]
claim_mappings             map[environment:environment]
token_policies             [ops-gitlab-net-project-gitlab-com_gl-infra_k8s-workloads_tanka-deployments-rw ops-gitlab-net-project-gitlab-com_gl-infra_k8s-workloads_tanka-deployments]
[...]
```

It will also create the following CI variables in the project:

* `VAULT_AUTH_ROLE:` read-only role name, and read-write role name for each defined protected environment if any
* `VAULT_SECRETS_PATH`: the secrets base path (`ci/<gitlab-instance>/<project-full-path>`)
* `VAULT_TRANSIT_KEY_NAME`: the transit key name relative to `transit/ci`

The following variables are also set at the group level:

* `VAULT_ADDR` / `VAULT_SERVER_URL`: `https://vault.ops.gke.gitlab.net`
* `VAULT_AUTH_PATH`: authentication method path relative to `auth/`, for instance `gitlab-com` or `ops-gitlab-net`
* `VAULT_TRANSIT_PATH`: `transit/ci`

#### Using Vault secrets in CI

Then in a CI job, a secret can be configured like so:

```yaml
my-job:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.gitlab.net
  secrets:
    TOKEN:
      file: false
      vault: ${VAULT_SECRETS_PATH}/${ENVIRONMENT}/some-service/token@ci
```

This will set the variable `TOKEN` to the value of the key `token` from the secret `some-service` for the current environment.

Note that the name of the KV mount is set at the end of the path with `@ci` here, and `token` is a key from the secret and not part of the actual path of the secret.

A secret can also be stored in a file instead by setting `file: true` like so:

```yaml
my-other-job:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.gitlab.net
  secrets:
    GOOGLE_APPLICATION_CREDENTIALS:
      file: true
      vault: ${VAULT_SECRETS_PATH}/${ENVIRONMENT}/service-account/key@ci
```

Something like this should appear at the beginning of the CI job output:

```
> Resolving secrets
  Resolving secret "GOOGLE_APPLICATION_CREDENTIALS"...
  Using "vault" secret resolver...
```

See [Use Vault secrets in a CI job](https://docs.gitlab.com/ee/ci/secrets/#use-vault-secrets-in-a-ci-job) and [the `.gitlab-ci.yml` reference](https://docs.gitlab.com/ee/ci/yaml/index.html#secretsvault) for more information.

#### Using Vault secrets in Terraform

This Vault provider configuration allows using Vault in Terraform both from CI and locally from one's workstation [when already logged in](#access):

```terraform
// providers.tf

provider "vault" {
  // address = "${VAULT_ADDR}"

  dynamic "auth_login_jwt" {
    for_each = var.vault_jwt != "" && var.vault_auth_path != "" ? [var.vault_auth_path] : []

    content {
      mount = var.vault_auth_path
      role  = var.vault_auth_role
      jwt   = var.vault_jwt
    }
  }
}

// variables.tf

variable "vault_jwt" {
  type        = string
  description = "Vault CI JWT token"
  default     = ""
  sensitive   = true
}
variable "vault_auth_path" {
  type        = string
  description = "Vault authentication path"
  default     = ""
}
variable "vault_auth_role" {
  type        = string
  description = "Vault authentication role"
  default     = ""
}
variable "vault_secrets_path" {
  type        = string
  description = "Vault secrets path"
  default     = "ops-gitlab-net/gitlab-com/gl-infra/my-project/some-env"
}

// versions.tf

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.9.0"
    }
  }
}
```

And the following has to be added on `.gitlab-ci.yml` to provide the Terraform variables above while also enabling [CI secrets](#using-vault-secrets-in-ci):

```yaml
variables:
  TF_VAR_vault_jwt: ${VAULT_ID_TOKEN}
  TF_VAR_vault_auth_path: ${VAULT_AUTH_PATH}
  TF_VAR_vault_auth_role: ${VAULT_AUTH_ROLE}
  TF_VAR_vault_auth_secrets_path: ${VAULT_SECRETS_PATH}/${CI_ENVIRONMENT_NAME}

# Define an ID token in each Terraform job
my_terraform_job:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.gitlab.net
```

Then a secret can be fetched using the [`vault_kv_secret_v2` data source](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2), and its content can be retrieved from the [`data`](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2#data) attribute:

```terraform
data "vault_kv_secret_v2" "some-secret" {
  mount = "ci"
  name  = "${var.vault_secrets_path}/some-secret"
}

resource "google_some_service" "foo" {
  token = data.vault_kv_secret_v2.some-secret.data.token
}
```

Terraform can also write a secret to Vault using the `vault_kv_secret_v2` resource:

```terraform
resource "vault_kv_secret_v2" "database-credentials" {
  mount     = "ci"
  name      = "${var.vault_secrets_path}/outputs/database"
  data_json = jsonencode({
      username = google_sql_user.foo.name
      password = google_sql_user.foo.password
  })
}
```

⚠️ There is [known issue](https://gitlab.com/gitlab-com/gl-infra/reliability/-/issues/17010) where the Vault token generated by the Vault provider expires sooner than expected, often causing expired token errors when the Terraform apply job is delayed by a few minutes after the Terraform plan job. As a workaround, the provider configuration can be left empty:

```terraform
provider "vault" {}
```

And the Vault token can instead be generated in the job script just before running Terraform:

```sh
export VAULT_TOKEN="$(vault write -field=token "auth/${VAULT_AUTH_PATH}/login" role="${TF_VAULT_AUTH_ROLE}" jwt="${VAULT_ID_TOKEN}")"
```

See the [Vault provider documentation](https://registry.terraform.io/providers/hashicorp/vault/latest/docs) for more information.

### Rotating CI secrets (with Terraform)

By default, the `vault_kv_secret_v2` data source will pull the latest version of a secret, but it can instead pull a specific one by setting the attribute `version`:

```terraform
data "vault_kv_secret_v2" "some-secret" {
  mount   = "ci"
  name    = "${var.vault_secrets_path}/some-secret"
  version = 3
}
```

This allows rotating secrets safely in a controlled manner:

* update the secret in place in Vault, creating a new version:

  ```shell
  vault kv patch ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/pre/some-secret foo=bar
  ```

* this will display the version number for the new secret, but it can also be retrieved it with:

  ```shell
  vault kv metadata get ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/pre/some-secret
  ```

* bump the version in Terraform:

  ```terraform
  data "vault_kv_secret_v2" "some-secret" {
    mount   = "ci"
    name    = "${var.vault_secrets_path}/some-secret"
    version = 4
  }
  ```

* commit, open a merge request, merge and apply
* if for any reason the previous version of the secret needs to be deleted:

  ```
  vault kv delete -versions 3 ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/pre/some-secret
  ```

* if it needs to be destroyed (unrecoverable):

  ```
  vault kv destroy -versions 3 ci/ops-gitlab-net/gitlab-com/gl-infra/my-project/pre/some-secret
  ```

### External Secrets in Kubernetes

#### Structure

Kubernetes secrets are available under the following paths:

* `k8s/<cluster>/<namespace>/...`: to be used for secrets scoped to a namespace in a particular cluster;
* `k8s/env/<environment>/ns/<namespace>/...`: to be used for secrets shared for the whole the environment, this is useful in the `gstg` and `gprd` where there are multiple clusters using the same secrets.

_Terminology:_

* `cluster`: the name of the GKE cluster the External Secrets are created in
* `environment`: the short name of the environment the Kubernetes clusters fetching the secrets runs in: `gprd`, `gstg`, `ops`, ...
* `namespace`: the namespace the External Secrets are created in

Examples:

* `k8s/ops-gitlab-gke/vault/oidc` is a secret named `oidc` for the namespace `vault` in the cluster `ops-gitlab-gke`
* `k8s/env/gprd/ns/gitlab/redis/foo` is a secret named `redis/foo` for the namespace `gitlab` in the environment `gprd`

#### Using the External Secrets operator within a Kubernetes deployment

The External Secrets operator provides 2 Kubernetes objects:

* a [SecretStore](https://external-secrets.io/v0.5.9/api-secretstore/) specifying the location of the Vault server, the role to authenticate as, the service account to authenticate with, and the targeted secret engine to use. For a given namespace there should be one Secret Store per secret engine.
* an [ExternalSecret](https://external-secrets.io/v0.5.9/api-externalsecret/) creating a Secret object from one or several Vault secrets using a given SecretStore. There can be as many External Secrets as needed, one for each Secret to provision.

The SecretStore uses a dedicated Service Account so that regular workloads are not able to access Vault by themselves, and it is scoped to the namespace it is deployed into.

Before using the operator, a role has to be created in Vault for the namespace the secrets will be provisioned into. This is done in [`environments/vault-production/kubernetes.tf`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/blob/master/environments/vault-production/kubernetes.tf):

```terraform
locals {
  kubernetes_common_roles = {
    [...]

    my-app = {
      service_accounts = ["my-app-secrets"]
      namespaces       = ["my-app"]
    }
  }

  kubernetes_clusters = {
    [...]

    pre-gitlab-gke = {
      environment = "pre"
      roles       = {
        my-app = local.kubernetes_common_roles.my-app
      }
    }

    [...]
  }
}
```

Terraform will then create the role for the given cluster along with its associated policies.

Then a Secret Store can be created with the following:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-secrets
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: my-app
spec:
  provider:
    vault:
      auth:
        kubernetes:
          mountPath: kubernetes/pre-gitlab-gke
          role: my-app
          serviceAccountRef:
            name: my-app-secrets
      path: k8s
      server: https://vault.ops.gke.gitlab.net
      version: v2
```

And finally a basic External Secret can be created with the following:

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: some-secret-v1
spec:
  secretStoreRef:
    kind: SecretStore
    name: my-app
  refreshInterval: 0
  target:
    creationPolicy: Owner
    deletionPolicy: Delete
    name: some-secret-v1
    template:
      type: Opaque
  data:
  - remoteRef:
      key: pre-gitlab-gke/my-namespace/some-secret
      property: username
      version: "1"
    secretKey: username
  - remoteRef:
      key: pre-gitlab-gke/my-namespace/some-secret
      property: password
      version: "1"
    secretKey: password
```

See [the External Secrets documentation](https://external-secrets.io/v0.5.9/api-externalsecret/) for more additional information on the ExternalSecret specification, secret data templating and more.

To help with this, some helpers exist in the `gitlab-helmfiles` and `tanka-deployments` repositories.

##### `gitlab-helmfiles` and `gitlab-com`

The chart [`vault-secrets`](https://gitlab.com/gitlab-com/gl-infra/charts/-/tree/main/gitlab/vault-secrets) can be used to create the Secrets Store(s) and External Secrets together:

```yaml
# helmfile.yaml


repositories:
  - name: registry-ops-gl
    url: registry.ops.gitlab.net
    oci: true

releases:
  - name: my-app-secrets
    chart: registry-ops-gl/gitlab-com/gl-infra/charts/vault-secrets
    version: 1.1.0
    namespace: my-app
    installed: {{ .Values | getOrNil "my-app.installed" | default false }}
    values:
      - secrets-values.yaml.gotmpl
```

```yaml
# secrets-values.yaml.gotmpl

---
clusterName: {{ .Environment.Values.cluster }}

externalSecrets:
  some-secret-v1:
    refreshInterval: 0
    secretStoreName: my-app-secrets
    target:
      creationPolicy: Owner
      deletionPolicy: Delete
    data:
      - remoteRef:
          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
          property: username
          version: "1"
        secretKey: username
      - remoteRef:
          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
          property: password
          version: "1"
        secretKey: password

secretStores:
  - name: my-app-secrets
    role: my-app
    # path: k8s
  - name: my-app-shared-secrets
    role: my-app
    path: shared

serviceAccount:
  name: my-app-secrets
```

##### `tanka-deployments`

The Secret Store(s) are handled separately for Tanka.

To enable the SecretStore, `externalSecretsRole` has to be set for the environment. Also additional secrets engine can be specified with `secretStorePaths` (defaulting to `k8s`):

```jsonnet
{
  envsData:: {
    pre: {
      namespaceName:: namespaceName,
      externalSecretsRole:: 'my-app',
      // secretStorePaths:: ['k8s', 'shared'],
      ...
    },
  }
}
```

Then the External Secrets can be created with the following:

```jsonnet
local clusters = import 'gitlab/clusters.libsonnet';
local externalSecrets = import 'gitlab/external-secrets.libsonnet';

{
  secrets:: {
    new(env, namespace, appName, labels={}):: {
      local secretKey(name) = externalSecrets.k8sAppSecretKey(clusters[env].clusterName, namespace, appName, name),

      some_secret:
        externalSecrets.externalSecret(
          'some-secret',
          appName,
          namespace,
          labels=labels,
          clusters[env].clusterName,
          data={
            username: {
              key: secretKey('some-secret'),
              property: 'username',
              version: 1,
            },
            password: {
              key: secretKey('some-secret'),
              property: 'password',
              version: 1,
            },
          },
        ),
    },
  },
}
```

See [`lib/gitlab/external-secrets.libsonnet`](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/tanka-deployments/-/blob/master/lib/gitlab/external-secrets.libsonnet) for the function definitions.

### Rotating Kubernetes secrets

For a safe and controlled rollout and to ensure that the pods are rotated each time a secret is updated, the secret's name should preferably be prefixed with the version, for example `my-secret-v1`, incrementing the version with each update.

The following instructions are for rotating secrets managed in the `gitlab-helmfiles` repository based on the examples from the [section above](#gitlab-helmfiles-and-gitlab-com), but the same principle can be followed in the other repositories:

* update the secret in place in Vault, creating a new version:

  ```shell
  vault kv patch k8s/my-cluster/my-app/some-secret password=foobar
  ```

* this will display the version number for the new secret, but it can also be retrieved it with:

  ```shell
  vault kv metadata get k8s/my-cluster/my-app/some-secret
  ```

* duplicate the external secret definition, bumping the version number in the name and the specification:

  ```diff
   # secrets-values.yaml.gotmpl

   externalSecrets:
     some-secret-v1:
       refreshInterval: 0
       secretStoreName: my-app-secrets
       target:
         creationPolicy: Owner
         deletionPolicy: Delete
       data:
         - remoteRef:
             key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
             property: username
             version: "1"
           secretKey: username
         - remoteRef:
             key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
             property: password
             version: "1"
           secretKey: password
  +  some-secret-v2:
  +    refreshInterval: 0
  +    secretStoreName: my-app-secrets
  +    target:
  +      creationPolicy: Owner
  +      deletionPolicy: Delete
  +    data:
  +      - remoteRef:
  +          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  +          property: username
  +          version: "2"
  +        secretKey: username
  +      - remoteRef:
  +          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  +          property: password
  +          version: "2"
  +        secretKey: password
  ```

* commit, open a merge request, merge and deploy
* ensure that the new secret has been created:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get externalsecrets
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v2
  ```

* ensure that the new secret data matches its value in Vault:

  ```shell
  vault kv get -format json -field data k8s/my-cluster/my-app/some-secret | jq -c
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v2 -o jsonpath='{.data}' | jq '.[] |= @base64d'
  ```

* update any reference to this secret in the rest of the application deployment configuration to target the new name `some-secret-v2`
* commit, open a merge request, merge and deploy

* ensure that the pods have been rotated and are all using the new secret

  ```shell
  kubectl --context my-cluster --namespace my-namespace get deployments
  kubectl --context my-cluster --namespace my-namespace get pods
  kubectl --context my-cluster --namespace my-namespace describe pod my-app-1ab2c3d4f5-g6h7i
  ```

* remove the old external secret definition:

  ```diff
   # secrets-values.yaml.gotmpl

   externalSecrets:
  -  some-secret-v1:
  -    refreshInterval: 0
  -    secretStoreName: my-app-secrets
  -    target:
  -      creationPolicy: Owner
  -      deletionPolicy: Delete
  -    data:
  -      - remoteRef:
  -          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  -          property: username
  -          version: "1"
  -        secretKey: username
  -      - remoteRef:
  -          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  -          property: password
  -          version: "1"
  -        secretKey: password
     some-secret-v2:
       refreshInterval: 0
       secretStoreName: my-app-secrets
       target:
         creationPolicy: Owner
         deletionPolicy: Delete
       data:
         - remoteRef:
             key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
             property: username
             version: "2"
           secretKey: username
         - remoteRef:
             key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
             property: password
             version: "2"
           secretKey: password
  ```

* commit, open a merge request, merge and deploy
* ensure that the old secret has been deleted:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v1
  ```

### Migrating existing Kubernetes secrets to External Secrets

An existing Kubernetes secret deployed by an older method (helmfile+GKMS, manual, ...) needs to be stored in Vault and be deployed with External Secrets.

⚠️ Consider opening a [Change Request](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/new?issuable_template=change_management) with the instructions below when migrating a secret in production.

The following instructions are for migrating a secrets managed in the `gitlab-helmfiles` repository based on the examples from the [section above](#gitlab-helmfiles-and-gitlab-com), but the same principle can be followed in the other repositories:

* fetch the existing secret value from Kubernetes and store it in to Vault:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v1 -o jsonpath='{.data.password}' \
    | base64 -d \
    | vault kv put k8s/my-cluster/my-app/some-secret password=-
  ```

* this will display the version number for the new secret, but it can also be retrieved it with:

  ```shell
  vault kv metadata get k8s/my-cluster/my-app/some-secret
  ```

* duplicate the external secret definition, bumping the version number in the name and the specification:

  ```diff
   # secrets-values.yaml.gotmpl

   externalSecrets:
  +  some-secret-v2:
  +    refreshInterval: 0
  +    secretStoreName: my-app-secrets
  +    target:
  +      creationPolicy: Owner
  +      deletionPolicy: Delete
  +    data:
  +      - remoteRef:
  +          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  +          property: password
  +          version: "2"
  +        secretKey: password
  ```

* commit, open a merge request, merge and deploy
* ensure that the new secret has been created:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get externalsecrets
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v2
  ```

* ensure that the new secret data matches its value in Vault:

  ```shell
  vault kv get -format json -field data k8s/my-cluster/my-app/some-secret
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v2 -o jsonpath='{.data}' | jq '.[] |= @base64d'
  ```

* ensure that the new secret data matches the old one:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v1 -o jsonpath='{.data}' | jq '.[] |= @base64d' | sha256sum
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v2 -o jsonpath='{.data}' | jq '.[] |= @base64d' | sha256sum
  ```

* if this is a production secret, post the checksum results above as proof in the associated issue or merge request

* update any reference to this secret in the rest of the application deployment configuration to target the new name `some-secret-v2`
* commit, open a merge request, merge and deploy

* ensure that the pods have been rotated and are all using the new secret

  ```shell
  kubectl --context my-cluster --namespace my-namespace get deployments
  kubectl --context my-cluster --namespace my-namespace get pods
  kubectl --context my-cluster --namespace my-namespace describe pod my-app-1ab2c3d4f5-g6h7i
  ```

* remove the old external secret definition:

  ```diff
   # secrets-values.yaml.gotmpl

   externalSecrets:
  -  some-secret-v1:
  -    refreshInterval: 0
  -    secretStoreName: my-app-secrets
  -    target:
  -      creationPolicy: Owner
  -      deletionPolicy: Delete
  -    data:
  -      - remoteRef:
  -          key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
  -          property: password
  -          version: "1"
  -        secretKey: password
     some-secret-v2:
       refreshInterval: 0
       secretStoreName: my-app-secrets
       target:
         creationPolicy: Owner
         deletionPolicy: Delete
       data:
         - remoteRef:
             key: "{{ .Environment.Values.cluster }}/my-app/some-secret"
             property: password
             version: "2"
           secretKey: password
  ```

* commit, open a merge request, merge and deploy
* ensure that the old secret has been deleted:

  ```shell
  kubectl --context my-cluster --namespace my-namespace get secret some-secret-v1
  ```

### Chef Secrets

#### Structure

Chef secrets are available under the following paths:

* `chef/env/<environment>/cookbook/<cookbook-name>/...`: to be used for secrets scoped to a cookbook, which are only accessible for this particular environment.
* `chef/env/<environment>/shared/...`: to be used by secrets shared for all instances on the environment, or when the secret is shared between several cookbooks.

_Terminology:_

* `environment`: The GCP project for the instance accessing Vault Secrets.
* `cookbook-name`: Name of the cookbook that will be accessing the secrets.

Examples:

* `chef/env/db-benchmarking/cookbook/gitlab-foo/foo`: is a secret named `foo` for the `db-benchmarking` environment and only to be accessed by instances that use the `gitlab-foo` cookbook.
* `chef/env/db-benchmarking/shared/foo-shared`: is a secret named `foo-shared` that is accessible by all instances and cookbooks on the `db-benchmarking` environment.

#### Authorizing a GCP Project and Cookbooks

We use the [GCP authentication method](https://developer.hashicorp.com/vault/docs/auth/gcp) for GCE instances to authenticate to Vault.
To enable instances on a GCP Project to access Vault, add the project and roles for each cookbook, to the `chef_environments` locals at the [Chef Vault Configuration on Terraform](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/blob/master/environments/vault-production/chef.tf)

Example of Vault Config for allowing Chef access:

```
locals {
  chef_common_cookbooks = [
    "gitlab-consul",
  ]

  chef_environments = {
    db-benchmarking = {
      gcp_projects = ["gitlab-db-benchmarking"]
      roles = {
        base = {
          cookbooks = local.chef_common_cookbooks
        }
        foo = {
          cookbooks = concat(local.chef_common_cookbooks, [
            "gitlab-foo",
          ])
        }
        foobar = {
          cookbooks = ["gitlab-foobar"]
        }
      }
    }
  }
}
```

On this example we have allowed access for instances on the GCP Project `gitlab-db-benchmarking`.

We have created three Vault roles:

* `base` - Will have access to secrets on the following paths:
  * `chef/env/db-benchmarking/shared/...`
  * `chef/env/db-benchmarking/cookbook/gitlab-consul/...`
* `foo` - Will have access to secrets on the following paths:
  * `chef/env/db-benchmarking/shared/...`
  * `chef/env/db-benchmarking/cookbook/gitlab-consul/...`
  * `chef/env/db-benchmarking/cookbook/gitlab-foo/...`
* `foobar` - Will have access to secrets on the following paths:
  * `chef/env/db-benchmarking/shared/...`
  * `chef/env/db-benchmarking/cookbook/gitlab-foobar/...`

#### Using Vault secrets in Chef

Cookbooks using Vault as secrets backend have a dependency on the [gitlab_secrets cookbook](https://gitlab.com/gitlab-cookbooks/gitlab_secrets) version `>=1.0.0`.

This cookbook provides two functions that can be used for retrieving secrets from Vault:

* [get_secrets()](https://gitlab.com/gitlab-cookbooks/gitlab_secrets/-/blob/master/libraries/secrets.rb#L161)
* [merge_secrets()](https://gitlab.com/gitlab-cookbooks/gitlab_secrets/-/blob/master/libraries/secrets.rb#L172)

#### Cookbook and Role Setup

We will use the `gitlab-monitor` cookbook as an example. This cookbook uses the [get_secrets()](https://gitlab.com/gitlab-cookbooks/gitlab-monitor/-/blob/master/recipes/database.rb#L14) function for accessing secrets.

This cookbook secrets are stored on the shared path `env/<environment>/shared/gitlab-omnibus-secrets` since is used across all instances on the environment.

In `chef-repo` we define its default attributes for the `env-base.json` role as follows:

```json
"gitlab_monitor": {
  "secrets": {
    "backend": "hashicorp_vault",
    "path": {
      "path": "env/<env>/shared/gitlab-omnibus-secrets",
      "mount": "chef"
    }
  }
}
```

Example of the attribute definition on [db-benchmarking-base.json role](https://gitlab.com/gitlab-com/gl-infra/chef-repo/-/blob/master/roles/db-benchmarking-base.json#L65-73)

### GCP credentials

The [Google Cloud Vault secrets engine](https://developer.hashicorp.com/vault/docs/secrets/gcp) generates temporary OAuth tokens or service account keys that can be used to gain access to Google Cloud resources. The created OAuth tokens and service account keys are automatically deleted when the Vault lease expires.

It is mounted on `/gcp` in Vault, and uses Vault's service account via [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity).

#### Rolesets, static accounts or impersonated accounts?

The Google Cloud Vault secrets engine can be configured 3 different ways with 2 different credential types:

* **[Rolesets](https://developer.hashicorp.com/vault/docs/secrets/gcp#rolesets):** Vault provisions and fully manages a service account and its IAM permissions. This avoids the need for external configuration (e.g. Terraform) but also makes it near-impossible to give additional permissions to the service account outside of Vault due to the service account ID being auto-generated.
  * OAuth2 Access token:* Vault generates a single service account key at creation (not rotated automatically, but [can be rotated manually](https://developer.hashicorp.com/vault/api-docs/secret/gcp#rotate-roleset-account-key-access_token-roleset-only)) and then generates OAuth2 access tokens from it with a fixed TTL of 1 hour;
  * *Service account key:* Vault generates temporary service account keys, they are deleted when the Vault lease expires. There is a hard limit of 10 keys maximum at a time per service account (GCP limitation);
* **[Static accounts](https://developer.hashicorp.com/vault/docs/secrets/gcp#static-accounts):** Vault uses a service account provisioned externally (e.g. Terraform) and can optionally manage its IAM permissions.
  * *OAuth2 Access token:* Vault generates a single service account key at creation (not rotated automatically, but [can be rotated manually](https://developer.hashicorp.com/vault/api-docs/secret/gcp#rotate-static-account-key-access_token-static-account-only)) and then generates OAuth2 access tokens from it with a fixed TTL of 1 hour;
  * *Service account key:* Vault generates temporary service account keys, they are deleted when the Vault lease expires. There is a hard limit of 10 keys maximum at a time per service account (GCP limitation);
* **[Impersonated accounts](https://developer.hashicorp.com/vault/docs/secrets/gcp#impersonated-accounts):** Vault impersonates a service account provisioned externally (e.g. Terraform)
  * *OAuth2 Access token:* Vault generates OAuth2 access tokens by impersonation with a configurable TTL of up to 12 hours (1 hour by default).

Service account impersonation is the preferred method as it doesn't use service account keys, gives control over the OAuth2 access token TTL and requires the fewest permissions in GCP.

The required permissions for each method [can be found in the official documentation](https://developer.hashicorp.com/vault/docs/secrets/gcp#required-permissions) and must be given to Vault's service account `vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com`.

#### Configuration

##### 1. Grant permissions for Vault in GCP

###### Rolesets

Bind the service account `vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com` to the following roles at the project level:

* `roles/iam.serviceAccountKeyAdmin`
* `roles/iam.serviceAccountAdmin`
* `roles/iam.securityAdmin`

In [`config-mgmt`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/) this can be done with the following in `environments/env-projects`:

```terraform
module "gitlab-my-project" {
  source  = "ops.gitlab.net/gitlab-com/project/google"
  version = "14.3.0"

  ...

  iam = {
    bindings = transpose(local.vault_iam_bindings)
  }
}
```

###### Static accounts

Bind the service account `vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com` to the following roles at the service account level:

* `roles/iam.serviceAccountKeyAdmin`
* `roles/iam.serviceAccountTokenCreator`

In [`config-mgmt`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/) this can be done with the following:

```terraform
locals {
  vault_service_account_email = "vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "my-service-account-vault" {
  for_each = ["roles/iam.serviceAccountTokenCreator", "roles/iam.serviceAccountTokenCreator"]

  service_account_id = google_service_account.my-service-account.name
  role               = each.value
  member             = "serviceAccount:${local.vault_service_account_email}"
}
```

###### Impersonated accounts

Bind the service account `vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com` to the following roles at the service account level:

* `roles/iam.serviceAccountTokenCreator`

In [`config-mgmt`](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/) this can be done with the following:

```terraform
locals {
  vault_service_account_email = "vault-ops-k8s@gitlab-ops.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "my-service-account-vault" {
  service_account_id = google_service_account.my-service-account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${local.vault_service_account_email}"
}
```

##### 2. Add GCP roles in Vault

In the [`vault-production` environment](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/tree/master/environments/vault-production), add your roleset / static account / impersonated account to the variable `gcp_projects` in `gcp_projects.tf`:

```terraform
  gcp_projects = {
    gitlab-my-project = {
      impersonated_accounts = {
        my-service-account-foo = {}
      }
      static_accounts = {
        my-service-account-bar = {}
      }
      rolesets = {
        "my-roleset-baz" = {
          roles = [
            "roles/compute.admin",
          ]
          type = "service_account_key"
        }
      }
    }
  }
```

The credentials for the service accounts defined above would then be available under those paths:

* `gcp/impersonated-account/gitlab-my-project--my-service-account-foo/token`
* `gcp/static-account/gitlab-my-project--my-service-account-bar/token`
* `gcp/roleset/gitlab-my-project--my-roleset-baz/key`

Several optional attributes are supported, see [the `vault-configuration` module documentation](https://ops.gitlab.net/gitlab-com/gl-infra/terraform-modules/vault-configuration/#input_gcp) for more information.

### Kubernetes credentials

The [Kubernetes Vault secrets engine](https://developer.hashicorp.com/vault/docs/secrets/kubernetes) generates Kubernetes service account tokens, and optionally service accounts, role bindings, and roles. The created service account tokens have a configurable TTL and any objects created are automatically deleted when the Vault lease expires.

It is mounted on `/kubernetes` in Vault.

#### Role rules, roles or service accounts

The Kubernetes Vault secrets engine can be configured 3 different ways:

* **Role rules:** Vault creates a temporary `Role` or `ClusterRole` from a given list of [`PolicyRules`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#policyrule-v1-rbac-authorization-k8s-io) and a temporary `ServiceAccount` bound to this role
* **Role:** Vault creates a temporary `ServiceAccount` bound to a given pre-existing `Role` or `ClusterRole`
* **Service account:** Vault uses a given pre-existing `ServiceAccount`

#### Configuration

##### 1. Grant permissions for Vault in a Kubernetes cluster

FIXME something something `vault-k8s-secrets` chart

##### 2. Add Kubernetes roles in Vault

In the [`vault-production` environment](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt/-/tree/master/environments/vault-production), add your role to the variable `kubernetes_clusters.<cluster>.secrets_roles` in `kubernetes.tf`:

```terraform
  kubernetes_clusters = {
    my-cluster = {
      secrets_roles = {
        view = {
          allowed_kubernetes_namespaces = ["*"]
          role_name                     = "view"
          role_type                     = "ClusterRole"
        }
        my-service-configmap-edit = {
          allowed_kubernetes_namespaces = ["my-namespace"]
          role_rules = [
            {
              apiGroups     = [""]
              resources     = ["configmaps"]
              resourceNames = ["my-service-config"]
              verbs         = ["get", "list", "watch", "create", "update", "patch", "delete"]
            }
          ]
          role_type = "Role"
        }
        my-service-account = {
          allowed_kubernetes_namespaces = ["my-other-namespace"]
          service_account_name          = "my-service-account"
        }
      }
    }
  }
```

The credentials for the service accounts defined above would then be available under those paths:

* `kubernetes/my-cluster/creds/view`
* `kubernetes/my-cluster/creds/my-service-configmap-edit`
* `kubernetes/my-cluster/creds/my-service-account`

Several optional attributes are supported, see [the `vault-configuration` module documentation](https://ops.gitlab.net/gitlab-com/gl-infra/terraform-modules/vault-configuration/#input_kubernetes) for more information.

### Interact with Vault Secrets

For reviewing or updating a secret you can either use the [Vault UI](https://vault.gitlab.net/) or use `glsh` commands as follows:

1. Start proxy to connect to Vault

```
glsh vault proxy
```

2. On another tab, authenticate to Vault

```
glsh vault login
```

3. Interact with Secret:

    * Retrieve secret data from Vault:

    ```
    glsh vault show-secret MOUNT PATH
    ```

    * Modify secret data and update it on Vault:

    ```
    glsh vault edit-secret MOUNT PATH
    ```

We will demonstrate this procedure with an example using the following secret attributes:
Secret Path: `env/db-benchmarking/shared/test-secret`
Mount: `chef`

* Show Vault Secret:

```
glsh vault show-secret chef env/db-benchmarking/shared/test-secret
{
  "database": {
    "password": "foopass",
    "user": "foo"
  },
  "favorite-things": {
    "animal": "dog",
    "car": "tesla",
    "color": "blue",
    "food": "pizza",
    "place": "san francisco"
  }
}
```

* Modify Vault Secret:

We will update the `password` field:

```
glsh vault edit-secret chef env/db-benchmarking/shared/test-secret
Retrieving secret from Vault
Checking file is valid json
Creating new env/db-benchmarking/shared/test-secret version in Vault
================== Secret Path ==================
chef/data/env/db-benchmarking/shared/test-secret

======= Metadata =======
Key                Value
---                -----
created_time       2023-04-25T15:10:48.609120095Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            16
Updated secret:
{
  "database": {
    "password": "supersecretpassword",
    "user": "foo"
  },
  "favorite-things": {
    "animal": "dog",
    "car": "tesla",
    "color": "blue",
    "food": "pizza",
    "place": "san francisco"
  }
}
```
