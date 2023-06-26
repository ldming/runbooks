#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/container_inspection_library.sh"

function main() {
  local TARGET_CONTAINER_ID=$1
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -eq 1 ]] || usage "Wrong number of arguments"
  cgroup_for_container_id "$TARGET_CONTAINER_ID"
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<HERE
Usage: cgroup_for_container_id.sh [container id]

Finds the cpu cgroup path of the given container id.

This cgroup path uniquely identifies the cgroup and the discrete set of processes it includes.
Each container and pod typically has its own cgroup.
The cgroup path can be used as a group identifier, for example to find and profile all member processes.
HERE
  exit 1
}

main "$@"
