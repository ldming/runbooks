#!/usr/bin/env bash

# Purpose:
# Find and kill "git pack-objects" processes that are associated with a client running "git fetch" or similar.
# The "git pack-objects" command can be spawned by several other git commands or called directly.
# We want to avoid terminating a "git pack-objects" process if it is supporting important maintenance tasks like garbage collection.
#
# Background:
# There are 2 usage patterns for spawning a "git pack-objects" process in support of a client fetching/cloning a repo:
# 1. "git pack-objects" was spawned directly by "git upload-pack".
#    * This is the native git pattern, but it should no longer occur on production Gitaly nodes where Gitaly's pack-objects-cache is enabled.
# 2. "git pack-objects" was spawned by "gitaly" itself, in response to "gitaly-hooks" calling back to "gitaly" to check its pack-objects-cache.
#    * This pattern was introduced as part of the pack-objects-cache workflow:
#      * The "gitaly" process spawns "git upload-pack" with a custom CLI config setting for "uploadpack.packObjectsHook" to run "gitaly-hooks" instead of "git pack-objects".
#      * The "git upload-pack" process spawns "gitaly-hooks git pack-objects", which calls back to "gitaly".
#      * Gitaly checks its pack-objects-cache, and if there is no hit, it spawns a normal "git pack-objects" process and feeds the results back through "gitaly-hooks" to "git upload-pack".
#    * Example process hierarchy:
#        gitaly ...                                       # the long-lived gitaly process
#        \_ git ... upload-pack ...                       # the "upload-pack" git subcommand that spawns "gitaly-hooks" instead of "git pack-objects"
#        |   \_ gitaly-hooks git ... pack-objects ...     # the "gitaly-hooks" process that calls back to "gitaly" to either read from the pack-objects cache or spawn a "git pack-objects" process
#        \_ git ... pack-objects ... pack-objects ...     # on cache miss for gitaly's pack-objects-cache, it spawns a normal "git pack-objects" process and passes the results back up the call chain

TARGET_GIT_DIR=$1

# Validate input.
[[ -z $TARGET_GIT_DIR ]] && {
  echo "Usage: $0 [git_dir]"
  exit 1
}
[[ $TARGET_GIT_DIR =~ \.git$ ]] || {
  echo "ERROR: Please check the git repo path (it should end in .git): $TARGET_GIT_DIR"
  exit 1
}
sudo ls -ld "$TARGET_GIT_DIR" | grep -q '^d' || {
  echo "ERROR: git repo dir is not a directory: $TARGET_GIT_DIR"
  exit 1
}

# Check all "git pack-objects" processes running with the "--stdout" argument.
for PACK_PID in $(pgrep -f 'git .*pack-objects .*--stdout'); do
  # Skip unless the executable is named "git".
  # Note: This skips "gitaly-hook" processes that are called with matching arguments "git ... pack-objects".
  ps -p "$PACK_PID" -o comm= | grep -q '^git$' || continue

  # Skip unless the pack-objects process refers to the target git repo dir.
  # Note: Gitaly consistently passes the "--git-dir" argument to "git", so we no longer need to check the current dir of the process.
  ps -p "$PACK_PID" -ww -o args= | grep -q "$TARGET_GIT_DIR" || continue

  # Skip unless the parent process is either "git upload-pack" or "gitaly" (respectively use cases 1 and 2).
  PARENT_PID=$(ps -p "$PACK_PID" -o ppid:1=)
  ps -p "$PARENT_PID" -ww -o args= | grep -q -e 'git .*upload-pack' -e 'gitaly ' || continue

  # Show the matching process to kill.
  echo 'Found a "git pack-objects" process that appears to support an upload-pack either directly or via a gitaly-hooks callback to gitaly:'
  ps uwwf -p "$PACK_PID"
  sudo cat "/proc/$PACK_PID/environ" | tr '\0' '\n' | grep 'CORRELATION_ID'

  if [[ -n $DRY_RUN ]]; then
    echo "Would kill git pack-objects PID: $PACK_PID"
  else
    echo "Killing git pack-objects PID: $PACK_PID"
    sudo kill "$PACK_PID"
  fi
done
