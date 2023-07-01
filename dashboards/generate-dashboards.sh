#!/usr/bin/env bash
# vim: ai:ts=2:sw=2:expandtab

set -euo pipefail
# Also fail when subshells fail
shopt -s inherit_errexit || true # Not all bash shells have this

IFS=$'\n\t'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}"

source "grafana-tools.lib.sh"

usage() {
  cat <<-EOF
  Usage $0 [Dh]

  DESCRIPTION
    This script generates dashboards manifest files.

    Useful for testing.

  FLAGS
    -D  run in Dry-run
    -h  help

EOF
}

args=("$@")

while getopts ":Dh" o; do
  case "${o}" in
  D)
    dry_run="true"
    ;;
  h)
    usage
    exit 0
    ;;
  *) ;;

  esac
done

shift $((OPTIND - 1))

dry_run=${dry_run:-}

prepare

rm -f generated/*/summary.txt

./find-dashboards.sh | xargs -n1 -P "$(nproc)" ./generate-dashboard.sh "${args[@]}"
