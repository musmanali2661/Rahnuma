'use strict';

const express = require('express');
const { query, validationResult } = require('express-validator');
const nominatimService = require('../../services/nominatimService');

const router = express.Router();

/**
 * GET /api/v1/search?q=&lat=&lon=&limit=
 * Search for places using Nominatim (supports Roman Urdu + English).
 */
router.get(
  '/',
  [
    query('q').isString().notEmpty().withMessage('Search query is required'),
    query('lat').optional().isFloat({ min: -90, max: 90 }),
    query('lon').optional().isFloat({ min: -180, max: 180 }),
    query('limit').optional().isInt({ min: 1, max: 20 }).toInt(),
    query('category').optional().isString(),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { q, lat, lon, limit = 10, category } = req.query;
      const results = await nominatimService.search(q, {
        lat: lat ? parseFloat(lat) : undefined,
        lon: lon ? parseFloat(lon) : undefined,
        limit,
        category,
      });
      res.json(results);
    } catch (err) {
      next(err);
    }
  }
);

/**
 * GET /api/v1/search/reverse?lat=&lon=
 * Reverse geocode a coordinate to an address.
 */
router.get(
  '/reverse',
  [
    query('lat').isFloat({ min: -90, max: 90 }),
    query('lon').isFloat({ min: -180, max: 180 }),
  ],
  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { lat, lon } = req.query;
      const result = await nominatimService.reverseGeocode(parseFloat(lat), parseFloat(lon));
      res.json(result);
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
