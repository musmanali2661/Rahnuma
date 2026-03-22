#!/usr/bin/env bash
# =============================================================================
# Rahnuma — Start OSRM routing engine
# Preprocesses Pakistan OSM data (first time) and starts the HTTP server.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
OSM_DIR="$DATA_DIR/osm"
OSRM_DIR="$DATA_DIR/osrm"
OSM_PBF="$OSM_DIR/pakistan-latest.osm.pbf"
OSRM_FILE="$OSRM_DIR/pakistan-latest.osrm"
OSRM_PORT="${OSRM_PORT:-5000}"
GEOFABRIK_URL="https://download.geofabrik.de/asia/pakistan-latest.osm.pbf"
PROFILE="${OSRM_PROFILE:-/opt/car.lua}"  # configurable via OSRM_PROFILE env var

mkdir -p "$OSM_DIR" "$OSRM_DIR"

# ── Download OSM extract if missing ──────────────────────────────────────────
if [ ! -f "$OSM_PBF" ]; then
  echo "[OSRM] Downloading Pakistan OSM extract (~1.5 GB)…"
  wget -c -O "$OSM_PBF" "$GEOFABRIK_URL"
fi

# ── OSRM preprocessing ───────────────────────────────────────────────────────
if [ ! -f "$OSRM_FILE" ]; then
  echo "[OSRM] Preprocessing Pakistan data (this takes 15-60 minutes)…"

  # Copy PBF to OSRM dir
  cp "$OSM_PBF" "$OSRM_DIR/pakistan-latest.osm.pbf"

  docker run --rm -v "$OSRM_DIR:/data" \
    ghcr.io/project-osrm/osrm-backend:v5.27.1 \
    osrm-extract -p "$PROFILE" /data/pakistan-latest.osm.pbf

  docker run --rm -v "$OSRM_DIR:/data" \
    ghcr.io/project-osrm/osrm-backend:v5.27.1 \
    osrm-partition /data/pakistan-latest.osrm

  docker run --rm -v "$OSRM_DIR:/data" \
    ghcr.io/project-osrm/osrm-backend:v5.27.1 \
    osrm-customize /data/pakistan-latest.osrm

  echo "[OSRM] Preprocessing complete."
fi

# ── Start OSRM server ─────────────────────────────────────────────────────────
echo "[OSRM] Starting OSRM server on port $OSRM_PORT…"
docker run --rm -p "$OSRM_PORT:5000" -v "$OSRM_DIR:/data" \
  ghcr.io/project-osrm/osrm-backend:v5.27.1 \
  osrm-routed --algorithm mld /data/pakistan-latest.osrm \
  --max-table-size 1000 \
  --max-matching-size 5000
