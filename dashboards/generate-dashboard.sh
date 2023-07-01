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
  Usage $0 [Dh] DASHBOARD-JSONNET-FILE

  DESCRIPTION
    Generate a single dashboard manifest file.

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

prepare

mkdir -p 'generated'

line="$1"
relative=${line#"./"}
folder=${GRAFANA_FOLDER:-$(dirname "$relative")}

mkdir -p "generated/${folder}"

generate_dashboards_for_file "${line}" | while IFS= read -r manifest; do
  if [ -z "$manifest" ]; then
    echo "warning: empty dashboard for $line"
    continue
  fi

  IFS='|' read -r uid title < <(echo "$manifest" | jq -r '[.uid, .title] | join("|")')
  if [ -z "$uid" ] || [ -z "$title" ]; then
    echo "Warning: empty dashboard for $line"
    continue
  fi

  echo "title: $title" >>"generated/${folder}/summary.txt"
  echo "uid: $uid" >>"generated/${folder}/summary.txt"

  if [[ -n $dry_run ]]; then
    echo "Dry Run: Would have written generated manifest for ${uid} with title ${title} in dashboards/generated/$folder/$uid.json"
  else
    echo "$manifest" >"generated/${folder}/${uid}.json"
    echo "Wrote generated manifest for ${uid} in dashboards/generated/$folder/$uid.json"
  fi
done
