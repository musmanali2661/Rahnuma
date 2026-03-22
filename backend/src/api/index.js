'use strict';

const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

const logger = require('../utils/logger');
const { connectPostgres } = require('../database/postgres');
const { connectRedis } = require('../database/redis');
const routeRouter = require('./routes/route');
const searchRouter = require('./routes/search');
const eventsRouter = require('./routes/events');
const offlineRouter = require('./routes/offline');
const authMiddleware = require('./middleware/auth');
const rateLimitMiddleware = require('./middleware/rateLimit');
const validationErrorHandler = require('./middleware/validation');
const { initWebSocket } = require('./websocket/liveTracking');

const app = express();
const server = http.createServer(app);

// ── Security & parsing middleware ────────────────────────────────────────────
app.use(helmet());
app.use(compression());
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

// ── CORS ─────────────────────────────────────────────────────────────────────
const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:5173').split(',');
app.use(
  cors({
    origin: (origin, cb) => {
      if (!origin || allowedOrigins.includes(origin)) return cb(null, true);
      cb(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true,
  })
);

// ── HTTP request logging ─────────────────────────────────────────────────────
app.use(
  morgan('combined', {
    stream: { write: (msg) => logger.http(msg.trim()) },
    skip: (req) => req.url === '/health',
  })
);

// ── Rate limiting ────────────────────────────────────────────────────────────
app.use('/api/', rateLimitMiddleware);

// ── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => res.json({ status: 'ok', ts: Date.now() }));

// ── API routes ───────────────────────────────────────────────────────────────
app.use('/api/v1/route', routeRouter);
app.use('/api/v1/search', searchRouter);
app.use('/api/v1/events', authMiddleware.optional, eventsRouter);
app.use('/api/v1/offline', offlineRouter);

// ── Validation error handler ─────────────────────────────────────────────────
app.use(validationErrorHandler);

// ── Generic error handler ────────────────────────────────────────────────────
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  logger.error(err.message, { stack: err.stack });
  const status = err.status || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});

// ── Start ────────────────────────────────────────────────────────────────────
const PORT = parseInt(process.env.PORT || '4000', 10);

async function start() {
  try {
    await connectPostgres();
    await connectRedis();
    initWebSocket(server);

    server.listen(PORT, () => {
      logger.info(`Rahnuma backend running on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
    });
  } catch (err) {
    logger.error('Failed to start server', { err });
    process.exit(1);
  }
}

start();

module.exports = { app, server }; // for testing
