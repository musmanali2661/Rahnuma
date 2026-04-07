'use strict';

const axios = require('axios');
const logger = require('../utils/logger');
const { decodePolyline, toGeoJSON } = require('../utils/geoUtils');

const OSRM_BASE = `${process.env.OSRM_HOST || 'http://localhost'}:${process.env.OSRM_PORT || 5000}`;

// Toll road segments for Pakistani motorways (simplified bounding boxes)
const TOLL_SEGMENTS = [
  { name: 'M-2 (Lahore–Islamabad)', toll: 685 },  // PKR
  { name: 'M-1 (Peshawar–Islamabad)', toll: 360 },
  { name: 'M-3 (Abdul Hakam–Faisalabad)', toll: 200 },
];

/**
 * Calculate a route between waypoints using OSRM.
 *
 * @param {Array<{lat: number, lon: number}>} waypoints
 * @param {{ profile?: string, alternatives?: boolean }} options
 * @returns {Promise<object>}
 */
async function getRoute(waypoints, { profile = 'car', alternatives = false } = {}) {
  const coords = waypoints.map((w) => `${w.lon},${w.lat}`).join(';');
  const url = `${OSRM_BASE}/route/v1/${profile}/${coords}`;

  const params = {
    overview: 'full',
    geometries: 'polyline6',
    steps: true,
    annotations: false,
    alternatives: alternatives ? 3 : false,
  };

  try {
    const { data } = await axios.get(url, { params, timeout: 10000 });

    if (data.code !== 'Ok') {
      throw Object.assign(new Error(data.message || 'OSRM routing error'), { status: 422 });
    }

    return {
      routes: data.routes.map((r) => formatRoute(r)),
      waypoints: data.waypoints,
    };
  } catch (err) {
    if (err.response) {
      logger.error('OSRM HTTP error', { status: err.response.status, data: err.response.data });
      throw Object.assign(new Error('Routing service error'), { status: 502 });
    }
    if (err.code === 'ECONNREFUSED' || err.code === 'ECONNABORTED') {
      throw Object.assign(new Error('Routing service unavailable'), { status: 503 });
    }
    throw err;
  }
}

/**
 * Snap a coordinate to the nearest road.
 */
async function snapToRoad(lat, lon) {
  const url = `${OSRM_BASE}/nearest/v1/car/${lon},${lat}`;
  const { data } = await axios.get(url, { timeout: 5000 });
  if (data.code !== 'Ok') throw new Error('Snap failed');
  return {
    location: data.waypoints[0].location,
    name: data.waypoints[0].name,
    distance: data.waypoints[0].distance,
  };
}

/**
 * Format a raw OSRM route into the Rahnuma response schema.
 */
function formatRoute(route) {
  const geometry = toGeoJSON(decodePolyline(route.geometry, 1e6));
  const legs = route.legs.map(formatLeg);
  const tollEstimate = estimateTolls(route);

  return {
    distance: route.distance,       // metres
    duration: route.duration,       // seconds
    geometry,
    legs,
    summary: route.legs.map((l) => l.summary).filter(Boolean).join(' → '),
    toll_estimate_pkr: tollEstimate,
  };
}

function formatLeg(leg) {
  return {
    distance: leg.distance,
    duration: leg.duration,
    summary: leg.summary,
    steps: leg.steps.map(formatStep),
  };
}

function formatStep(step) {
  return {
    distance: step.distance,
    duration: step.duration,
    name: step.name,
    mode: step.mode,
    maneuver: step.maneuver,
    geometry: toGeoJSON(decodePolyline(step.geometry, 1e6)),
  };
}

/**
 * Rough toll estimation based on route distance for known motorways.
 * Phase 1: simple heuristic; Phase 2 will use actual segment matching.
 */
function estimateTolls(route) {
  // Estimate based on whether the route uses motorway-like speeds
  const distanceKm = route.distance / 1000;
  // ~PKR 2 per km on motorways — very rough estimate
  if (distanceKm > 50) return Math.round(distanceKm * 2);
  return 0;
}

module.exports = { getRoute, snapToRoad };
