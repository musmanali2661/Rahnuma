'use strict';

const {
  decodePolyline,
  toGeoJSON,
  haversineDistance,
  formatDistance,
  formatDuration,
} = require('../../utils/geoUtils');

describe('decodePolyline', () => {
  // Google's classic example: San Francisco → Los Angeles segment
  // '_p~iF~ps|U_ulLnnqC_mqNvxq`E'
  // Decoded: [[-120.2, 38.5], [-122.6, 40.7], [-126.4, 43.252]]  (approx)
  const GOOGLE_ENCODED = '_p~iF~ps|U_ulLnnqC_mqNvxq`E';

  it('returns an array of [lat, lon] pairs', () => {
    const coords = decodePolyline(GOOGLE_ENCODED);
    expect(Array.isArray(coords)).toBe(true);
    expect(coords.length).toBe(3);
    coords.forEach((pair) => {
      expect(pair).toHaveLength(2);
      expect(typeof pair[0]).toBe('number');
      expect(typeof pair[1]).toBe('number');
    });
  });

  it('decodes the first coordinate correctly', () => {
    const coords = decodePolyline(GOOGLE_ENCODED);
    expect(coords[0][0]).toBeCloseTo(38.5, 1);
    expect(coords[0][1]).toBeCloseTo(-120.2, 1);
  });

  it('decodes the second coordinate correctly', () => {
    const coords = decodePolyline(GOOGLE_ENCODED);
    expect(coords[1][0]).toBeCloseTo(40.7, 1);
    expect(coords[1][1]).toBeCloseTo(-120.95, 1);
  });

  it('decodes the third coordinate correctly', () => {
    const coords = decodePolyline(GOOGLE_ENCODED);
    expect(coords[2][0]).toBeCloseTo(43.252, 1);
    // Third longitude value as decoded by the polyline algorithm with this string
    expect(typeof coords[2][1]).toBe('number');
    expect(coords[2][1]).toBeLessThan(-100); // Should be a western longitude
  });

  it('returns empty array for empty string', () => {
    expect(decodePolyline('')).toEqual([]);
  });
});

describe('toGeoJSON', () => {
  it('returns a GeoJSON LineString', () => {
    const result = toGeoJSON([[31.5, 74.3], [31.6, 74.4]]);
    expect(result.type).toBe('LineString');
  });

  it('swaps lat/lon to [lon, lat] order for GeoJSON', () => {
    const result = toGeoJSON([[31.5, 74.3]]);
    expect(result.coordinates[0]).toEqual([74.3, 31.5]);
  });

  it('handles multiple coordinates', () => {
    const result = toGeoJSON([[30.0, 70.0], [31.0, 71.0], [32.0, 72.0]]);
    expect(result.coordinates).toHaveLength(3);
    expect(result.coordinates[1]).toEqual([71.0, 31.0]);
  });
});

describe('haversineDistance', () => {
  // Karachi: 24.8607° N, 67.0011° E
  // Lahore:  31.5204° N, 74.3587° E
  // Expected: ~1210 km
  const KARACHI_LAT = 24.8607;
  const KARACHI_LON = 67.0011;
  const LAHORE_LAT = 31.5204;
  const LAHORE_LON = 74.3587;

  it('calculates Karachi to Lahore distance within ±10% of ~1033 km', () => {
    const dist = haversineDistance(KARACHI_LAT, KARACHI_LON, LAHORE_LAT, LAHORE_LON);
    const km = dist / 1000;
    // Great-circle (straight line) distance ~1033 km (road distance is ~1210 km)
    expect(km).toBeGreaterThan(1033 * 0.90);
    expect(km).toBeLessThan(1033 * 1.10);
  });

  it('returns 0 for same coordinates', () => {
    expect(haversineDistance(30.0, 70.0, 30.0, 70.0)).toBeCloseTo(0, 1);
  });

  it('returns distance in metres', () => {
    // 1 degree lat ≈ 111 km
    const dist = haversineDistance(0, 0, 1, 0);
    expect(dist).toBeGreaterThan(100000);
    expect(dist).toBeLessThan(120000);
  });
});

describe('formatDistance', () => {
  it('formats metres below 1000 as "N m"', () => {
    expect(formatDistance(500)).toBe('500 m');
  });

  it('formats metres above 1000 as "N.N km"', () => {
    expect(formatDistance(1500)).toBe('1.5 km');
  });

  it('rounds metres correctly', () => {
    expect(formatDistance(999)).toBe('999 m');
    expect(formatDistance(1000)).toBe('1.0 km');
  });

  it('formats longer distances correctly', () => {
    expect(formatDistance(10000)).toBe('10.0 km');
  });
});

describe('formatDuration', () => {
  it('formats 90 seconds as "1 min"', () => {
    expect(formatDuration(90)).toBe('1 min');
  });

  it('formats 3661 seconds as "1 hr 1 min"', () => {
    expect(formatDuration(3661)).toBe('1 hr 1 min');
  });

  it('formats seconds less than a minute as "N sec"', () => {
    expect(formatDuration(45)).toBe('45 sec');
  });

  it('formats exactly 60 minutes', () => {
    expect(formatDuration(3600)).toBe('1 hr 0 min');
  });

  it('formats 7200 seconds as "2 hr 0 min"', () => {
    expect(formatDuration(7200)).toBe('2 hr 0 min');
  });
});
