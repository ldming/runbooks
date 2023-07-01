#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/container_inspection_library.sh"

function main() {
  TARGET_CGROUP=$1
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -eq 1 ]] || usage "Wrong number of arguments"
  container_id_for_cpu_cgroup "$TARGET_CGROUP"
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<HERE
Usage: container_id_for_cgroup.sh [cgroup_path]

Given a cpu cgroup path (such as reported by /proc/[pid]/cgroup), find the corresponding container id.
This container id can be used with "crictl" subcommands such as "ps" and "inspect".

Note: This script relies on the "crictl" utility to query the configured container runtime API.
HERE
  exit 1
}

main "$@"
