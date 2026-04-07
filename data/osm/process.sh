#!/usr/bin/env bash
# =============================================================================
# Rahnuma — OSM data processing helper
# Downloads and validates the Pakistan OSM extract.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSM_DIR="$SCRIPT_DIR"
OSM_PBF="$OSM_DIR/pakistan-latest.osm.pbf"
GEOFABRIK_URL="https://download.geofabrik.de/asia/pakistan-latest.osm.pbf"
CHECKSUM_URL="${GEOFABRIK_URL}.md5"

mkdir -p "$OSM_DIR"

echo "[osm] Downloading Pakistan extract…"
wget -c -O "$OSM_PBF" "$GEOFABRIK_URL"

echo "[osm] Verifying checksum…"
wget -qO "$OSM_PBF.md5" "$CHECKSUM_URL"
md5sum -c "$OSM_PBF.md5"

echo "[osm] Done: $OSM_PBF"
