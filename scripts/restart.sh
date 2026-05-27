#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

./scripts/check-prereqs.sh
docker compose up -d --force-recreate
docker compose ps
