#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

./scripts/check-prereqs.sh

WG_DATA_DIR="$(awk -F= '
  $0 ~ /^[[:space:]]*#/ { next }
  $0 ~ /^[[:space:]]*$/ { next }
  index($0, "WG_DATA_DIR=") == 1 {
    sub(/^[^=]*=/, "", $0)
    print $0
    exit
  }
' .env)"

mkdir -p "$WG_DATA_DIR"
docker compose up -d
docker compose ps
