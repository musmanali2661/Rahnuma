'use strict';

const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { getPool } = require('../../database/postgres');
const authMiddleware = require('../middleware/auth');
const logger = require('../../utils/logger');

const router = express.Router();

const VALID_REPORT_TYPES = ['accident', 'police', 'flood', 'road_closed', 'protest'];
const VALID_SEVERITIES = ['minor', 'moderate', 'severe'];

/**
 * POST /api/v1/reports
 * Submit a crowd-sourced incident report. Requires authentication.
 */
router.post(
  '/',
  authMiddleware.required,
  [
    body('lat').isFloat({ min: -90, max: 90 }).withMessage('lat must be a valid latitude'),
    body('lon').isFloat({ min: -180, max: 180 }).withMessage('lon must be a valid longitude'),
    body('report_type')
      .isIn(VALID_REPORT_TYPES)
      .withMessage(`report_type must be one of: ${VALID_REPORT_TYPES.join(', ')}`),
    body('description').optional().isString().trim(),
    body('severity')
      .optional()
      .isIn(VALID_SEVERITIES)
      .withMessage(`severity must be one of: ${VALID_SEVERITIES.join(', ')}`),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { lat, lon, report_type, description, severity = 'moderate' } = req.body;
      const pool = getPool();

      const { rows } = await pool.query(
        `INSERT INTO user_reports (user_id, report_type, description, location, verified, resolved)
         VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), false, false)
         RETURNING id`,
        [req.user.id, report_type, description || null, parseFloat(lon), parseFloat(lat)]
      );

      res.status(201).json({ id: rows[0].id });
    } catch (err) {
      logger.error('Failed to insert report', { err });
      next(err);
    }
  }
);

/**
 * GET /api/v1/reports
 * Return crowd-sourced reports in a bounding box (public endpoint).
 * Returns pending (verified=false) and verified reports that have not expired.
 */
router.get(
  '/',
  [
    query('minLat').isFloat({ min: -90, max: 90 }).withMessage('minLat must be a valid latitude'),
    query('minLon').isFloat({ min: -180, max: 180 }).withMessage('minLon must be a valid longitude'),
    query('maxLat').isFloat({ min: -90, max: 90 }).withMessage('maxLat must be a valid latitude'),
    query('maxLon').isFloat({ min: -180, max: 180 }).withMessage('maxLon must be a valid longitude'),
    query('type').optional().isIn(VALID_REPORT_TYPES),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { minLat, minLon, maxLat, maxLon, type } = req.query;
      const pool = getPool();

      let sql = `
        SELECT
          id,
          report_type,
          description,
          ST_Y(location::geometry) AS lat,
          ST_X(location::geometry) AS lon,
          verified,
          created_at,
          expires_at
        FROM user_reports
        WHERE location && ST_MakeEnvelope($1, $2, $3, $4, 4326)
          AND resolved = false
          AND (expires_at > NOW() OR expires_at IS NULL)
      `;
      const params = [
        parseFloat(minLon),
        parseFloat(minLat),
        parseFloat(maxLon),
        parseFloat(maxLat),
      ];

      if (type) {
        sql += ` AND report_type = $${params.length + 1}`;
        params.push(type);
      }

      sql += ' ORDER BY created_at DESC';

      const { rows } = await pool.query(sql, params);
      res.json({ reports: rows });
    } catch (err) {
      logger.error('Failed to fetch reports', { err });
      next(err);
    }
  }
);

module.exports = router;
