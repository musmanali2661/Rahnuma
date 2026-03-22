'use strict';

const express = require('express');
const { body, query, validationResult } = require('express-validator');
const osrmService = require('../../services/osrmService');
const logger = require('../../utils/logger');

const router = express.Router();

/**
 * POST /api/v1/route
 * Calculate a route between waypoints.
 *
 * Body: { waypoints: [{lat, lon}], profile?: "car"|"bike"|"foot", alternatives?: boolean }
 */
router.post(
  '/',
  [
    body('waypoints')
      .isArray({ min: 2, max: 10 })
      .withMessage('waypoints must be an array of 2–10 coordinates'),
    body('waypoints.*.lat').isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
    body('waypoints.*.lon').isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
    body('profile').optional().isIn(['car', 'bike', 'foot']),
    body('alternatives').optional().isBoolean(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { waypoints, profile = 'car', alternatives = false } = req.body;
      const route = await osrmService.getRoute(waypoints, { profile, alternatives });
      res.json(route);
    } catch (err) {
      logger.error('Route calculation failed', { err });
      next(err);
    }
  }
);

/**
 * GET /api/v1/route/snap
 * Snap a coordinate to the nearest road.
 */
router.get(
  '/snap',
  [
    query('lat').isFloat({ min: -90, max: 90 }),
    query('lon').isFloat({ min: -180, max: 180 }),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { lat, lon } = req.query;
      const snapped = await osrmService.snapToRoad(parseFloat(lat), parseFloat(lon));
      res.json(snapped);
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
