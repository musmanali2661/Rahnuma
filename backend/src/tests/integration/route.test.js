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
jest.mock('../../services/osrmService');

const { app } = require('../../api/index');
const osrmService = require('../../services/osrmService');

const MOCK_ROUTE_RESPONSE = {
  routes: [
    {
      distance: 350000,
      duration: 12600,
      geometry: { type: 'LineString', coordinates: [[74.3, 31.5], [73.0, 33.7]] },
      legs: [],
      summary: 'M-2',
      toll_estimate_pkr: 685,
    },
  ],
  waypoints: [],
};

describe('POST /api/v1/route', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with route data for valid waypoints', async () => {
    osrmService.getRoute.mockResolvedValue(MOCK_ROUTE_RESPONSE);

    const res = await request(app).post('/api/v1/route').send({
      waypoints: [
        { lat: 31.5, lon: 74.3 },
        { lat: 33.7, lon: 73.0 },
      ],
    });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('routes');
  });

  it('returns 400 when only 1 waypoint is provided', async () => {
    const res = await request(app).post('/api/v1/route').send({
      waypoints: [{ lat: 31.5, lon: 74.3 }],
    });

    expect(res.status).toBe(400);
  });

  it('returns 400 when lat > 90', async () => {
    const res = await request(app).post('/api/v1/route').send({
      waypoints: [
        { lat: 95, lon: 74.3 },
        { lat: 33.7, lon: 73.0 },
      ],
    });

    expect(res.status).toBe(400);
  });

  it('returns 400 for invalid profile', async () => {
    const res = await request(app).post('/api/v1/route').send({
      waypoints: [
        { lat: 31.5, lon: 74.3 },
        { lat: 33.7, lon: 73.0 },
      ],
      profile: 'helicopter',
    });

    expect(res.status).toBe(400);
  });
});

describe('GET /api/v1/route/snap', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with snapped location for valid params', async () => {
    osrmService.snapToRoad.mockResolvedValue({
      location: [74.3, 31.5],
      name: 'Test Road',
      distance: 5.2,
    });

    const res = await request(app).get('/api/v1/route/snap?lat=31.5&lon=74.3');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('location');
  });

  it('returns 400 when lat or lon params are missing', async () => {
    const res = await request(app).get('/api/v1/route/snap?lat=31.5');

    expect(res.status).toBe(400);
  });
});
