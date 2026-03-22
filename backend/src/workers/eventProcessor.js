'use strict';

const { getPool } = require('../database/postgres');
const logger = require('../utils/logger');

/**
 * Process batched IMU events from the ML service and mark valid ones as verified.
 * Runs periodically to aggregate similar events and filter noise.
 */
async function processEvents() {
  const pool = getPool();

  // Radius (metres) within which multiple reports of the same event type
  // count toward verification. Tunable based on real-world data in Phase 2.
  const VERIFICATION_RADIUS_METERS = 50;

  try {
    // Mark events verified if enough users reported the same location
    const { rowCount } = await pool.query(`
      UPDATE road_events re
      SET verified = true
      WHERE NOT verified
        AND (
          SELECT COUNT(*) FROM road_events re2
          WHERE re2.event_type = re.event_type
            AND ST_DWithin(re2.location, re.location, $1)
            AND re2.created_at > NOW() - INTERVAL '7 days'
        ) >= 2
    `, [VERIFICATION_RADIUS_METERS]);

    if (rowCount > 0) {
      logger.info(`Event processor: verified ${rowCount} events`);
    }

    // Remove expired unverified events
    const { rowCount: deleted } = await pool.query(`
      DELETE FROM road_events
      WHERE verified = false
        AND created_at < NOW() - INTERVAL '24 hours'
    `);

    if (deleted > 0) {
      logger.info(`Event processor: cleaned ${deleted} stale events`);
    }
  } catch (err) {
    logger.error('Event processor error', { err });
  }
}

// Run every 5 minutes
if (require.main === module) {
  setInterval(processEvents, 5 * 60 * 1000);
  processEvents();
}

module.exports = { processEvents };
