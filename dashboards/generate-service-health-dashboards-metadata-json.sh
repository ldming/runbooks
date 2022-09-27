#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}" || exit

source "grafana-tools.lib.sh"

TEMPFILE="tempfile.json"
FILE="${SCRIPT_DIR}/service_health_dashboards.json"

usage() {
  cat <<-EOF
  Usage [Dh]

  DESCRIPTION
    This script checks the existence of any dashboards defined in
    "dashboards/**/*.dashboard.jsonnet" files and collates the result
    in a JSON file

    GRAFANA_API_TOKEN must be set in the environment

    Useful for testing.

  FLAGS
    -D  run in Dry-run
    -h  help

EOF
}

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

if [[ -z $dry_run && -z ${GRAFANA_API_TOKEN:-} ]]; then
  echo "You must set GRAFANA_API_TOKEN to use this script, or run in dry run mode"
  usage
  exit 1
fi

prepare

trap 'rm -rf "${TEMPFILE}"' EXIT

find_dashboards | while read -r line; do
  basename=$(basename "$line")
  relative=${line#"./"}
  folder=${GRAFANA_FOLDER:-$(dirname "$relative")}

  uid="${folder}-${basename%%.*}"
  if response=$(call_grafana_api "https://dashboards.gitlab.net/api/dashboards/uid/$uid"); then
    url=$(echo "${response}" | jq '.meta.url' | tr -d '"')
    fullurl="https://dashboards.gitlab.net$url"

    if test -f "$TEMPFILE"; then
      cat <<<"$(jq ".\"$folder\" |= .+ [\"$fullurl\"]" $TEMPFILE)" >$TEMPFILE
    else
      echo "{\"$folder\": [\"$fullurl\"]}" >$TEMPFILE
    fi
  fi
done

if [[ -n $dry_run ]]; then
  cat $TEMPFILE | jq '.'
  rm $TEMPFILE
else
  cat <<<"$(jq '.' $TEMPFILE)" >"$FILE"
fi
