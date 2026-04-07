#!/usr/bin/env bash
# =============================================================================
# Rahnuma — Start Martin vector tile server
# =============================================================================
set -euo pipefail

if [ -f "$(dirname "$0")/../.env" ]; then
  set -a; source "$(dirname "$0")/../.env"; set +a
fi

TILE_PORT="${TILE_SERVER_PORT:-3000}"
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-rahnuma}"
DB_USER="${POSTGRES_USER:-rahnuma}"
DB_PASS="${POSTGRES_PASSWORD:-rahnuma_secret}"

DATABASE_URL="postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "[martin] Starting tile server on port $TILE_PORT…"
docker run --rm \
  -p "$TILE_PORT:3000" \
  -e DATABASE_URL="$DATABASE_URL" \
  -v "$(pwd)/data/styles:/styles:ro" \
  ghcr.io/maplibre/martin:v0.14.3 \
  --listen-addresses "0.0.0.0:3000"
