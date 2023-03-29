# Teleport Approver Workflow

The approval process for Rails and Database Console access is the same.

## Approval Process

As an approver, you should use your judgement to determine whether the access that they are asking for is appropriate for what they are trying to do in the linked issue or in the text of the `Reason` field.

There are two main areas to check in just a few minutes:

1. Does the request line up with the person's role at GitLab? (Okta should enforce this too via groups)
2. Is the issue a current and related item?

Since all requests will already be authenticated via Okta, using 2FA and Company credentials, the approver does not need to do anything additional to validate their identity unless there is something suspicious about the request.

Clicking on the link to the request will bring up the Okta login (which will automatically redirect through if already logged in). Okta will redirect to a web view of the request. Here you can enter any comments that are appropriate for why the request is being approved or rejected. Comments are optional.

Once the form is submitted, the service will generate a short lived certificate (currnetly 24 hours) and return it to the requestors session. The Slack bot will update the status of the notification so there is no need to flag it as complete, or take any further action.

> Note: The staging and production environments are completely separated, but the interfaces look similar.  Be aware of whether you are responding to the production slack bot (named `Teleport`) or the staging slack bot (named `Teleport-Staging`).  Also be aware of which web interfaces you are on when you approve a request.

## Slack Notifications

When a user requests access to a role, the Teleport server will post a message in Slack with a link to the request. Clicking the link leads to the request section of the web interface. The message will also contain a `Reason` field, which is free text but we suggest that the requestor use that field for a link to the issue that they are working on.

## Web Interface

The web Access Request lists are:

- Staging - [https://teleport.gstg.gitlab.net:3080/web/requests](https://teleport.gstg.gitlab.net:3080/web/requests)
- Production - [https://teleport.gprd.gitlab.net:3080/web/requests](https://teleport.gprd.gitlab.net:3080/web/requests)

The Slack notifications are only there to provide timely notification of new requests. It is fine to approve a request which you are notified of through other reasonable means (for example verbally during an incident). Just go to one of the lists above, find the request you'd like to approve, and click `View`.  This will take you to the same review and approval page as the Slack link.

## Optional CLI Workflow

Approvals can be done entirely through the web interface, but there are times when it may be desirable to do them from the CLI.

To use the CLI approval workflows, you must be running the enterprise version of the `tctl` client.  This can be installed locally on a laptop, or can be run on the teleport servers.  Note that the version installed with `brew install teleport` is NOT the enterprise version.  It will work fine for client connections, but will not work for approvals.

To install the enterprise version on a workstation, download and install this package:

- Mac Package: [https://get.gravitational.com/teleport-ent-8.1.1.pkg](https://get.gravitational.com/teleport-ent-8.1.1.pkg)
- Linux DEB: [https://get.gravitational.com/teleport-ent_8.1.1_amd64.deb](https://get.gravitational.com/teleport-ent_8.1.1_amd64.deb)
- Linux TAR: [https://get.gravitational.com/teleport-ent-v8.1.1-linux-amd64-bin.tar.gz](https://get.gravitational.com/teleport-ent-v8.1.2-linux-amd64-bin.tar.gz)

> You must be logged in with the role `teleport-approver` to use these commands. That means you'll need to be in the `GitLab - SRE` or `GitLab - SRE Managers` group in Okta. (This is configured in the [okta-connector.yaml](https://gitlab.com/gitlab-cookbooks/gitlab-teleport/-/blob/master/templates/default/okta-connector.yaml.erb#L14) file)

```shell
$ tctl request ls
Token                                Requestor         Metadata       Created At (UTC)    Status   Request Reason Resolve Reason
------------------------------------ ----------------- -------------- ------------------- -------- -------------- --------------
8f1532ba-1f96-46c3-8695-b209d3e70507 dsylva@gitlab.com roles=rails-ro 11 Mar 21 19:07 UTC PENDING 11234
```

```shell
tctl request approve 8f1532ba-1f96-46c3-8695-b209d3e70507
```

```shell
$ tctl request ls
Token                                Requestor         Metadata       Created At (UTC)    Status   Request Reason Resolve Reason
------------------------------------ ----------------- -------------- ------------------- -------- -------------- --------------
8f1532ba-1f96-46c3-8695-b209d3e70507 dsylva@gitlab.com roles=rails-ro 11 Mar 21 19:07 UTC APPROVED 11234
```

### Troubleshooting

If you see the following errors:

`ERROR: your credentials have expired, please login using tsh login`

`ERROR: lstat /private/var/lib/teleport: no such file or directory`

It's likely that you need to log in or re-authenticate with:

```shell
tsh login --proxy=teleport.gstg.gitlab.net
```

> Note: All examples are for the `gstg` environment.  Replace `gstg` with `gprd` for production

## User issues

Many user issues can be corrected by removing their local `~/.tsh` directory.  It will be re-created on next login.  These problems usually show up if the user has previously connected to an instance which has been rebuilt and has new CA certificates.

There are also times when restarting the Teleport service has resolved user issues. Read about that in the [teleport_admin](teleport_admin.md) runbook.

## Workarounds

Last resort solutions if UI and tctl from your machine don't work.
You can ssh directly to the teleport server and do tctl commands:

```shell
ssh teleport-01-inf-gstg.c.gitlab-staging-1.internal sudo tctl requests ls
ssh teleport-01-inf-gstg.c.gitlab-staging-1.internal sudo tctl requests approve XXX
```
