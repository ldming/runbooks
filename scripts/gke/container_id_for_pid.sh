#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/container_inspection_library.sh"

function main() {
  TARGET_PID=$1
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -eq 1 ]] || usage "Wrong number of arguments"
  TARGET_CGROUP=$(cgroup_path_for_pid "$TARGET_PID")
  container_id_for_cpu_cgroup "$TARGET_CGROUP"
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<'HERE'
Usage: container_id_for_pid.sh [pid]

Given a process id, find its corresponding container id.

This container id can be used with "crictl" subcommands such as:
  $ crictl ps --id $CONTAINER_ID
  $ crictl inspect $CONTAINER_ID

Note: This script relies on the "crictl" utility to query the configured container runtime API.
HERE
  exit 1
}

main "$@"
