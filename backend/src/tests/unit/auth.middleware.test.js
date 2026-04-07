'use strict';

const httpMocks = require('node-mocks-http');

// Use the real auth middleware (it reads JWT_SECRET from env)
const authMiddleware = require('../../api/middleware/auth');
const { signAccessToken } = require('../../utils/jwtUtils');

// Helper: create a mock request with optional Bearer token
function mockReq(token) {
  const headers = token ? { authorization: `Bearer ${token}` } : {};
  return httpMocks.createRequest({ headers });
}

describe('authMiddleware.required', () => {
  it('sets req.user and calls next() with a valid Bearer token', () => {
    const token = signAccessToken({ id: 'user-1', role: 'user' });
    const req = mockReq(token);
    const res = httpMocks.createResponse();
    const next = jest.fn();

    authMiddleware.required(req, res, next);

    expect(next).toHaveBeenCalledWith();
    expect(req.user).toBeDefined();
    expect(req.user.id).toBe('user-1');
  });

  it('returns 401 when Authorization header is missing', () => {
    const req = mockReq(null);
    const res = httpMocks.createResponse();
    const next = jest.fn();

    authMiddleware.required(req, res, next);

    expect(res.statusCode).toBe(401);
    expect(next).not.toHaveBeenCalled();
  });

  it('returns 401 for a malformed / invalid token', () => {
    const req = mockReq('this.is.not.valid');
    const res = httpMocks.createResponse();
    const next = jest.fn();

    authMiddleware.required(req, res, next);

    expect(res.statusCode).toBe(401);
    expect(next).not.toHaveBeenCalled();
  });
});

describe('authMiddleware.optional', () => {
  it('sets req.user and calls next() with a valid token', () => {
    const token = signAccessToken({ id: 'user-2', role: 'user' });
    const req = mockReq(token);
    const res = httpMocks.createResponse();
    const next = jest.fn();

    authMiddleware.optional(req, res, next);

    expect(next).toHaveBeenCalled();
    expect(req.user).toBeDefined();
    expect(req.user.id).toBe('user-2');
  });

  it('sets req.user = null and calls next() when no token is provided', () => {
    const req = mockReq(null);
    const res = httpMocks.createResponse();
    const next = jest.fn();

    authMiddleware.optional(req, res, next);

    expect(next).toHaveBeenCalled();
    expect(req.user).toBeNull();
  });
});
