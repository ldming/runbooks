#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

REPO_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  pwd
)

# Check that jsonnet-tool is installed
"${REPO_DIR}/scripts/ensure-jsonnet-tool.sh"

function render_multi_jsonnet() {
  local dest_dir="$1"
  local filename="$2"

  local warning="# WARNING. DO NOT EDIT THIS FILE BY HAND. RUN ./scripts/generate-reference-architecture-configs.sh TO GENERATE IT. YOUR CHANGES WILL BE OVERRIDDEN"

  set -x
  rm -rf "$dest_dir"
  jsonnet-tool render \
    --multi "$dest_dir" \
    --header "${warning}" \
    -J "${REPO_DIR}/libsonnet/" \
    -J "$(dirname "$filename")" \
    -J "${REPO_DIR}/vendor/" \
    "${filename}"
}

for i in "${REPO_DIR}"/reference-architectures/*/src/generate.jsonnet; do
  dir=$(
    cd "$(dirname "$i")/.."
    pwd
  )
  rm -rf "${dir}/config"
  render_multi_jsonnet "${dir}/config" "$i"
done