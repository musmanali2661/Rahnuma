/**
 * Format metres into a human-readable distance string.
 */
export function formatDistance(metres) {
  if (metres == null) return '';
  if (metres < 1000) return `${Math.round(metres)} m`;
  return `${(metres / 1000).toFixed(1)} km`;
}

/**
 * Format seconds into a human-readable duration string.
 */
export function formatDuration(seconds) {
  if (seconds == null) return '';
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h} hr ${m} min`;
  if (m > 0) return `${m} min`;
  return `${Math.round(seconds)} sec`;
}

/**
 * Format a UNIX timestamp (ms) to a locale time string.
 */
export function formatTime(ms) {
  return new Date(ms).toLocaleTimeString('en-PK', { hour: '2-digit', minute: '2-digit' });
}
