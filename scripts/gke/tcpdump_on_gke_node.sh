#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/tcpdump_on_gke_library.sh"

function main() {
  handle_args "$@"
  setup_toolbox
  find_default_net_iface_for_host
  run_tcpdump_in_toolbox_for_iface
  compress_pcap_file
  show_pcap_file
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<HERE
Usage: tcpdump_on_gke_node.sh [max_duration_seconds] [tcpdump_options]

Capture network traffic on the host's main interface, including all pods.

Must specify the max seconds to run tcpdump as the first argument.
Any other arguments are passed directly to tcpdump, including any pcap filter expressions or other options.

The resulting pcap file is written to host path:
$OUTPUT_DIR_OUTSIDE_TOOLBOX

Warning:
Ctrl-C is ignored during the capture, because toolbox does not pass signals to its spawned process (tcpdump).
As a precaution, [max_duration_seconds] is a mandatory argument for this script.
If you need to interrupt a capture, open another shell and kill tcpdump.

Examples:

Capture all traffic to and from all pods on this host for 60 seconds:
$ tcpdump_on_gke_node.sh 60

Capture traffic in both directions on host port 8080 for 10 seconds:
$ tcpdump_on_gke_node.sh 10 'port 8080'

Capture up to 10K packets or up to 120 seconds, whichever comes first:
$ tcpdump_on_gke_node.sh 120 -c 10000
HERE
  exit 1
}

function handle_args() {
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -ge 1 ]] || usage "Must specify at least a capture duration."

  MAX_DURATION_SECONDS=$1
  shift
  [[ $MAX_DURATION_SECONDS =~ ^[0-9]+$ ]] || usage "Must specify max duration in seconds."

  # shellcheck disable=SC2034
  EXTRA_TCPDUMP_ARGS=("$@")

  # shellcheck disable=SC2034
  PCAP_FILENAME="$(hostname -s).$(date +%Y%m%d_%H%M%S).pcap"
}

main "$@"
