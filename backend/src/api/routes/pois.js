'use strict';

const express = require('express');
const { query, validationResult } = require('express-validator');
const { getPool } = require('../../database/postgres');
const logger = require('../../utils/logger');

const router = express.Router();

/**
 * GET /api/v1/pois
 * Return POIs within a bounding box.
 *
 * Query params: minLat, minLon, maxLat, maxLon (required), category (optional), limit (optional, 1-200, default 50)
 */
router.get(
  '/',
  [
    query('minLat').isFloat({ min: -90, max: 90 }).withMessage('minLat must be a valid latitude'),
    query('minLon').isFloat({ min: -180, max: 180 }).withMessage('minLon must be a valid longitude'),
    query('maxLat').isFloat({ min: -90, max: 90 }).withMessage('maxLat must be a valid latitude'),
    query('maxLon').isFloat({ min: -180, max: 180 }).withMessage('maxLon must be a valid longitude'),
    query('category').optional().isString().trim(),
    query('limit').optional().isInt({ min: 1, max: 200 }).toInt(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { minLat, minLon, maxLat, maxLon, category, limit = 50 } = req.query;
      const pool = getPool();

      let sql = `
        SELECT
          id,
          name,
          name_ur,
          category,
          tags->>'subcategory' AS subcategory,
          ST_Y(location::geometry) AS lat,
          ST_X(location::geometry) AS lon,
          (tags->>'rating_avg')::float AS rating_avg,
          (tags->>'rating_count')::int AS rating_count,
          tags->>'phone' AS phone,
          tags->>'opening_hours' AS opening_hours
        FROM pois
        WHERE location && ST_MakeEnvelope($1, $2, $3, $4, 4326)
      `;
      const params = [
        parseFloat(minLon),
        parseFloat(minLat),
        parseFloat(maxLon),
        parseFloat(maxLat),
      ];

      if (category) {
        sql += ` AND category = $${params.length + 1}`;
        params.push(category);
      }

      sql += ` LIMIT $${params.length + 1}`;
      params.push(limit);

      const { rows } = await pool.query(sql, params);
      res.json({ pois: rows });
    } catch (err) {
      logger.error('Failed to fetch POIs', { err });
      next(err);
    }
  }
);

/**
 * GET /api/v1/pois/:id
 * Return a single POI by UUID.
 */
router.get('/:id', async (req, res, next) => {
  try {
    const pool = getPool();
    const { rows } = await pool.query(
      `SELECT
         id,
         name,
         name_ur,
         category,
         tags->>'subcategory' AS subcategory,
         ST_Y(location::geometry) AS lat,
         ST_X(location::geometry) AS lon,
         (tags->>'rating_avg')::float AS rating_avg,
         (tags->>'rating_count')::int AS rating_count,
         tags->>'phone' AS phone,
         tags->>'opening_hours' AS opening_hours
       FROM pois
       WHERE id = $1`,
      [req.params.id]
    );

    if (!rows.length) {
      return res.status(404).json({ error: 'POI not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    logger.error('Failed to fetch POI', { err });
    next(err);
  }
});

module.exports = router;
