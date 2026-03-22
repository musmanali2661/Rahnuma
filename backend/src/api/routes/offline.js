'use strict';

const express = require('express');
const path = require('path');
const fs = require('fs');
const offlineService = require('../../services/offlineService');

const router = express.Router();

/**
 * GET /api/v1/offline/packages
 * List available offline map packages (city-level MBTiles).
 */
router.get('/packages', async (_req, res, next) => {
  try {
    const packages = await offlineService.listPackages();
    res.json({ packages });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/offline/packages/:city
 * Download MBTiles package for a city.
 */
router.get('/packages/:city', async (req, res, next) => {
  try {
    const { city } = req.params;
    const filePath = await offlineService.getPackagePath(city);

    if (!filePath || !fs.existsSync(filePath)) {
      return res.status(404).json({ error: `Package for "${city}" not found` });
    }

    const fileName = `${city}.mbtiles`;
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
    res.setHeader('Content-Type', 'application/x-sqlite3');
    res.sendFile(path.resolve(filePath));
  } catch (err) {
    next(err);
  }
});

module.exports = router;
