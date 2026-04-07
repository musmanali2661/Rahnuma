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

const { app } = require('../../api/index');

describe('GET /health', () => {
  it('returns 200 with { status: "ok" }', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
