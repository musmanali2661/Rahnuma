'use strict';

const axios = require('axios');
const logger = require('../utils/logger');

const NOMINATIM_BASE = `${process.env.NOMINATIM_HOST || 'http://localhost'}:${process.env.NOMINATIM_PORT || 7070}`;

// Roman Urdu → Urdu script transliteration map (Phase 1 simplified)
const ROMAN_URDU_MAP = {
  lahore: 'لاہور',
  karachi: 'کراچی',
  islamabad: 'اسلام آباد',
  rawalpindi: 'راولپنڈی',
  peshawar: 'پشاور',
  quetta: 'کوئٹہ',
  multan: 'ملتان',
  faisalabad: 'فیصل آباد',
  sialkot: 'سیالکوٹ',
  gujranwala: 'گوجرانوالہ',
  hyderabad: 'حیدرآباد',
  sukkur: 'سکھر',
  larkana: 'لاڑکانہ',
  // Common area types
  masjid: 'مسجد',
  hospital: 'ہسپتال',
  bazar: 'بازار',
  road: 'روڈ',
  market: 'مارکیٹ',
  petrol: 'پٹرول',
};

// OSM category → Nominatim class filter
const CATEGORY_FILTERS = {
  petrol: { amenity: 'fuel' },
  food: { amenity: 'restaurant' },
  mosque: { amenity: 'place_of_worship', religion: 'muslim' },
  hospital: { amenity: 'hospital' },
};

/**
 * Search for places using Nominatim.
 *
 * @param {string} q Raw search query (English or Roman Urdu)
 * @param {{ lat?, lon?, limit?, category? }} options
 */
async function search(q, { lat, lon, limit = 10, category } = {}) {
  const transliterated = transliterateRomanUrdu(q);
  const queries = [q];
  if (transliterated !== q) queries.push(transliterated);

  // Fetch results for both original + transliterated queries in parallel
  const resultSets = await Promise.all(
    queries.map((query) => fetchNominatim(query, { lat, lon, limit, category }))
  );

  // Merge, deduplicate by place_id, and limit
  const seen = new Set();
  const merged = [];
  for (const results of resultSets) {
    for (const r of results) {
      if (!seen.has(r.place_id)) {
        seen.add(r.place_id);
        merged.push(formatResult(r));
      }
    }
  }

  return merged.slice(0, limit);
}

/**
 * Reverse geocode a coordinate.
 */
async function reverseGeocode(lat, lon) {
  const url = `${NOMINATIM_BASE}/reverse`;
  const { data } = await axios.get(url, {
    params: { lat, lon, format: 'jsonv2', addressdetails: 1 },
    timeout: 8000,
  });
  return formatResult(data);
}

// ── Internal helpers ─────────────────────────────────────────────────────────

async function fetchNominatim(q, { lat, lon, limit, category }) {
  try {
    const params = {
      q,
      format: 'jsonv2',
      addressdetails: 1,
      limit,
      countrycodes: 'pk',
    };

    if (lat && lon) {
      params.viewbox = `${lon - 0.5},${lat - 0.5},${lon + 0.5},${lat + 0.5}`;
      params.bounded = 0;
    }

    if (category && CATEGORY_FILTERS[category]) {
      Object.assign(params, CATEGORY_FILTERS[category]);
    }

    const { data } = await axios.get(`${NOMINATIM_BASE}/search`, { params, timeout: 8000 });
    return Array.isArray(data) ? data : [];
  } catch (err) {
    logger.error('Nominatim search error', { err: err.message, q });
    return [];
  }
}

function formatResult(r) {
  return {
    place_id: r.place_id,
    name: r.display_name,
    lat: parseFloat(r.lat),
    lon: parseFloat(r.lon),
    type: r.type,
    class: r.class,
    address: r.address || {},
    boundingbox: r.boundingbox,
  };
}

/**
 * Simple word-by-word Roman Urdu → Urdu script transliteration.
 */
function transliterateRomanUrdu(text) {
  const lower = text.toLowerCase();
  let result = lower;
  for (const [roman, urdu] of Object.entries(ROMAN_URDU_MAP)) {
    result = result.replace(new RegExp(`\\b${roman}\\b`, 'gi'), urdu);
  }
  return result;
}

module.exports = { search, reverseGeocode, transliterateRomanUrdu };
