'use strict';

const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';

/**
 * Parse and verify a JWT from the Authorization header.
 * Returns the decoded payload or null.
 */
function parseToken(req) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) return null;
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}

/**
 * Middleware: authentication required.
 * Returns 401 if no valid token is present.
 */
function required(req, res, next) {
  const payload = parseToken(req);
  if (!payload) return res.status(401).json({ error: 'Authentication required' });
  req.user = payload;
  next();
}

/**
 * Middleware: authentication optional.
 * Attaches user to req if token is valid, otherwise continues.
 */
function optional(req, _res, next) {
  req.user = parseToken(req) || null;
  next();
}

module.exports = { required, optional };
