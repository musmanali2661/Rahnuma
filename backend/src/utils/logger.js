'use strict';

const winston = require('winston');

const { combine, timestamp, printf, colorize, errors } = winston.format;

const level = process.env.LOG_LEVEL || (process.env.NODE_ENV === 'production' ? 'warn' : 'debug');

const logFormat = printf(({ level, message, timestamp, stack, ...meta }) => {
  let log = `${timestamp} [${level}] ${message}`;
  if (stack) log += `\n${stack}`;
  const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
  return log + metaStr;
});

const logger = winston.createLogger({
  level,
  format: combine(
    errors({ stack: true }),
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    process.env.NODE_ENV === 'production' ? winston.format.json() : combine(colorize(), logFormat)
  ),
  transports: [new winston.transports.Console()],
});

// Add HTTP level
logger.addColors({ http: 'magenta' });

module.exports = logger;
