'use strict';

const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { getPool } = require('../../database/postgres');
const logger = require('../../utils/logger');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/v1/events
 * Retrieve road events (potholes, speed bumps, rough roads) in a bounding box.
 */
router.get(
  '/',
  [
    query('minLat').isFloat({ min: -90, max: 90 }),
    query('minLon').isFloat({ min: -180, max: 180 }),
    query('maxLat').isFloat({ min: -90, max: 90 }),
    query('maxLon').isFloat({ min: -180, max: 180 }),
    query('type').optional().isIn(['pothole', 'speed_bump', 'rough_road']),
    query('limit').optional().isInt({ min: 1, max: 500 }).toInt(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { minLat, minLon, maxLat, maxLon, type, limit = 200 } = req.query;
      const pool = getPool();

      let sql = `
        SELECT id, event_type, confidence, ST_AsGeoJSON(location)::json AS geojson,
               created_at, verified
        FROM road_events
        WHERE location && ST_MakeEnvelope($1, $2, $3, $4, 4326)
          AND verified = true
      `;
      const params = [
        parseFloat(minLon),
        parseFloat(minLat),
        parseFloat(maxLon),
        parseFloat(maxLat),
      ];

      if (type) {
        sql += ` AND event_type = $${params.length + 1}`;
        params.push(type);
      }

      sql += ` ORDER BY confidence DESC LIMIT $${params.length + 1}`;
      params.push(limit);

      const { rows } = await pool.query(sql, params);
      res.json({ events: rows });
    } catch (err) {
      logger.error('Failed to fetch events', { err });
      next(err);
    }
  }
);

/**
 * POST /api/v1/events
 * Submit road event(s) from IMU sensor data.
 * Requires authentication.
 *
 * Note: GET /events is public (unauthenticated users can view verified events),
 * but POST /events requires a valid Bearer token so reports are tied to a user
 * account for spam prevention and reputation tracking.
 */
router.post(
  '/',
  authMiddleware.required,
  [
    body('events').isArray({ min: 1, max: 50 }),
    body('events.*.lat').isFloat({ min: -90, max: 90 }),
    body('events.*.lon').isFloat({ min: -180, max: 180 }),
    body('events.*.event_type').isIn(['pothole', 'speed_bump', 'rough_road']),
    body('events.*.confidence').isFloat({ min: 0, max: 1 }),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const pool = getPool();
      const userId = req.user.id;

      const inserted = [];
      for (const ev of req.body.events) {
        const { lat, lon, event_type, confidence } = ev;
        const { rows } = await pool.query(
          `INSERT INTO road_events (user_id, event_type, confidence, location)
           VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))
           ON CONFLICT DO NOTHING
           RETURNING id`,
          [userId, event_type, confidence, lon, lat]
        );
        if (rows[0]) inserted.push(rows[0].id);
      }

      res.status(201).json({ inserted: inserted.length, ids: inserted });
    } catch (err) {
      logger.error('Failed to insert events', { err });
      next(err);
    }
  }
);

module.exports = router;
