#!/bin/bash

set -o pipefail
set -o errexit

function main() {
  local TARGET_POD_ID=$1
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -eq 1 ]] || usage "Wrong number of arguments"
  install_jq
  pod_ip_addr_for_pod_id "$TARGET_POD_ID"
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<'HERE'
Usage: ip_addr_for_pod_id.sh [pod id]

Finds the pod IP address of the given pod id.

Examples:

$ POD_ID=$( crictl pods --quiet --latest --label 'app=gitlab-shell' )
$ bash ./ip_addr_for_pod_id.sh $POD_ID

$ POD_ID=$( bash ./pod_id_for_pid.sh $( pidof redis-server ) )
$ bash ./ip_addr_for_pod_id.sh $POD_ID
HERE
  exit 1
}

function install_jq() {
  toolbox apt install -y -qq jq >&/dev/null
}

function pod_ip_addr_for_pod_id() {
  local POD_ID=$1
  crictl inspectp "$POD_ID" 2>/dev/null | toolbox jq -r '.info.cniResult.Interfaces.eth0.IPConfigs[].IP' 2>/dev/null
}

main "$@"
