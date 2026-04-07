'use strict';

const request = require('supertest');
const bcrypt = require('bcryptjs');

// ── Mock DB and Redis before requiring the app ────────────────────────────────
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

// ── Helpers ───────────────────────────────────────────────────────────────────
const VALID_REGISTER_BODY = {
  email: 'test@example.com',
  password: 'password123',
  name: 'Test User',
};

describe('POST /api/v1/auth/register', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 201 with accessToken and refreshToken on valid body', async () => {
    // First query: INSERT users, second: INSERT refresh_tokens
    mockQuery
      .mockResolvedValueOnce({ rows: [{ id: 'user-uuid-1' }] })
      .mockResolvedValueOnce({ rows: [] });

    const res = await request(app).post('/api/v1/auth/register').send(VALID_REGISTER_BODY);

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('accessToken');
    expect(res.body).toHaveProperty('refreshToken');
  });

  it('returns 400 when both email and phone are missing', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({ password: 'password123' });

    expect(res.status).toBe(400);
  });

  it('returns 409 when email/phone already exists (unique constraint)', async () => {
    const uniqueError = new Error('duplicate key');
    uniqueError.code = '23505';
    mockQuery.mockRejectedValueOnce(uniqueError);

    const res = await request(app).post('/api/v1/auth/register').send(VALID_REGISTER_BODY);

    expect(res.status).toBe(409);
  });
});

describe('POST /api/v1/auth/login', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with tokens on valid credentials', async () => {
    const hash = await bcrypt.hash('password123', 1);
    // First query: SELECT user, second: INSERT refresh_tokens
    mockQuery
      .mockResolvedValueOnce({ rows: [{ id: 'user-uuid-1', password_hash: hash }] })
      .mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('accessToken');
    expect(res.body).toHaveProperty('refreshToken');
  });

  it('returns 401 on wrong password', async () => {
    const hash = await bcrypt.hash('correctpassword', 1);
    mockQuery.mockResolvedValueOnce({ rows: [{ id: 'user-uuid-1', password_hash: hash }] });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'test@example.com', password: 'wrongpassword' });

    expect(res.status).toBe(401);
  });

  it('returns 401 when user is not found', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'nobody@example.com', password: 'password123' });

    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/auth/refresh', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 200 with new accessToken for a valid refresh token', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [
        {
          id: 'token-uuid',
          user_id: 'user-uuid-1',
          expires_at: new Date(Date.now() + 86400000),
          revoked_at: null,
        },
      ],
    });

    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: 'valid-refresh-token' });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('accessToken');
  });

  it('returns 401 when refresh token is not in DB', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: 'unknown-token' });

    expect(res.status).toBe(401);
  });

  it('returns 401 when refresh token is revoked', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [
        {
          id: 'token-uuid',
          user_id: 'user-uuid-1',
          expires_at: new Date(Date.now() + 86400000),
          revoked_at: new Date(),
        },
      ],
    });

    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: 'revoked-token' });

    expect(res.status).toBe(401);
  });

  it('returns 401 when refresh token is expired', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [
        {
          id: 'token-uuid',
          user_id: 'user-uuid-1',
          expires_at: new Date(Date.now() - 1000),  // expired
          revoked_at: null,
        },
      ],
    });

    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: 'expired-token' });

    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/auth/logout', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns 204 when authenticated with valid refresh token', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const accessToken = signAccessToken({ id: 'user-uuid-1', role: 'user' });

    const res = await request(app)
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ refreshToken: 'some-refresh-token' });

    expect(res.status).toBe(204);
  });

  it('returns 401 when not authenticated', async () => {
    const res = await request(app)
      .post('/api/v1/auth/logout')
      .send({ refreshToken: 'some-refresh-token' });

    expect(res.status).toBe(401);
  });
});
