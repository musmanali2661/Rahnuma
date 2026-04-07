'use strict';

const { signAccessToken, signRefreshToken, verifyAccessToken } = require('../../utils/jwtUtils');

describe('signAccessToken + verifyAccessToken', () => {
  it('round-trips a payload correctly', () => {
    const payload = { id: 'abc', role: 'user' };
    const token = signAccessToken(payload);
    const decoded = verifyAccessToken(token);
    expect(decoded.id).toBe('abc');
    expect(decoded.role).toBe('user');
  });

  it('decoded token contains standard JWT fields', () => {
    const token = signAccessToken({ id: 'test' });
    const decoded = verifyAccessToken(token);
    expect(decoded).toHaveProperty('iat');
    expect(decoded).toHaveProperty('exp');
  });
});

describe('verifyAccessToken error cases', () => {
  it('throws on an invalid/tampered token', () => {
    expect(() => verifyAccessToken('not.a.valid.token')).toThrow();
  });

  it('throws on an expired token', async () => {
    const jwt = require('jsonwebtoken');
    const { JWT_SECRET } = require('../../utils/jwtUtils');
    const expired = jwt.sign({ id: 'x' }, JWT_SECRET, { expiresIn: '1ms' });

    // Wait briefly so the token expires
    await new Promise((resolve) => setTimeout(resolve, 5));

    expect(() => verifyAccessToken(expired)).toThrow();
  });
});

describe('signRefreshToken', () => {
  it('returns a string', () => {
    const token = signRefreshToken();
    expect(typeof token).toBe('string');
  });

  it('returns a string of length >= 32', () => {
    const token = signRefreshToken();
    expect(token.length).toBeGreaterThanOrEqual(32);
  });

  it('returns different values each time', () => {
    const t1 = signRefreshToken();
    const t2 = signRefreshToken();
    expect(t1).not.toBe(t2);
  });
});
