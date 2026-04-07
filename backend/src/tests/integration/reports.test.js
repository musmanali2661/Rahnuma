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
const { signAccessToken } = require('../../utils/jwtUtils');

const BBOX = 'minLat=30&minLon=73&maxLat=31&maxLon=74';

describe('POST /api/v1/reports', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 401 without auth', async () => {
    const res = await request(app).post('/api/v1/reports').send({
      lat: 31.5,
      lon: 74.3,
      report_type: 'accident',
    });

    expect(res.status).toBe(401);
  });

  it('returns 201 with auth and valid body', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [{ id: 'report-uuid-1' }] });
    const token = signAccessToken({ id: 'user-uuid-1', role: 'user' });

    const res = await request(app)
      .post('/api/v1/reports')
      .set('Authorization', `Bearer ${token}`)
      .send({
        lat: 31.5,
        lon: 74.3,
        report_type: 'accident',
        description: 'Major accident on the highway',
        severity: 'severe',
      });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
  });

  it('returns 400 for invalid report_type', async () => {
    const token = signAccessToken({ id: 'user-uuid-1', role: 'user' });

    const res = await request(app)
      .post('/api/v1/reports')
      .set('Authorization', `Bearer ${token}`)
      .send({
        lat: 31.5,
        lon: 74.3,
        report_type: 'invalid_type',
      });

    expect(res.status).toBe(400);
  });
});

describe('GET /api/v1/reports', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with reports array', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get(`/api/v1/reports?${BBOX}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('reports');
    expect(Array.isArray(res.body.reports)).toBe(true);
  });

  it('returns 400 when bbox params are missing', async () => {
    const res = await request(app).get('/api/v1/reports');

    expect(res.status).toBe(400);
  });
});
