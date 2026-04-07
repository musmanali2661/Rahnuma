'use strict';

const Redis = require('ioredis');
const logger = require('../utils/logger');

let client = null;

/**
 * Connect to Redis.
 */
async function connectRedis() {
  client = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    password: process.env.REDIS_PASSWORD || undefined,
    lazyConnect: true,
    enableReadyCheck: true,
    maxRetriesPerRequest: 3,
  });

  await client.connect();
  logger.info('Redis connected');
}

/**
 * Get the Redis client (throws if not connected).
 */
function getClient() {
  if (!client) throw new Error('Redis not initialised. Call connectRedis() first.');
  return client;
}

module.exports = { connectRedis, getClient };
