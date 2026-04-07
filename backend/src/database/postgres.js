'use strict';

const { Pool } = require('pg');
const logger = require('../utils/logger');

let pool = null;

/**
 * Connect to PostgreSQL and run a quick health check.
 */
async function connectPostgres() {
  pool = new Pool({
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
    database: process.env.POSTGRES_DB || 'rahnuma',
    user: process.env.POSTGRES_USER || 'rahnuma',
    password: process.env.POSTGRES_PASSWORD || 'rahnuma_secret',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  });

  pool.on('error', (err) => logger.error('PostgreSQL pool error', { err }));

  // Verify connection
  const client = await pool.connect();
  await client.query('SELECT 1');
  client.release();

  logger.info('PostgreSQL connected');
}

/**
 * Get the shared pool (throws if not yet connected).
 */
function getPool() {
  if (!pool) throw new Error('PostgreSQL pool not initialised. Call connectPostgres() first.');
  return pool;
}

module.exports = { connectPostgres, getPool };
