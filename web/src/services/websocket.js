const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:4000';

let ws = null;
let sessionId = null;
const listeners = new Map();

export function connectWebSocket(sid) {
  sessionId = sid || `web-${Date.now()}`;
  ws = new WebSocket(`${WS_URL}/ws?session=${sessionId}`);

  ws.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data);
      const handler = listeners.get(msg.type);
      if (handler) handler(msg);
    } catch (e) {
      console.error('WS parse error', e);
    }
  };

  ws.onerror = (e) => console.error('WebSocket error', e);
  ws.onclose = () => console.info('WebSocket closed');
}

export function sendLocation(lat, lon) {
  if (ws?.readyState !== WebSocket.OPEN) return;
  ws.send(JSON.stringify({ type: 'location_update', payload: { lat, lon }, ref: Date.now() }));
}

export function onMessage(type, handler) {
  listeners.set(type, handler);
}

export function disconnect() {
  ws?.close();
  ws = null;
}
