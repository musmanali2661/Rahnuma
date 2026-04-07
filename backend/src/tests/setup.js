'use strict';

/**
 * Shared test setup — mocks the database and Redis modules.
 * Import this in test files via `require('../setup')` or configure
 * jest.setup in package.json.
 *
 * Usage in each test file:
 *   jest.mock('../../database/postgres', () => require('../setup').pgMock);
 *   jest.mock('../../database/redis', () => require('../setup').redisMock);
 */

// ── Postgres mock ────────────────────────────────────────────────────────────
const mockQuery = jest.fn();
const mockPool = { query: mockQuery };

const pgMock = {
  getPool: jest.fn(() => mockPool),
  connectPostgres: jest.fn(),
};

// ── Redis mock ───────────────────────────────────────────────────────────────
const mockRedis = {
  get: jest.fn(),
  set: jest.fn(),
  del: jest.fn(),
};

const redisMock = {
  connectRedis: jest.fn(),
  getRedis: jest.fn(() => mockRedis),
};

/**
 * Returns a fresh Express app instance without starting the server.
 * Relies on `if (require.main === module) { start(); }` guard in index.js.
 */
function makeApp() {
  // Clear module cache so each test gets a fresh app
  jest.resetModules();
  const { app } = require('../api/index');
  return app;
}

module.exports = { pgMock, redisMock, mockPool, mockQuery, mockRedis, makeApp };
