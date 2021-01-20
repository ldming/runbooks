<!-- MARKER: do not edit this section directly. Edit services/service-catalog.yml then run scripts/generate-docs -->

**Table of Contents**

[[_TOC_]]

#  Kubernetes-agent Service
* [Service Overview](https://dashboards.gitlab.net/d/kas/kas)
* **Alerts**: https://alerts.gitlab.net/#/alerts?filter=%7Btype%3D%22kubernetes-agent%22%2C%20tier%3D%22sv%22%7D
* **Label**: gitlab-com/gl-infra/production~"Service:kas"

## Logging

* [kas](TBD)

## Troubleshooting Pointers

* [kubernetes-agent-basic-troubleshooting.md](kubernetes-agent-basic-troubleshooting.md)
<!-- END_MARKER -->

# Summary

The GitLab Kubernetes Agent is an active in-cluster component for solving GitLab and Kubernetes integration tasks in a secure and cloud-native way. It enables:

* Integrating GitLab with a Kubernetes cluster behind a firewall or NAT (network address translation).
* Pull-based GitOps deployments by leveraging the GitOps Engine.
* Real-time access to API endpoints in a cluster.

More information can be found at https://docs.gitlab.com/ee/user/clusters/agent/

# Architecture

## Ingress Architecture

`kas` is unique in that it doesn't follow the traditional mechanisms/traffic flow from the internet. Instead of using cloudflare and haproxy, we instead have created an entirely new domain https://kas.gitlab.com and Ingress architecture to accomodate it. This is because

* As `kas` is focussed on long-lived connections, we didn't want to have `kas` connections tying up the same ingress resources that the rest of Gitlab uses (haproxy, ingress-nginx, etc).
* As `kas` uses websockets or grpc, some of our current ingress technologies such as cloudflare have varying levels of support for these (with their own caveats)

To this end, we have exposed `kas` to internet traffic utilising a [GKE Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) object, currently running in HTTP1.1 with websockets. We also leverage a few key features of GKE Ingress including

* [Google Managed Certificate](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs) for https://kas.gitlab.com, deployed and managed by a Kubernetes CRD in the [gitlab-extras helm release](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab-extras/values.yaml.gotmpl#L3-10)

* We configure the GKE Ingress (which is implemented by a GCP HTTPS Load Balancer) to use a custom HTTP healthcheck, as the readiness and liveness endpoints for `kas` live on a different port than the port used to serve traffic (due to the nature of websockets/grpc). It is also part of the [gitlab-extras helm release](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab-extras/values.yaml.gotmpl#L12-22)

* We also leverage [container native load balancing](https://cloud.google.com/kubernetes-engine/docs/concepts/container-native-load-balancing) to allow the GCP Load Balancer to map endpoints and route traffic **directly to the pods via their individual pod IPs**. This bypasses the usual mechanism of mapping endpoints as nodes, requiring a service being exposed as a `NodePort`, and utilising `kube-proxy` to configure `iptables` rules to route traffic in an even matter. This overall provides a much simpler network topology, with less hops. A Kubernetes `service` object is still needed for GKE/GCP to sync the endpoint list to the HTTPS load balancer, but the `ClusterIP` (or indeed any IP) of the `service` object is not actually used.

## Agent, KAS, and Rails Architecture

See https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md#high-level-architecture

We have two components for the Kubernetes agent:

- The GitLab Kubernetes Agent Server (`kas`). This is deployed server-side together with the GitLab web (Rails), and Gitaly. It's responsible for:
  - Accepting requests from `agentk`.
  - [Authentication of requests](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/identity_and_auth.md) from `agentk` by querying `GitLab RoR`.
  - Fetching agent's configuration from a corresponding Git repository by querying `Gitaly`.
  - Polling manifest repositories for [GitOps support](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/gitops.md) by talking to `Gitaly`.
- The GitLab Kubernetes Agent (`agentk`). This is deployed to the user's Kubernetes cluster. It is responsible for:
  - Keeping a connection established to a `kas` instance
  - Processing GitOps requests from `kas`

# Performance

# Scalability

1. The `kas` chart is configured by default to autoscale by using a [HorizontalPodAutoscaler](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/charts/gitlab/charts/kas/templates/hpa.yaml). The HorizontalPodAutoscaler is configured to target an average value of 100m CPU.

# Availability

# Durability

Kas itself is stateless, all information it needs is stored in either Gitaly or the Gitlab rails application itself.

# Security/Compliance

Please see https://gitlab.com/gitlab-com/gl-security/appsec/appsec-reviews/-/issues/30

# Monitoring/Alerting

# Links to further Documentation