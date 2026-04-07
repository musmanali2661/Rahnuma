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
jest.mock('../../services/offlineService');

const { app } = require('../../api/index');
const offlineService = require('../../services/offlineService');

describe('GET /api/v1/offline/packages', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with packages array', async () => {
    offlineService.listPackages.mockResolvedValue([]);

    const res = await request(app).get('/api/v1/offline/packages');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('packages');
    expect(Array.isArray(res.body.packages)).toBe(true);
  });
});

describe('GET /api/v1/offline/packages/:city', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 404 when file does not exist', async () => {
    offlineService.getPackagePath.mockResolvedValue(null);

    const res = await request(app).get('/api/v1/offline/packages/karachi');

    expect(res.status).toBe(404);
  });
});
