#!/bin/bash

# This file provides library functions used by other scripts in this directory.
# These functions mainly facilitate crossreferencing between PID, container id, pod id, and cgroups.
# Assumptions:
#  * The "crictl" utility should be installed and configured with a container runtime API endpoint.
#    This is true by default on GKE nodes.
#  * The container runtime is using cgroups v1.  This is currently standard for Kubernetes.
#  * The standard mountpoint is used for the cpu cgroup controller.

# This is the standard mountpoint for the cgroups v1 cpu controller on COS and Ubuntu.
CPU_CGROUP_MOUNTPOINT="/sys/fs/cgroup/cpu,cpuacct"

function cgroup_path_for_pid() {
  local TARGET_PID=$1
  assert_is_pid "$TARGET_PID"
  local CPU_CGROUP
  CPU_CGROUP=$(awk -F':' '$2 == "cpu,cpuacct" { print $3 }' "/proc/$TARGET_PID/cgroup")
  [[ -n $CPU_CGROUP ]] || die "Could not find the CPU cgroup for PID $TARGET_PID"
  echo "$CPU_CGROUP"
}

function assert_is_pid() {
  local TARGET_PID=$1
  [[ $TARGET_PID =~ ^[0-9,]+$ ]] || die "Invalid PID: '$TARGET_PID'"
  [[ -d "/proc/$TARGET_PID" ]] || die "PID $TARGET_PID does not exist in this PID namespace"
}

function cgroup_for_container_id() {
  local CONTAINER_ID=$1
  crictl inspect "$CONTAINER_ID" 2>/dev/null | grep 'cgroupsPath' | awk '{ print $2 }' | tr -d '",'
}

function parent_cgroup_for_pod_id() {
  local POD_ID=$1
  crictl inspectp "$POD_ID" 2>/dev/null | grep 'cgroup_parent' | awk '{ print $2 }' | tr -d '",'
}

function all_container_ids() {
  crictl ps --quiet
}

function all_pod_ids() {
  crictl pods --quiet
}

function container_id_for_cpu_cgroup() {
  local TARGET_CGROUP=$1
  assert_is_cpu_cgroup "$TARGET_CGROUP"
  for CONTAINER_ID in $(all_container_ids); do
    local CONTAINER_CGROUP
    CONTAINER_CGROUP=$(cgroup_for_container_id "$CONTAINER_ID")
    if [[ $CONTAINER_CGROUP == "$TARGET_CGROUP" ]]; then
      echo "$CONTAINER_ID"
      return
    fi
  done
  die "Could not find a matching container id.  Does that cgroup belong to a pod or a non-kubernetes resource?"
}

function pod_id_for_cpu_cgroup() {
  local TARGET_CGROUP=$1
  assert_is_cpu_cgroup "$TARGET_CGROUP"
  for POD_ID in $(all_pod_ids); do
    local POD_CGROUP
    POD_CGROUP=$(parent_cgroup_for_pod_id "$POD_ID")
    if [[ $TARGET_CGROUP =~ ^${POD_CGROUP} ]]; then
      echo "$POD_ID"
      return
    fi
  done
  die "Could not find a matching pod id.  Does that cgroup belong to a resource outside of kubernetes?"
}

function assert_is_cpu_cgroup() {
  local TARGET_CGROUP=$1
  assert_cpu_cgroup_mountpoint_exists
  [[ -n $TARGET_CGROUP ]] || die "Must specify a non-blank cgroup path."
  [[ -d "$CPU_CGROUP_MOUNTPOINT/$TARGET_CGROUP" ]] || die "Could not find CPU cgroup: $TARGET_CGROUP"
}

function assert_cpu_cgroup_mountpoint_exists() {
  df --type cgroup "$CPU_CGROUP_MOUNTPOINT" >&/dev/null || die "Cannot find expected base mountpoint for cpu cgroups."
}

function die() {
  echo "ERROR: $*" 1>&2
  exit 1
}
