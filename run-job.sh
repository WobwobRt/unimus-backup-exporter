#!/bin/bash
set -euo pipefail

LOCK_FILE="/tmp/unimus-export.lock"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "$(date '+%F %T') Previous export still running, skipping this run"
  exit 0
fi

echo "$(date '+%F %T') Starting Unimus backup export..."
if /exporter/unimus-backup-exporter.sh; then
  echo "$(date '+%F %T') Export succeeded"
else
  rc=$?
  echo "$(date '+%F %T') Export FAILED (exit $rc)" >&2
  exit "$rc"
fi
