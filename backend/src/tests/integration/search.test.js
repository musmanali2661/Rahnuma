'use strict';

const request = require('supertest');

jest.mock('../../database/postgres', () => ({
  getPool: jest.fn(),
  connectPostgres: jest.fn(),
}));
jest.mock('../../database/redis', () => ({
  connectRedis: jest.fn(),
  getRedis: jest.fn(),
}));
jest.mock('../../services/nominatimService');

const { app } = require('../../api/index');
const nominatimService = require('../../services/nominatimService');

const MOCK_SEARCH_RESULTS = [
  {
    place_id: 1,
    display_name: 'Lahore, Punjab, Pakistan',
    lat: 31.5204,
    lon: 74.3587,
    category: 'place',
    type: 'city',
    address: {},
  },
];

describe('GET /api/v1/search', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with results for valid query', async () => {
    nominatimService.search.mockResolvedValue(MOCK_SEARCH_RESULTS);

    const res = await request(app).get('/api/v1/search?q=lahore');

    expect(res.status).toBe(200);
  });

  it('returns 400 when query param q is missing', async () => {
    const res = await request(app).get('/api/v1/search');

    expect(res.status).toBe(400);
  });
});

describe('GET /api/v1/search/reverse', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 for valid lat/lon', async () => {
    nominatimService.reverseGeocode.mockResolvedValue({
      place_id: 99,
      display_name: 'Karachi, Pakistan',
      lat: 24.86,
      lon: 67.01,
      address: {},
    });

    const res = await request(app).get('/api/v1/search/reverse?lat=31.5&lon=74.3');

    expect(res.status).toBe(200);
  });

  it('returns 400 when lat is missing', async () => {
    const res = await request(app).get('/api/v1/search/reverse?lon=74.3');

    expect(res.status).toBe(400);
  });
});
