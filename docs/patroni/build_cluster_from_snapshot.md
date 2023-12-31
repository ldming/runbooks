# Steps to create (or recreate) a Standby CLuster using a Snapshot from a Production cluster as Master cluster (instead of pg_basebackup)

<!-- vscode-markdown-toc -->
* 1. [Pre-requisites](#Pre-requisites)
* 2. [Chef role for the Target cluster](#ChefrolefortheTargetcluster)
* 3. [Define the new Standby Cluster in Terraform](#DefinethenewStandbyClusterinTerraform)
* 4. [Steps to Destroy a Standby Cluster if you want to recreate it](#StepstoDestroyaStandbyClusterifyouwanttorecreateit)
* 5. [Create the Patroni CI Standby Cluster instances](#CreatethePatroniCIStandbyClusterinstances)
  * 5.1. [Create the cluster with TF](#CreatetheclusterwithTF)
  * 5.2. [Stop patroni and reset WAL directory from old files](#StoppatroniandresetWALdirectoryfromoldfiles)
  * 5.3. [Initialize Patroni standby_cluster with Ansible playbook](#InitializePatronistandby_clusterwithAnsibleplaybook)
  * 5.4. [Check if the Patroni standby_cluster is healthy and replicating](#CheckifthePatronistandby_clusterishealthyandreplicating)
    * 5.4.1. [Check standby_cluster source configuration](#Checkstandby_clustersourceconfiguration)
    * 5.4.2. [Check Replication status](#CheckReplicationstatus)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

# Summary

From time to time we have to create Standby Clusters from a source/existing Gitlab.com Patroni database, usually from GPRD or GSTG.

Standby Clusters are physically replicated clusters, that stream or recover WALs from the source Patroni/PostgreSQL database, but have an independent Patroni configuration and management, therefore can be promoted if required.

This runbook describes the whole procedure and several takeaways to help you to create a new Patrony Standby Clusters from scratch.

## 1. <a name='Pre-requisites'></a>Pre-requisites

1. Terraform should be installed and configured;
2. Ansible should be installed and configured into your account into your workstation or a `console` node, you can use the following commands:

    ```
    python3 -m venv ansible
    source ansible/bin/activate
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible
    ansible --version
    ```

3. Download/clone the [ops.gitlab.net/gitlab-com/gl-infra/config-mgmt](https://ops.gitlab.net/gitlab-com/gl-infra/config-mgmt) project into your workstation or a `console` node;

## 2. <a name='ChefrolefortheTargetcluster'></a>Chef role for the Target cluster

Some `postgresql` settings need to be the SAME as the Source cluster for the physical replication to work, they are:

```
    "postgresql": {
        "version":
        "pg_user_homedir":
        "config_directory":
        "data_directory":
        "log_directory":
        "bin_directory":
    ...
    }

```

**IMPORTANT: the `gitlab_walg.storage_prefix` in the target Chef role SHOULD NOT BE THE SAME as the Source cluster**, otherwise the backup of the source cluster can be overwritten.

The Chef role of the standby patroni cluster should have defined the `standby_cluster` settings under `override_attributes.gitlab-patroni.patroni.config.bootstrap.dcs` like the below example.
Notice that `host` should point to the endpoint of the Primary/Master node of the source cluster, therefore if there's a failover we don't have to reconfigure the standby cluster.

```
  "override_attributes": {
    "gitlab-patroni": {
      "patroni": {
        "config": {
          "bootstrap": {
            "dcs": {
              "standby_cluster": {
                "host": "master.patroni.service.consul",
                "port": 5432
              }
            }
          }
        }
      }
    }
  },
```

## 3. <a name='DefinethenewStandbyClusterinTerraform'></a>Define the new Standby Cluster in Terraform

Define a disk snapshot from the source cluster in Terraform, for example:

```
data "google_compute_snapshot" "gcp_database_snapshot_gprd_main_2004" {
  filter      = "sourceDisk eq .*/patroni-main-2004-.*"
  most_recent = true
}
```

:warning: IMPORTANT: Use an existing snapshot or create a new one manually – to do the latter properly, follow the procedure defined in [gcs-snapshots.md](gcs-snapshots.md#manual-gcs-snapshots). If you create a new GCS snapshot without proper additional actions, Postgres might not be able to reach the consistency point (it won't start).

When defining the target cluster module in Terraform, define the storage size and settings similar to the source, and then define the `data_disk_snapshot` pointing to the source snapshot and a large amount of time for `data_disk_create_timeout`, like for example:

```
module "patroni-main-standby_cluster" {
  source  = "ops.gitlab.net/gitlab-com/generic-stor-with-group/google"
  version = "8.1.0"

  data_disk_size           = var.data_disk_sizes["patroni-main-2004"]
  data_disk_type           = "pd-ssd"
  data_disk_snapshot       = data.google_compute_snapshot.gcp_database_snapshot_gprd_main_2004.id
  data_disk_create_timeout = "120m"
  ...
}
```

## 4. <a name='StepstoDestroyaStandbyClusterifyouwanttorecreateit'></a>Steps to Destroy a Standby Cluster if you want to recreate it

**IMPORTANT: make sure to review the MRs and commands or perform the execution with a peer**

**IMPORTANT: You should NEVER perform this operation for existing clusters PRODUCTION clusters that are in use by the application**, only destroy new clusters you are rebuilding for new projects;

If the cluster exists and is not operational, in sync, or has issues with the source replication, create an MR to destroy the cluster. As a standard practice, always rebase MR before merging it and review MR's Terraform plan job for accuracy.

Once MR is merged, clean out any remaining Chef client/nodes using `knife`, like for example:

```
knife node delete --yes patroni-main-standby_cluster-10{1..5}-db-$env.c.gitlab-$gcp_project.internal
knife client delete --yes patroni-main-standby_cluster-10{1..5}-db-$env.c.gitlab-$gcp_project.internal
```

## 5. <a name='CreatethePatroniCIStandbyClusterinstances'></a>Create the Patroni CI Standby Cluster instances

### 5.1. <a name='CreatetheclusterwithTF'></a>Create the cluster with Terraform MR

If you are creating the nodes for the first time, **they should be created by our CI/CO pipeline** when you merge the changes in `main.tf` in the repository.

Otherwise, create a new MR to revert the changes performed by the earlier MR that destroyed it. Again, as a standard practice, always rebase MR before merging it and review MR's Terraform plan job for accuracy. Merge the MR to create cluster nodes.

### 5.2. <a name='StoppatroniandresetWALdirectoryfromoldfiles'></a>Stop patroni and reset WAL directory from old files

Before executing the playbook to create the standby cluster, you have to stop patroni service in all nodes of the new standby cluster.

```
knife ssh "role:<patroni_standby_cluster_role>" "sudo systemctl stop patroni"
````

Then you have to clean out the `pg_wal` directory of all nodes of the new standby cluster, otherwise, there could be old TL history data on this directory that will affect the WAL recovery from the source cluster.
You can perform the following:

```
knife ssh "role:<patroni_standby_cluster_role>" "sudo rm -rf /var/opt/gitlab/postgresql/data12/pg_wal; sudo mkdir /var/opt/gitlab/postgresql/data12/pg_wal; sudo chown gitlab-psql /var/opt/gitlab/postgresql/data12/pg_wal"
```

Note: you can change `/var/opt/gitlab/postgresql/data12` to any other data directory that is in use, eg. `/var/opt/gitlab/postgresql/data14`, etc.

### 5.3. <a name='InitializePatronistandby_clusterwithAnsibleplaybook'></a>Initialize Patroni standby_cluster with Ansible playbook

**1st -** Download/clone the [gitlab.com/gitlab-com/gl-infra/db-migration](https://gitlab.com/gitlab-com/gl-infra/db-migration) project into your workstation or a `console` node;

```
git clone https://gitlab.com/gitlab-com/gl-infra/db-migration.git
```

**2nd -** Check that the inventory file for your desired environment exists in `db-migration/pg-replica-rebuild/inventory/` and it's up-to-date with the hosts you're targeting. The inventory file should contain:

* `all.vars.walg_gs_prefix`: this is the GCS bucket and directory of the SOURCE database WAL archive location (the source database is the cluster you referred the `data_disk_snapshot` to create the cluster throughout TF). You can find this value in the source cluster Chef role, it should be the `gitlab_walg.storage_prefix` for that cluster.
* `all.hosts`: a regex that represents the FQDN of the hosts that are going to be part of this cluster, where the first node will be created as Standby Leader.

Example:

```
all:
  vars:
    walg_gs_prefix: 'gs://gitlab-gstg-postgres-backup/pitr-walg-main-pg12-2004'
  hosts:
    patroni-main-v14-[101:105]-db-gstg.c.gitlab-staging-1.internal:
```

**3rd -** Run `ansible -i inventory/<file> all -m ping` to ensure that all `hosts` in the inventory are reachable;

```
cd db-migration/pg-replica-rebuild
ansible -i inventory/<file> all -m ping
```

**4th -** Execute the `rebuild-all` Ansible playbook to create the standby_cluster, and sync all nodes with the source database;

```
cd db-migration/pg-replica-rebuild
ansible-playbook -i inventory/patroni-main-v14-gstg.yml rebuild-all.yml
```

### 5.4. <a name='CheckifthePatronistandby_clusterishealthyandreplicating'></a>Check if the Patroni standby_cluster is healthy and replicating

#### 5.4.1. <a name='Checkstandby_clustersourceconfiguration'></a>Check standby_cluster source configuration

Execute

```
gitlab-patronictl show-config
```

The output should present the `standby_cluster` block with the `host` property pointing to the proper source cluster master endpoint.

#### 5.4.2. <a name='CheckReplicationstatus'></a>Check Replication status

Execute

```
gitlab-patronictl list
```

In the output, the leader node of the new standby cluster should have its `Role` defined as `Standby Leader`, the `TL` (timeline) should match the TL from the source cluster, and all replicas `State` should be `running`, which mean that they are replicating/streaming from their sources.
