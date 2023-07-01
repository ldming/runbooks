#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/tcpdump_on_gke_library.sh"

function main() {
  handle_args "$@"
  setup_toolbox
  find_netns_for_pod_id
  run_tcpdump_in_toolbox_for_netns
  compress_pcap_file
  show_pcap_file
}

function usage() {
  local ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "ERROR: $ERROR_MESSAGE" && echo

  cat <<HERE
Usage: tcpdump_on_gke_in_pod_netns.sh [pod_id] [max_duration_seconds] [tcpdump_options]

Capture network traffic in the pod's network namespace.
This includes traffic on both the local loopback and main network interface.

Must specify the pod_id and max seconds to run tcpdump as the first two arguments.
Any other arguments are passed directly to tcpdump, including any pcap filter expressions or other options.

The resulting pcap file is written to host path:
$OUTPUT_DIR_OUTSIDE_TOOLBOX

Warning:
Ctrl-C is ignored during the capture, because toolbox does not pass signals to its spawned process (tcpdump).
As a precaution, [max_duration_seconds] is a mandatory argument for this script.
If you need to interrupt a capture, open another shell and kill tcpdump.

Examples:

Choose a pod id:

$ POD_ID=\$( crictl pods --quiet --latest --label 'app=gitlab-shell' )
$ POD_ID=\$( bash ./pod_id_for_pid.sh \$( pidof redis-server ) )

Then capture its traffic:

Capture all traffic to and from this pod for 60 seconds:
$ tcpdump_on_gke_in_pod_netns.sh \$POD_ID 60

Capture traffic in both directions on this pod's container port 8080 for 10 seconds:
$ tcpdump_on_gke_in_pod_netns.sh \$POD_ID 10 'port 8080'

Capture up to 10K packets or up to 120 seconds, whichever comes first:
$ tcpdump_on_gke_in_pod_netns.sh \$POD_ID 120 -c 10000
HERE
  exit 1
}

function handle_args() {
  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -ge 2 ]] || usage "Must specify at least a pod id and a max capture duration."

  POD_ID=$1
  shift
  [[ $POD_ID =~ ^[0-9a-f]{10,64}$ ]] || usage "Invalid pod id: '$POD_ID'"

  MAX_DURATION_SECONDS=$1
  shift
  [[ $MAX_DURATION_SECONDS =~ ^[0-9]+$ ]] || usage "Must specify max duration in seconds."

  # shellcheck disable=SC2034
  EXTRA_TCPDUMP_ARGS=("$@")

  # shellcheck disable=SC2034
  PCAP_FILENAME="$(hostname -s).pod_${POD_ID}.$(date +%Y%m%d_%H%M%S).pcap"
}

main "$@"
