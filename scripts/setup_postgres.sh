#!/usr/bin/env bash
# =============================================================================
# Rahnuma — Set up PostgreSQL with PostGIS and run migrations
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../backend/src/database/migrations"

if [ -f "$SCRIPT_DIR/../.env" ]; then
  set -a; source "$SCRIPT_DIR/../.env"; set +a
fi

DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-rahnuma}"
DB_USER="${POSTGRES_USER:-rahnuma}"
DB_PASS="${POSTGRES_PASSWORD:-rahnuma_secret}"

echo "[setup] Waiting for PostgreSQL at $DB_HOST:$DB_PORT…"
until PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &>/dev/null; do
  sleep 2
done

echo "[setup] Running migrations…"
for sql in "$MIGRATIONS_DIR"/*.sql; do
  echo "[setup] Applying $sql…"
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql"
done

echo "[setup] Database setup complete."
