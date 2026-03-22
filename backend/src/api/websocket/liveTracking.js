'use strict';

const { WebSocketServer } = require('ws');
const logger = require('../../utils/logger');

/** Map of sessionId → WebSocket */
const sessions = new Map();

/**
 * Initialise the WebSocket server on an existing HTTP server.
 * Clients connect to ws://host/ws?session=<id>
 */
function initWebSocket(server) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', (ws, req) => {
    const url = new URL(req.url, 'http://localhost');
    const sessionId = url.searchParams.get('session') || `anon-${Date.now()}`;

    logger.info(`WebSocket connected: ${sessionId}`);
    sessions.set(sessionId, ws);

    ws.on('message', (raw) => {
      try {
        const msg = JSON.parse(raw.toString());
        handleMessage(sessionId, ws, msg);
      } catch (e) {
        ws.send(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });

    ws.on('close', () => {
      sessions.delete(sessionId);
      logger.info(`WebSocket disconnected: ${sessionId}`);
    });

    ws.on('error', (err) => logger.error('WebSocket error', { sessionId, err }));

    ws.send(JSON.stringify({ type: 'connected', sessionId }));
  });

  logger.info('WebSocket server initialised');
}

/**
 * Process an incoming WebSocket message.
 */
function handleMessage(sessionId, ws, msg) {
  switch (msg.type) {
    case 'location_update':
      // Broadcast location to any interested subscribers (Phase 2: group tracking)
      logger.debug(`Location update from ${sessionId}`, msg.payload);
      ws.send(JSON.stringify({ type: 'ack', ref: msg.ref }));
      break;

    case 'ping':
      ws.send(JSON.stringify({ type: 'pong', ts: Date.now() }));
      break;

    default:
      ws.send(JSON.stringify({ error: `Unknown message type: ${msg.type}` }));
  }
}

/**
 * Push a message to a specific session.
 */
function pushToSession(sessionId, payload) {
  const ws = sessions.get(sessionId);
  if (ws && ws.readyState === 1 /* OPEN */) {
    ws.send(JSON.stringify(payload));
  }
}

module.exports = { initWebSocket, pushToSession };
