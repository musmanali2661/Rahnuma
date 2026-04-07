'use strict';

const express = require('express');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const { getPool } = require('../../database/postgres');
const { signAccessToken, signRefreshToken } = require('../../utils/jwtUtils');
const authMiddleware = require('../middleware/auth');
const logger = require('../../utils/logger');

const router = express.Router();

const BCRYPT_ROUNDS = 12;
const REFRESH_TOKEN_DAYS = 30;

// ── POST /api/v1/auth/register ───────────────────────────────────────────────
router.post(
  '/register',
  [
    body('email').optional().isEmail().normalizeEmail(),
    body('phone').optional().isMobilePhone(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('name').optional().isString().trim(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, phone, password, name } = req.body;
    if (!email && !phone) {
      return res.status(400).json({ error: 'At least one of email or phone is required' });
    }

    try {
      const pool = getPool();
      const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);

      // For phone-only users, use a synthetic email to satisfy NOT NULL constraint
      const effectiveEmail = email || `phone:${phone}@rahnuma.app`;
      const username = email || phone;

      const { rows } = await pool.query(
        `INSERT INTO users (username, email, password_hash, display_name)
         VALUES ($1, $2, $3, $4)
         RETURNING id`,
        [username, effectiveEmail, passwordHash, name || null]
      );

      const userId = rows[0].id;
      const accessToken = signAccessToken({ id: userId, role: 'user' });
      const refreshToken = signRefreshToken();
      const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);

      await pool.query(
        `INSERT INTO refresh_tokens (user_id, token, expires_at)
         VALUES ($1, $2, $3)`,
        [userId, refreshToken, expiresAt]
      );

      res.status(201).json({ accessToken, refreshToken });
    } catch (err) {
      if (err.code === '23505') {
        // Unique constraint violation
        return res.status(409).json({ error: 'Email or phone already registered' });
      }
      logger.error('Registration failed', { err });
      next(err);
    }
  }
);

// ── POST /api/v1/auth/login ──────────────────────────────────────────────────
router.post(
  '/login',
  [
    body('email').optional().isEmail().normalizeEmail(),
    body('phone').optional().isMobilePhone(),
    body('password').notEmpty(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, phone, password } = req.body;
    if (!email && !phone) {
      return res.status(400).json({ error: 'At least one of email or phone is required' });
    }

    try {
      const pool = getPool();
      const effectiveEmail = email || `phone:${phone}@rahnuma.app`;

      const { rows } = await pool.query(
        'SELECT id, password_hash FROM users WHERE email = $1',
        [effectiveEmail]
      );

      if (!rows.length) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const user = rows[0];
      const match = await bcrypt.compare(password, user.password_hash);
      if (!match) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const accessToken = signAccessToken({ id: user.id, role: 'user' });
      const refreshToken = signRefreshToken();
      const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);

      await pool.query(
        `INSERT INTO refresh_tokens (user_id, token, expires_at)
         VALUES ($1, $2, $3)`,
        [user.id, refreshToken, expiresAt]
      );

      res.json({ accessToken, refreshToken });
    } catch (err) {
      logger.error('Login failed', { err });
      next(err);
    }
  }
);

// ── POST /api/v1/auth/refresh ────────────────────────────────────────────────
router.post(
  '/refresh',
  [body('refreshToken').notEmpty().withMessage('refreshToken is required')],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { refreshToken } = req.body;

    try {
      const pool = getPool();
      const { rows } = await pool.query(
        `SELECT id, user_id, expires_at, revoked_at
         FROM refresh_tokens
         WHERE token = $1`,
        [refreshToken]
      );

      if (!rows.length) {
        return res.status(401).json({ error: 'Invalid refresh token' });
      }

      const record = rows[0];

      if (record.revoked_at) {
        return res.status(401).json({ error: 'Refresh token has been revoked' });
      }

      if (new Date(record.expires_at) < new Date()) {
        return res.status(401).json({ error: 'Refresh token has expired' });
      }

      const accessToken = signAccessToken({ id: record.user_id, role: 'user' });
      res.json({ accessToken });
    } catch (err) {
      logger.error('Token refresh failed', { err });
      next(err);
    }
  }
);

// ── POST /api/v1/auth/logout ─────────────────────────────────────────────────
router.post(
  '/logout',
  authMiddleware.required,
  [body('refreshToken').notEmpty().withMessage('refreshToken is required')],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { refreshToken } = req.body;

    try {
      const pool = getPool();
      await pool.query(
        `UPDATE refresh_tokens
         SET revoked_at = NOW()
         WHERE token = $1 AND user_id = $2`,
        [refreshToken, req.user.id]
      );

      res.status(204).end();
    } catch (err) {
      logger.error('Logout failed', { err });
      next(err);
    }
  }
);

module.exports = router;
