'use strict';

jest.mock('axios');

const axios = require('axios');
const nominatimService = require('../../services/nominatimService');

// Access the private transliterateRomanUrdu function via the module's search
// by examining what it does with known inputs. We test it indirectly.
// The function is not exported, so we test through observable behaviour.

describe('transliterateRomanUrdu (via search behaviour)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Default: axios returns empty results so dedup logic doesn't interfere
    axios.get.mockResolvedValue({ data: [] });
  });

  it('triggers a second search call for known Roman Urdu word "lahore"', async () => {
    await nominatimService.search('lahore');
    // Should call axios.get twice: once for 'lahore', once for 'لاہور'
    expect(axios.get).toHaveBeenCalledTimes(2);
    const calls = axios.get.mock.calls.map((c) => c[1].params.q);
    expect(calls).toContain('lahore');
    expect(calls).toContain('لاہور');
  });

  it('triggers a second search call containing Karachi Urdu for "karachi hospital"', async () => {
    await nominatimService.search('Karachi hospital');
    expect(axios.get).toHaveBeenCalledTimes(2);
    const transliteratedCall = axios.get.mock.calls[1][1].params.q;
    expect(transliteratedCall).toContain('کراچی');
    expect(transliteratedCall).toContain('ہسپتال');
  });

  it('does NOT trigger a second search for unrecognised word "xyz123"', async () => {
    await nominatimService.search('xyz123');
    // Only one call — no transliteration match
    expect(axios.get).toHaveBeenCalledTimes(1);
  });
});

describe('nominatimService.search', () => {
  const nominatimResult = {
    place_id: 42,
    osm_type: 'node',
    osm_id: 12345,
    display_name: 'Lahore, Punjab, Pakistan',
    lat: '31.5204',
    lon: '74.3587',
    address: { city: 'Lahore', country: 'Pakistan' },
    category: 'place',
    type: 'city',
    importance: 0.8,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns formatted results', async () => {
    axios.get.mockResolvedValue({ data: [nominatimResult] });
    const results = await nominatimService.search('lahore');
    expect(results.length).toBeGreaterThan(0);
    const first = results[0];
    expect(first).toHaveProperty('place_id', 42);
    expect(first).toHaveProperty('lat', 31.5204);
    expect(first).toHaveProperty('lon', 74.3587);
    expect(first).toHaveProperty('name');  // formatResult maps display_name → name
  });

  it('deduplicates results by place_id', async () => {
    // Both queries return the same result
    axios.get.mockResolvedValue({ data: [nominatimResult] });
    const results = await nominatimService.search('lahore');
    const ids = results.map((r) => r.place_id);
    const unique = [...new Set(ids)];
    expect(ids).toEqual(unique);
  });

  it('respects the limit option', async () => {
    const many = Array.from({ length: 20 }, (_, i) => ({ ...nominatimResult, place_id: i }));
    axios.get.mockResolvedValue({ data: many });
    const results = await nominatimService.search('test', { limit: 5 });
    expect(results.length).toBeLessThanOrEqual(5);
  });
});

describe('nominatimService.reverseGeocode', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns formatted result from reverse geocode', async () => {
    axios.get.mockResolvedValue({
      data: {
        place_id: 99,
        display_name: '123 Main St, Karachi, Pakistan',
        lat: '24.86',
        lon: '67.01',
        address: { road: 'Main St', city: 'Karachi' },
        category: 'place',
        type: 'house',
        importance: 0.5,
      },
    });

    const result = await nominatimService.reverseGeocode(24.86, 67.01);
    expect(result).toHaveProperty('place_id', 99);
    expect(result).toHaveProperty('lat', 24.86);
    expect(result).toHaveProperty('lon', 67.01);
    expect(result).toHaveProperty('name');  // formatResult maps display_name → name
  });
});
