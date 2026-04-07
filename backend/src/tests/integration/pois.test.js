'use strict';

const request = require('supertest');

const mockQuery = jest.fn();
jest.mock('../../database/postgres', () => ({
  getPool: jest.fn(() => ({ query: mockQuery })),
  connectPostgres: jest.fn(),
}));
jest.mock('../../database/redis', () => ({
  connectRedis: jest.fn(),
  getRedis: jest.fn(),
}));

const { app } = require('../../api/index');

const BBOX = 'minLat=30&minLon=73&maxLat=31&maxLon=74';

describe('GET /api/v1/pois', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with pois array', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get(`/api/v1/pois?${BBOX}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('pois');
    expect(Array.isArray(res.body.pois)).toBe(true);
  });

  it('returns 400 when bbox params are missing', async () => {
    const res = await request(app).get('/api/v1/pois');

    expect(res.status).toBe(400);
  });
});

describe('GET /api/v1/pois/:id', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 when POI is found', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [
        {
          id: 'poi-uuid-1',
          name: 'Badshahi Mosque',
          name_ur: 'بادشاہی مسجد',
          category: 'mosque',
          subcategory: null,
          lat: 31.59,
          lon: 74.31,
          rating_avg: null,
          rating_count: null,
          phone: null,
          opening_hours: null,
        },
      ],
    });

    const res = await request(app).get('/api/v1/pois/poi-uuid-1');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('id', 'poi-uuid-1');
  });

  it('returns 404 when POI is not found', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get('/api/v1/pois/00000000-0000-0000-0000-000000000000');

    expect(res.status).toBe(404);
  });
});
