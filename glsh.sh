#!/usr/bin/env bash

set -eufo pipefail

export RUNBOOKS_PATH
if [[ $(uname -s) == "Darwin" ]]; then
  RUNBOOKS_PATH=$(dirname "$(readlink "$0")")
else
  RUNBOOKS_PATH=$(dirname "$(readlink -f "$0")")
fi

BIN_DIR="$RUNBOOKS_PATH/bin"

if [[ $# -eq 0 ]]; then
  SUBCMD="help"
else
  # Remove the first paramater so we can send the rest to the executable
  SUBCMD="$1"
  shift
fi

EXEC_PATH="$BIN_DIR/$SUBCMD"

if [[ ! -f $EXEC_PATH ]]; then
  echo >&2 "glsh: executable path not found: $EXEC_PATH "
  exit 1
fi

if [[ ! -x $EXEC_PATH ]]; then
  echo >&2 "glsh: File not executable, please run: chmod +x $EXEC_PATH"
  exit 1
fi

exec "$EXEC_PATH" "$@"
