/**
 * Rahnuma custom MapLibre GL style.
 * Uses OpenStreetMap tiles via a self-hosted tile server (Martin).
 *
 * Road colour scheme:
 *  Motorways   : Green  #2E7D32
 *  Primary     : Orange #FF9800
 *  Secondary   : Gray   #757575
 *  Residential : Light  #E0E0E0
 *  Unpaved     : Brown  #8D6E63
 */

const TILE_URL = import.meta.env?.VITE_TILE_SERVER_URL || 'http://localhost:3000';

export const mapStyle = {
  version: 8,
  name: 'Rahnuma',
  glyphs: 'https://fonts.openmaptiles.org/{fontstack}/{range}.pbf',
  sprite: `${TILE_URL}/sprites/rahnuma`,
  sources: {
    'rahnuma-tiles': {
      type: 'vector',
      tiles: [`${TILE_URL}/rahnuma/{z}/{x}/{y}`],
      minzoom: 0,
      maxzoom: 14,
      attribution: '© OpenStreetMap contributors',
    },
  },
  layers: [
    // ── Background ────────────────────────────────────────────────────────
    {
      id: 'background',
      type: 'background',
      paint: { 'background-color': '#F5F5F5' },
    },

    // ── Water ─────────────────────────────────────────────────────────────
    {
      id: 'water',
      type: 'fill',
      source: 'rahnuma-tiles',
      'source-layer': 'water',
      paint: { 'fill-color': '#B3E5FC' },
    },

    // ── Land use ──────────────────────────────────────────────────────────
    {
      id: 'landuse-park',
      type: 'fill',
      source: 'rahnuma-tiles',
      'source-layer': 'landuse',
      filter: ['==', ['get', 'class'], 'park'],
      paint: { 'fill-color': '#C8E6C9', 'fill-opacity': 0.7 },
    },
    {
      id: 'landuse-residential',
      type: 'fill',
      source: 'rahnuma-tiles',
      'source-layer': 'landuse',
      filter: ['==', ['get', 'class'], 'residential'],
      paint: { 'fill-color': '#EEEEEE', 'fill-opacity': 0.5 },
    },

    // ── Buildings ─────────────────────────────────────────────────────────
    {
      id: 'building',
      type: 'fill',
      source: 'rahnuma-tiles',
      'source-layer': 'building',
      minzoom: 14,
      paint: { 'fill-color': '#D7CCC8', 'fill-outline-color': '#BCAAA4' },
    },

    // ── Roads — casing (outline) ──────────────────────────────────────────
    {
      id: 'road-motorway-casing',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['==', ['get', 'class'], 'motorway'],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#1B5E20', 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 3, 14, 14] },
    },
    {
      id: 'road-primary-casing',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['==', ['get', 'class'], 'primary'],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#E65100', 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 2, 14, 12] },
    },

    // ── Roads — fill ──────────────────────────────────────────────────────
    {
      id: 'road-motorway',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['==', ['get', 'class'], 'motorway'],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#2E7D32', 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 2, 14, 10] },
    },
    {
      id: 'road-trunk',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['==', ['get', 'class'], 'trunk'],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#388E3C', 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 1.5, 14, 8] },
    },
    {
      id: 'road-primary',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['==', ['get', 'class'], 'primary'],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#FF9800', 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 1, 14, 6] },
    },
    {
      id: 'road-secondary',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['in', ['get', 'class'], ['literal', ['secondary', 'tertiary']]],
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#757575', 'line-width': ['interpolate', ['linear'], ['zoom'], 10, 0.5, 14, 4] },
    },
    {
      id: 'road-residential',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['in', ['get', 'class'], ['literal', ['residential', 'service', 'unclassified']]],
      minzoom: 13,
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#E0E0E0', 'line-width': ['interpolate', ['linear'], ['zoom'], 13, 0.5, 16, 4] },
    },
    {
      id: 'road-unpaved',
      type: 'line',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation',
      filter: ['in', ['get', 'class'], ['literal', ['track', 'path']]],
      minzoom: 13,
      layout: { 'line-cap': 'round', 'line-join': 'round', 'line-dasharray': [3, 2] },
      paint: { 'line-color': '#8D6E63', 'line-width': 1.5 },
    },

    // ── Road labels ───────────────────────────────────────────────────────
    {
      id: 'road-label',
      type: 'symbol',
      source: 'rahnuma-tiles',
      'source-layer': 'transportation_name',
      minzoom: 12,
      layout: {
        'text-field': ['coalesce', ['get', 'name:ur'], ['get', 'name']],
        'text-font': ['Noto Sans Regular'],
        'text-size': 11,
        'symbol-placement': 'line',
        'text-max-angle': 30,
      },
      paint: { 'text-color': '#37474F', 'text-halo-color': '#FFFFFF', 'text-halo-width': 1.5 },
    },

    // ── POI labels ────────────────────────────────────────────────────────
    {
      id: 'poi-label',
      type: 'symbol',
      source: 'rahnuma-tiles',
      'source-layer': 'poi',
      minzoom: 14,
      layout: {
        'text-field': ['coalesce', ['get', 'name:ur'], ['get', 'name']],
        'text-font': ['Noto Sans Regular'],
        'text-size': 10,
        'text-anchor': 'top',
        'text-offset': [0, 0.6],
        'icon-image': ['get', 'class'],
        'icon-size': 0.8,
      },
      paint: { 'text-color': '#546E7A', 'text-halo-color': '#FFFFFF', 'text-halo-width': 1 },
    },

    // ── City labels ───────────────────────────────────────────────────────
    {
      id: 'place-city',
      type: 'symbol',
      source: 'rahnuma-tiles',
      'source-layer': 'place',
      filter: ['in', ['get', 'class'], ['literal', ['city', 'town']]],
      layout: {
        'text-field': ['coalesce', ['get', 'name:ur'], ['get', 'name']],
        'text-font': ['Noto Sans Bold'],
        'text-size': ['interpolate', ['linear'], ['zoom'], 6, 12, 12, 18],
        'text-anchor': 'center',
      },
      paint: { 'text-color': '#1A237E', 'text-halo-color': '#FFFFFF', 'text-halo-width': 2 },
    },
  ],
};
