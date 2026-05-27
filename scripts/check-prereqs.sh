#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

error() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "$1 is not installed or not on PATH."
}

env_get() {
  awk -F= -v key="$1" '
    $0 ~ /^[[:space:]]*#/ { next }
    $0 ~ /^[[:space:]]*$/ { next }
    index($0, key "=") == 1 {
      sub(/^[^=]*=/, "", $0)
      print $0
      found=1
      exit
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' .env
}

env_has_key() {
  awk -F= -v key="$1" '
    $0 ~ /^[[:space:]]*#/ { next }
    $0 ~ /^[[:space:]]*$/ { next }
    index($0, key "=") == 1 { found=1; exit }
    END { exit(found ? 0 : 1) }
  ' .env
}

is_valid_port() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

data_dir_initialized() {
  if [ ! -d "$WG_DATA_DIR" ]; then
    return 1
  fi

  find "$WG_DATA_DIR" -mindepth 1 -print -quit 2>/dev/null | grep -q .
}

require_command docker
docker info >/dev/null 2>&1 || error "Docker daemon is not reachable."
docker compose version >/dev/null 2>&1 || error "Docker Compose plugin is not available."

[ -f .env ] || error ".env file not found. Copy .env.example to .env first."

INSECURE="$(trim "$(env_get INSECURE 2>/dev/null || true)")"
INIT_ENABLED="$(trim "$(env_get INIT_ENABLED 2>/dev/null || true)")"
INIT_USERNAME="$(trim "$(env_get INIT_USERNAME 2>/dev/null || true)")"
INIT_PASSWORD="$(trim "$(env_get INIT_PASSWORD 2>/dev/null || true)")"
INIT_HOST="$(trim "$(env_get INIT_HOST 2>/dev/null || true)")"
INIT_PORT="$(trim "$(env_get INIT_PORT 2>/dev/null || true)")"
WG_PORT="$(trim "$(env_get WG_PORT 2>/dev/null || true)")"
WG_UI_PORT="$(trim "$(env_get WG_UI_PORT 2>/dev/null || true)")"
WG_DATA_DIR="$(trim "$(env_get WG_DATA_DIR 2>/dev/null || true)")"
INIT_IPV4_CIDR="$(trim "$(env_get INIT_IPV4_CIDR 2>/dev/null || true)")"
INIT_IPV6_CIDR="$(trim "$(env_get INIT_IPV6_CIDR 2>/dev/null || true)")"

[ -n "$INSECURE" ] || error "INSECURE must be set in .env."
[ "$INIT_ENABLED" = "true" ] || error "INIT_ENABLED must be set to true for this starter."
[ -n "$INIT_HOST" ] || error "INIT_HOST must not be empty."
[ "$INIT_HOST" != "change-me.example.com" ] || error "INIT_HOST is still set to change-me.example.com. Set it to your public IP or DNS name."
[ -n "$WG_DATA_DIR" ] || error "WG_DATA_DIR must not be empty."

is_valid_port "$INIT_PORT" || error "INIT_PORT must be a valid port number from 1 to 65535."
is_valid_port "$WG_PORT" || error "WG_PORT must be a valid port number from 1 to 65535."
is_valid_port "$WG_UI_PORT" || error "WG_UI_PORT must be a valid port number from 1 to 65535."
[ "$INIT_PORT" = "$WG_PORT" ] || error "INIT_PORT must match WG_PORT for this starter."

if [ -n "$INIT_IPV4_CIDR" ] || [ -n "$INIT_IPV6_CIDR" ]; then
  [ -n "$INIT_IPV4_CIDR" ] || error "INIT_IPV4_CIDR must be set when INIT_IPV6_CIDR is set."
  [ -n "$INIT_IPV6_CIDR" ] || error "INIT_IPV6_CIDR must be set when INIT_IPV4_CIDR is set."
fi

if data_dir_initialized; then
  warn "INIT_* values are only used on the first container start. Existing data in WG_DATA_DIR will not be reinitialized."
  warn "Changing INIT_* values in .env will not reconfigure this existing deployment."
  if [ -z "$INIT_USERNAME" ] || [ -z "$INIT_PASSWORD" ]; then
    warn "INIT_USERNAME and INIT_PASSWORD are blank, which is acceptable for an already-initialized deployment."
  fi
else
  [ -n "$INIT_USERNAME" ] || error "INIT_USERNAME must not be empty for the first bootstrap."
  [ -n "$INIT_PASSWORD" ] || error "INIT_PASSWORD must not be empty for the first bootstrap."
  warn "INIT_* values seed the first boot only."
  warn "Remove INIT_USERNAME and INIT_PASSWORD from .env only after the first successful bootstrap and only for already-initialized deployments."
fi

warn "WG_UI_PORT exposure cannot be reliably validated locally. Restrict UI access with firewall rules, localhost binding, or an SSH tunnel."

printf 'Prerequisite checks passed.\n'
