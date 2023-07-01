#!/bin/bash

set -o pipefail
set -o errexit

source "$(dirname "$0")/container_inspection_library.sh"

function usage() {
  ERROR_MESSAGE=$1
  [[ -n $ERROR_MESSAGE ]] && echo "Error: $ERROR_MESSAGE" && echo

  cat <<HERE
Usage: perf_flamegraph_for_container_id.sh [container id]

Captures an on-CPU stack profile for a container's processes, and renders it as a flamegraph.

The given container id should be from the output of "crictl ps".  It can be either the short or full id.
HERE
  exit 1
}

function is_gke() {
  if [[ ! -f /etc/os-release ]]; then
    return 1
  fi
  . /etc/os-release
  [[ $ID == "cos" ]]
}

function gke_install_flamegraph_pl() {
  if toolbox bash -c '[[ -d /opt/FlameGraph ]]'; then
    return
  fi
  toolbox apt update -y
  toolbox apt install -y git
  toolbox git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph
  toolbox ln -s /opt/FlameGraph/stackcollapse-perf.pl /usr/local/bin/stackcollapse-perf.pl
  toolbox ln -s /opt/FlameGraph/flamegraph.pl /usr/local/bin/flamegraph.pl
}

function main() {
  TARGET_CONTAINER_ID=$1
  DURATION_SECONDS=60
  SAMPLES_PER_SECOND=99

  [[ $1 =~ ^-h|--help$ ]] && usage
  [[ $# -eq 1 ]] || usage "Wrong number of arguments"
  [[ $TARGET_CONTAINER_ID =~ ^[0-9a-f]+$ ]] || usage "Invalid container id: '$TARGET_CONTAINER_ID'"

  is_gke && gke_install_flamegraph_pl

  # Find the given container's CPU cgroup.
  CONTAINER_CGROUP=$(cgroup_for_container_id "$TARGET_CONTAINER_ID")
  [[ -z $CONTAINER_CGROUP ]] && echo "ERROR: Cannot find container $TARGET_CONTAINER_ID" && exit 1
  echo "Target container $TARGET_CONTAINER_ID uses cgroup: $CONTAINER_CGROUP"

  # Use a temp dir.  This avoids polluting current dir and supports concurrent runs of this script.
  OUTDIR=$(mktemp -d /tmp/perf-record-results.XXXXXXXX)
  cd "$OUTDIR"

  # Name the output files to clearly indicate the scope and timestamp of the capture.
  OUTFILE_PREFIX="$(hostname -s).$(date +%Y%m%d_%H%M%S_%Z).container_${TARGET_CONTAINER_ID}"
  OUTFILE_PERF_SCRIPT="${OUTFILE_PREFIX}.perf-script.txt.gz"
  OUTFILE_FLAMEGRAPH="${OUTFILE_PREFIX}.flamegraph.svg"

  # Capture timer-based profile, resolve symbols, and render as a flamegraph.
  echo "Starting capture for $DURATION_SECONDS seconds."
  sudo perf record --freq "$SAMPLES_PER_SECOND" -g --all-cpus -e cpu-cycles --cgroup "$CONTAINER_CGROUP" -- sleep "$DURATION_SECONDS"
  sudo perf script --header | gzip >"$OUTFILE_PERF_SCRIPT"

  echo "Generating flamegraph."
  if is_gke; then
    toolbox bash -c "cd /media/root/$OUTDIR && zcat $OUTFILE_PERF_SCRIPT | stackcollapse-perf.pl --kernel | flamegraph.pl --hash --colors=perl >$OUTFILE_FLAMEGRAPH"
  else
    zcat "$OUTFILE_PERF_SCRIPT" | stackcollapse-perf.pl --kernel | flamegraph.pl --hash --colors=perl >"$OUTFILE_FLAMEGRAPH"
  fi

  # Show user where the output is.
  echo
  echo "Results:"
  echo "Flamegraph:       ${OUTDIR}/${OUTFILE_FLAMEGRAPH}"
  echo "Raw stack traces: ${OUTDIR}/${OUTFILE_PERF_SCRIPT}"
}

main "$@"
