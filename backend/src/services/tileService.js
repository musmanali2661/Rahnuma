'use strict';

const TILE_SERVER_URL = process.env.TILE_SERVER_URL || 'http://localhost:3000';

/**
 * Build a tile URL for the frontend.
 */
function getTileUrl(layer = 'rahnuma') {
  return `${TILE_SERVER_URL}/${layer}/{z}/{x}/{y}`;
}

/**
 * Return available tile layers.
 */
function getLayers() {
  return [
    { id: 'rahnuma', name: 'Rahnuma (Default)', url: getTileUrl('rahnuma') },
    { id: 'satellite', name: 'Satellite', url: getTileUrl('satellite') },
  ];
}

module.exports = { getTileUrl, getLayers };
