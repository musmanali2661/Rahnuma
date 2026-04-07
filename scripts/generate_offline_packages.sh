#!/usr/bin/env bash
# =============================================================================
# Rahnuma — Generate offline map packages for all major cities
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../data/offline_packages"

echo "[offline] Generating city MBTiles packages…"
python3 "$PACKAGES_DIR/generate_cities.py" "$@"
echo "[offline] Done."
