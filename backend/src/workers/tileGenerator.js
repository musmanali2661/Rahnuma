'use strict';

const { execSync } = require('child_process');
const path = require('path');
const logger = require('../utils/logger');

const PACKAGES_DIR = process.env.OFFLINE_PACKAGES_DIR || path.join(__dirname, '../../../data/offline_packages');

/**
 * Generate a MBTiles package for a city using mbutil/tilemill (placeholder).
 * In a real deployment this would invoke a tile generation pipeline.
 */
async function generateCityTiles(cityId, bbox, minZoom = 10, maxZoom = 16) {
  logger.info(`Generating tiles for ${cityId}`, { bbox, minZoom, maxZoom });

  // In Phase 1 this is a placeholder; actual generation happens via generate_offline_packages.sh
  // The script uses tippecanoe + osmium to extract and package tiles.
  logger.info(`Tile generation for ${cityId} queued (run scripts/generate_offline_packages.sh)`);
}

module.exports = { generateCityTiles };
