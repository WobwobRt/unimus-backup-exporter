#!/bin/bash
set -e

INTERVAL="${EXPORT_INTERVAL_SECONDS:-86400}"  # default: once a day

cat > /exporter/unimus-backup-exporter.env <<EOF
unimus_server_address="${UNIMUS_SERVER_ADDRESS}"
unimus_api_key="${UNIMUS_API_KEY}"
backup_type="${BACKUP_TYPE:-latest}"
export_type="${EXPORT_TYPE:-fs}"
separator="${SEPARATOR:-_}"
EOF

while true; do
  echo "$(date '+%F %T') Starting Unimus backup export..."
  /exporter/unimus-backup-exporter.sh || echo "$(date '+%F %T') Export FAILED"
  echo "$(date '+%F %T') Sleeping for ${INTERVAL}s"
  sleep "$INTERVAL"
done
