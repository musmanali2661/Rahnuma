'use strict';

const fs = require('fs');
const path = require('path');

const PACKAGES_DIR = process.env.OFFLINE_PACKAGES_DIR || path.join(__dirname, '../../../data/offline_packages');

// Cities available for offline download
const AVAILABLE_CITIES = [
  { id: 'karachi', name: 'Karachi', size_mb: 450 },
  { id: 'lahore', name: 'Lahore', size_mb: 380 },
  { id: 'islamabad', name: 'Islamabad', size_mb: 120 },
  { id: 'rawalpindi', name: 'Rawalpindi', size_mb: 150 },
  { id: 'faisalabad', name: 'Faisalabad', size_mb: 200 },
  { id: 'multan', name: 'Multan', size_mb: 160 },
  { id: 'peshawar', name: 'Peshawar', size_mb: 130 },
  { id: 'quetta', name: 'Quetta', size_mb: 110 },
];

/**
 * List available offline packages with download status.
 */
async function listPackages() {
  return AVAILABLE_CITIES.map((city) => {
    const filePath = path.join(PACKAGES_DIR, `${city.id}.mbtiles`);
    const available = fs.existsSync(filePath);
    const stats = available ? fs.statSync(filePath) : null;
    return {
      ...city,
      available,
      file_size_bytes: stats ? stats.size : null,
      last_updated: stats ? stats.mtime.toISOString() : null,
    };
  });
}

/**
 * Get the local file path for a city package.
 */
async function getPackagePath(cityId) {
  const city = AVAILABLE_CITIES.find((c) => c.id === cityId);
  if (!city) return null;
  return path.join(PACKAGES_DIR, `${city.id}.mbtiles`);
}

module.exports = { listPackages, getPackagePath, AVAILABLE_CITIES };
