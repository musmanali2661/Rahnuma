'use strict';

const rateLimit = require('express-rate-limit');

const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10);
const max = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10);

module.exports = rateLimit({
  windowMs,
  max,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' },
});
