const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

async function request(path, options = {}) {
  const url = `${API_BASE}${path}`;
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw Object.assign(new Error(body.error || `HTTP ${res.status}`), { status: res.status });
  }
  return res.json();
}

export function searchPlaces(q, { lat, lon, limit = 10, category } = {}) {
  const params = new URLSearchParams({ q, limit });
  if (lat != null) params.set('lat', lat);
  if (lon != null) params.set('lon', lon);
  if (category) params.set('category', category);
  return request(`/api/v1/search?${params}`);
}

export function calculateRoute(waypoints, { profile = 'car', alternatives = false } = {}) {
  return request('/api/v1/route', {
    method: 'POST',
    body: JSON.stringify({ waypoints, profile, alternatives }),
  });
}

export function getEvents({ minLat, minLon, maxLat, maxLon, type } = {}) {
  const params = new URLSearchParams({ minLat, minLon, maxLat, maxLon });
  if (type) params.set('type', type);
  return request(`/api/v1/events?${params}`);
}

export function listOfflinePackages() {
  return request('/api/v1/offline/packages');
}
