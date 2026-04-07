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

describe('GET /api/v1/events', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with events array', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get(`/api/v1/events?${BBOX}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('events');
    expect(Array.isArray(res.body.events)).toBe(true);
  });

  it('returns 400 when bbox params are missing', async () => {
    const res = await request(app).get('/api/v1/events');

    expect(res.status).toBe(400);
  });
});

describe('POST /api/v1/events', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 401 without auth', async () => {
    const res = await request(app).post('/api/v1/events').send({
      events: [{ lat: 31.5, lon: 74.3, event_type: 'pothole', confidence: 0.9 }],
    });

    expect(res.status).toBe(401);
  });

  it('returns 201 with valid JWT and valid body', async () => {
    mockQuery.mockResolvedValue({ rows: [{ id: 'event-uuid-1' }] });
    const token = signAccessToken({ id: 'user-uuid-1', role: 'user' });

    const res = await request(app)
      .post('/api/v1/events')
      .set('Authorization', `Bearer ${token}`)
      .send({
        events: [{ lat: 31.5, lon: 74.3, event_type: 'pothole', confidence: 0.9 }],
      });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('inserted');
  });

  it('returns 400 with valid JWT but empty events array', async () => {
    const token = signAccessToken({ id: 'user-uuid-1', role: 'user' });

    const res = await request(app)
      .post('/api/v1/events')
      .set('Authorization', `Bearer ${token}`)
      .send({ events: [] });

    expect(res.status).toBe(400);
  });
});
