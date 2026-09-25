#!/bin/bash
set -euo pipefail

ENV_FILE="/exporter/unimus-backup-exporter.env"
CRONTAB_FILE="/exporter/crontab"

resolve() {
  local var_name="$1"
  local file_var="${var_name}_FILE"
  if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
    cat "${!file_var}"
  else
    echo "${!var_name:-}"
  fi
}

write_setting() {
  local key="$1" value="$2"
  [ -n "$value" ] && printf '%s="%s"\n' "$key" "$value" >> "$ENV_FILE"
  return 0
}

generate_env_file() {
  : > "$ENV_FILE"
  write_setting "unimus_server_address" "${UNIMUS_SERVER_ADDRESS:-}"
  write_setting "unimus_api_key"        "$(resolve UNIMUS_API_KEY)"
  write_setting "backup_type"           "${BACKUP_TYPE:-latest}"
  write_setting "export_type"           "${EXPORT_TYPE:-fs}"
  write_setting "insecure"              "${UNIMUS_INSECURE:-}"
  write_setting "separator"             "${SEPARATOR:-}"
  write_setting "device_name_field"     "${DEVICE_NAME_FIELD:-}"
  write_setting "page_size"             "${PAGE_SIZE:-}"

  if [ "${EXPORT_TYPE:-fs}" = "git" ]; then
    write_setting "git_username"        "${GIT_USERNAME:-}"
    write_setting "git_password"        "$(resolve GIT_PASSWORD)"
    write_setting "git_email"           "${GIT_EMAIL:-}"
    write_setting "git_server_protocol" "${GIT_SERVER_PROTOCOL:-ssh}"
    write_setting "git_server_address"  "${GIT_SERVER_ADDRESS:-}"
    write_setting "git_port"            "${GIT_PORT:-}"
    write_setting "git_repo_name"       "${GIT_REPO_NAME:-}"
    write_setting "git_branch"          "${GIT_BRANCH:-master}"
  fi
}

setup_ssh() {
  [ "${EXPORT_TYPE:-fs}" = "git" ] || return 0
  [ "${GIT_SERVER_PROTOCOL:-ssh}" = "ssh" ] || return 0

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ -n "${SSH_PRIVATE_KEY_FILE:-}" ] && [ -f "${SSH_PRIVATE_KEY_FILE}" ]; then
    cp "${SSH_PRIVATE_KEY_FILE}" "$HOME/.ssh/id_ed25519"
    chmod 600 "$HOME/.ssh/id_ed25519"
  fi

  if [ -n "${GIT_SERVER_ADDRESS:-}" ] && [ ! -f "$HOME/.ssh/known_hosts" ]; then
    ssh-keyscan -p "${GIT_PORT:-22}" "${GIT_SERVER_ADDRESS}" >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
  fi
}

validate() {
  local missing=0
  [ -z "${UNIMUS_SERVER_ADDRESS:-}" ] && { echo "ERROR: UNIMUS_SERVER_ADDRESS not set" >&2; missing=1; }
  [ -z "$(resolve UNIMUS_API_KEY)" ] && { echo "ERROR: UNIMUS_API_KEY(_FILE) not set" >&2; missing=1; }
  [ -z "${CRON_SCHEDULE:-}" ] && { echo "ERROR: CRON_SCHEDULE not set, e.g. '0 3 * * *'" >&2; missing=1; }
  [ "$missing" -eq 0 ] || exit 1
}

write_crontab() {
  # supercronic's format: standard 5-field cron expression + command, one job per line
  echo "${CRON_SCHEDULE} /exporter/run-job.sh" > "$CRONTAB_FILE"
}

# ---- main ----
validate
generate_env_file
setup_ssh

if [ "${RUN_ONCE:-false}" = "true" ]; then
  /exporter/run-job.sh
  exit 0
fi

write_crontab
echo "$(date '+%F %T') Schedule: '${CRON_SCHEDULE}' (TZ=${TZ:-UTC})"
exec supercronic "$CRONTAB_FILE"
