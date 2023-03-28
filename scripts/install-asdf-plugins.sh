#!/usr/bin/env bash

# This script will install the ASDF plugins required for this project

set -euo pipefail
IFS=$'\n\t'

# shellcheck source=/dev/null
source "$ASDF_DIR/asdf.sh"

plugin_list=$(asdf plugin list || echo)

update_ruby_build() {
  # If ruby is installed
  if [[ -d $(asdf where ruby) ]]; then
    # Then so is rbenv and ruby-build
    echo "# Updating ruby-build"
    # Make sure ruby-build has the latest ruby versions releases list
    asdf plugin update ruby
  fi
}

install_plugin() {
  local plugin=$1

  if ! echo "${plugin_list}" | grep -q "${plugin}"; then
    echo "# Installing plugin" "$@"
    asdf plugin add "$@" || {
      echo "Failed to install plugin:" "$@"
      exit 1
    } >&2
  fi

  [[ "${plugin}" == 'ruby' ]] && update_ruby_build
  echo "# Installing ${plugin} version"
  asdf install "${plugin}" || {
    echo "Failed to install plugin version: ${plugin}"
    exit 1
  } >&2

  # Use this plugin for the rest of the install-asdf-plugins.sh script...
  asdf shell "${plugin}" "$(asdf current "${plugin}" | awk '{print $2}')"
}

remove_plugin_with_source() {
  local plugin=$1
  local source=$2

  if ! asdf plugin list --urls | grep -qF "${source}"; then
    return
  fi

  echo "# Removing plugin ${plugin} installed from ${source}"
  asdf plugin remove "${plugin}" || {
    echo "Failed to remove plugin: ${plugin}"
    exit 1
  } >&2

  # Refresh list of installed plugins.
  plugin_list=$(asdf plugin list)
}

check_global_golang_install() {
  (
    pushd /
    asdf current golang
    popd
  ) >/dev/null 2>/dev/null
}

# Install golang first as some of the other plugins require it.
install_plugin golang

if [[ -z "${CI:-}" ]]; then
  # The go-jsonnet plugin requires a global golang version to be configured
  # and will otherwise fail to install.
  #
  # This check is not necessary in CI.
  GOLANG_VERSION=$(asdf current golang | awk '{print $2}')

  if ! check_global_golang_install; then
    cat <<-EOF
---------------------------------------------------------------------------------------
The go-jsonnet plugin requires a global golang version to be configured.$
Suggestion: run this command to set this up: 'asdf global golang ${GOLANG_VERSION}'
Then rerun this command.

Note: you can undo this change after running this command by editing ~/.tool-versions
---------------------------------------------------------------------------------------
EOF
    exit 1
  fi
fi

# The location of the Thanos plugin has changed. Remove old
# plugin if it hasn't been migrated to the new source yet.
remove_plugin_with_source thanos \
  https://gitlab.com/gitlab-com/gl-infra/asdf-thanos.git

# The location of the jsonnet-tool plugin has changed. Remove old
# plugin if it hasn't been migrated to the new source yet.
remove_plugin_with_source jsonnet-tool \
  https://gitlab.com/gitlab-com/gl-infra/asdf-jsonnet-tool.git

install_plugin go-jsonnet
install_plugin jb
install_plugin shellcheck
install_plugin shfmt
install_plugin terraform
install_plugin promtool https://gitlab.com/gitlab-com/gl-infra/asdf-promtool.git
install_plugin thanos https://gitlab.com/gitlab-com/gl-infra/asdf-promtool.git
install_plugin amtool https://gitlab.com/gitlab-com/gl-infra/asdf-promtool.git
install_plugin jsonnet-tool https://gitlab.com/gitlab-com/gl-infra/asdf-gl-infra.git
install_plugin ruby
install_plugin nodejs
install_plugin yq
install_plugin pre-commit
install_plugin python
