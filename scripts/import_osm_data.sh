#!/usr/bin/env bash
# =============================================================================
# Rahnuma — Import OSM data into PostgreSQL/PostGIS
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data/osm"
OSM_PBF="$DATA_DIR/pakistan-latest.osm.pbf"
GEOFABRIK_URL="https://download.geofabrik.de/asia/pakistan-latest.osm.pbf"

# Load env vars
if [ -f "$SCRIPT_DIR/../.env" ]; then
  # shellcheck source=/dev/null
  set -a; source "$SCRIPT_DIR/../.env"; set +a
fi

DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-rahnuma}"
DB_USER="${POSTGRES_USER:-rahnuma}"
DB_PASS="${POSTGRES_PASSWORD:-rahnuma_secret}"
OSM2PGSQL_CACHE="${OSM2PGSQL_CACHE:-4096}"

mkdir -p "$DATA_DIR"

# ── Download if missing ───────────────────────────────────────────────────────
if [ ! -f "$OSM_PBF" ]; then
  echo "[import] Downloading Pakistan OSM extract (~1.5 GB)…"
  wget -c -O "$OSM_PBF" "$GEOFABRIK_URL"
fi

# ── Wait for PostgreSQL ───────────────────────────────────────────────────────
echo "[import] Waiting for PostgreSQL…"
until PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &>/dev/null; do
  sleep 2
done
echo "[import] PostgreSQL is ready."

# ── Import into PostGIS using osm2pgsql ──────────────────────────────────────
echo "[import] Running osm2pgsql (cache=${OSM2PGSQL_CACHE}MB)…"
PGPASSWORD="$DB_PASS" osm2pgsql \
  --host "$DB_HOST" \
  --port "$DB_PORT" \
  --database "$DB_NAME" \
  --username "$DB_USER" \
  --hstore \
  --slim \
  --cache "$OSM2PGSQL_CACHE" \
  --tag-transform-script /usr/share/osm2pgsql/default.lua \
  "$OSM_PBF"

# ── Extract POIs into separate table ─────────────────────────────────────────
echo "[import] Extracting POIs…"
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<'SQL'
INSERT INTO pois (osm_id, name, category, location, tags)
SELECT
    osm_id,
    tags->'name' AS name,
    CASE
        WHEN tags->'amenity' = 'fuel'              THEN 'petrol'
        WHEN tags->'amenity' = 'restaurant'        THEN 'food'
        WHEN tags->'amenity' = 'place_of_worship'  THEN 'mosque'
        WHEN tags->'amenity' = 'hospital'          THEN 'hospital'
        ELSE tags->'amenity'
    END AS category,
    ST_Transform(way, 4326) AS location,
    tags
FROM planet_osm_point
WHERE tags->'amenity' IN ('fuel','restaurant','place_of_worship','hospital','pharmacy','bank','atm')
ON CONFLICT (osm_id) DO UPDATE
    SET name = EXCLUDED.name,
        tags = EXCLUDED.tags;
SQL

echo "[import] Done. OSM data imported into '$DB_NAME'."
