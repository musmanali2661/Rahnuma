'use strict';

const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';

/**
 * Sign a short-lived access token (24h).
 *
 * @param {object} payload  Data to embed in the token (e.g. { id, role })
 * @returns {string}  Signed JWT string
 */
function signAccessToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
}

/**
 * Generate an opaque refresh token (NOT a JWT).
 * Returns a random UUID string that is stored in the refresh_tokens table.
 *
 * @returns {string}  Random UUID token string
 */
function signRefreshToken() {
  return crypto.randomUUID();
}

/**
 * Verify an access token and return the decoded payload.
 * Throws a JsonWebTokenError or TokenExpiredError on failure.
 *
 * @param {string} token  JWT access token
 * @returns {object}  Decoded payload
 */
function verifyAccessToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

module.exports = { signAccessToken, signRefreshToken, verifyAccessToken, JWT_SECRET };
