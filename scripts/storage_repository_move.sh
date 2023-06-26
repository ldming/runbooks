#!/usr/bin/env bash
#
# Description: Move a single project to a new file server with the API.

set -uo pipefail

usage() {
  echo "usage: $(basename "$0") <project> <nfs-fileXX>"
}

if [[ $# -ne 2 ]]; then
  usage
  exit
fi

project="$1"
storage_target="$2"

if [[ -z ${GITLAB_GPRD_ADMIN_API_PRIVATE_TOKEN-} ]]; then
  echo 'ERROR: Missing GITLAB_GPRD_ADMIN_API_PRIVATE_TOKEN env var'
  exit 1
fi

projects_api_url='https://gitlab.com/api/v4/projects'

curl_project_api() {
  local uri="$1"
  shift
  curl "$@" \
    --silent \
    --fail \
    --header "Private-Token: ${GITLAB_GPRD_ADMIN_API_PRIVATE_TOKEN}" \
    --header 'Content-Type: application/json' \
    "${projects_api_url}/${uri}"
}

get_project_json() {
  curl_project_api "$(echo -n "$1" | jq -sRr '@uri')"
}

is_move_finished() {
  local state
  state="$(curl_project_api "$1" | jq '.state')"
  if [[ ${state} == "finished" ]]; then
    return 0
  fi
  return 1
}

project_json=$(get_project_json "${project}")

if [[ -z ${project_json} ]]; then
  echo "ERROR: Unable to get project json for '${project}'"
  exit 1
fi

project_id="$(echo -n "${project_json}" | jq -r '.id')"

if [[ ! ${project_id} -gt 0 ]]; then
  echo "ERROR: Unable to get project ID for '${project}'"
  exit 1
fi

original_storage_target="$(curl_project_api "${project_id}" | jq -r '.repository_storage')"

if [[ ${original_storage_target} == "${storage_target}" ]]; then
  echo "INFO: Project already on ${original_storage_target}"
  exit 0
fi

echo "INFO: Starting move of '${project}' (id=${project_id}) from ${original_storage_target} to ${storage_target}"

destination_json="{\"destination_storage_name\": \"${storage_target}\"}"
move_json="$(curl_project_api "${project_id}/repository_storage_moves" --request POST --data "${destination_json}")"

move_id="$(echo -n "${move_json}" | jq -r '.id')"

if [[ ! ${move_id} -gt 0 ]]; then
  echo "ERROR: Unable to start move '${move_json}'"
  exit 1
fi

echo "INFO: Move started, id=${move_id}"

sleep 5

status_uri="${project_id}/repository_storage_moves/${move_id}"

while is_move_finished "${status_uri}"; do
  echo "INFO: Still moving"
  sleep 5
done

new_storage_target="$(get_project_json "${project}" | jq -r '.repository_storage')"

if [[ ${storage_target} == "${new_storage_target}" ]]; then
  echo "INFO: Completed move to ${new_storage_target}"
else
  echo "INFO: Error moving, still on ${new_storage_target}"
  exit 1
fi
