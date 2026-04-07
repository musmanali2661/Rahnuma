'use strict';

/**
 * Decode a Google/OSRM polyline-encoded string.
 *
 * @param {string} encoded  Encoded polyline string
 * @param {number} precision  1e5 (default) or 1e6 for OSRM
 * @returns {Array<[number, number]>}  Array of [lat, lon] pairs
 */
function decodePolyline(encoded, precision = 1e5) {
  const coordinates = [];
  let index = 0;
  let lat = 0;
  let lon = 0;

  while (index < encoded.length) {
    let shift = 0;
    let result = 0;
    let byte;

    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    lat += result & 1 ? ~(result >> 1) : result >> 1;

    shift = 0;
    result = 0;

    do {
      byte = encoded.charCodeAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    lon += result & 1 ? ~(result >> 1) : result >> 1;

    coordinates.push([lat / precision, lon / precision]);
  }

  return coordinates;
}

/**
 * Convert an array of [lat, lon] pairs to a GeoJSON LineString.
 */
function toGeoJSON(latLonPairs) {
  return {
    type: 'LineString',
    coordinates: latLonPairs.map(([lat, lon]) => [lon, lat]),
  };
}

/**
 * Calculate the Haversine distance between two points in metres.
 */
function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Earth radius in metres
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/**
 * Format metres as a human-readable distance string.
 */
function formatDistance(metres) {
  if (metres < 1000) return `${Math.round(metres)} m`;
  return `${(metres / 1000).toFixed(1)} km`;
}

/**
 * Format seconds as a human-readable duration string.
 */
function formatDuration(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h} hr ${m} min`;
  if (m > 0) return `${m} min`;
  return `${Math.round(seconds)} sec`;
}

module.exports = { decodePolyline, toGeoJSON, haversineDistance, formatDistance, formatDuration };
