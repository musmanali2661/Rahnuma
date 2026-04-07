# Rahnuma API Documentation

Base URL: `http://localhost:4000/api/v1`

---

## Authentication

Most endpoints are public. Endpoints that require authentication use Bearer JWT tokens:

```
Authorization: Bearer <token>
```

---

## Endpoints

### `GET /health`
Health check.

**Response:**
```json
{ "status": "ok", "ts": 1700000000000 }
```

---

### `POST /route`
Calculate a route between two or more waypoints.

**Request body:**
```json
{
  "waypoints": [
    { "lat": 33.7215, "lon": 73.0479 },
    { "lat": 31.5497, "lon": 74.3436 }
  ],
  "profile": "car",
  "alternatives": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `waypoints` | array | 2–10 `{lat, lon}` objects |
| `profile` | string | `car` \| `bike` \| `foot` (default: `car`) |
| `alternatives` | boolean | Return up to 3 alternative routes |

**Response:**
```json
{
  "routes": [
    {
      "distance": 352000,
      "duration": 14400,
      "geometry": { "type": "LineString", "coordinates": [...] },
      "legs": [...],
      "summary": "M-2",
      "toll_estimate_pkr": 685
    }
  ],
  "waypoints": [...]
}
```

---

### `GET /search?q=&lat=&lon=&limit=&category=`
Search for places (supports Roman Urdu + English).

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query (required) |
| `lat` | float | User latitude for biasing |
| `lon` | float | User longitude for biasing |
| `limit` | int | Max results (default 10, max 20) |
| `category` | string | `petrol` \| `food` \| `mosque` \| `hospital` |

**Response:**
```json
[
  {
    "place_id": 12345,
    "name": "Liberty Market, Lahore",
    "lat": 31.512,
    "lon": 74.332,
    "type": "marketplace",
    "address": { "city": "Lahore", "country": "Pakistan" }
  }
]
```

---

### `GET /search/reverse?lat=&lon=`
Reverse geocode a coordinate to an address.

---

### `GET /events?minLat=&minLon=&maxLat=&maxLon=&type=`
Get road events (potholes, speed bumps) in a bounding box.

| Parameter | Type | Description |
|-----------|------|-------------|
| `minLat`, `minLon`, `maxLat`, `maxLon` | float | Bounding box |
| `type` | string | `pothole` \| `speed_bump` \| `rough_road` |
| `limit` | int | Max events (default 200, max 500) |

**Response:**
```json
{
  "events": [
    {
      "id": "uuid",
      "event_type": "pothole",
      "confidence": 0.87,
      "geojson": { "type": "Point", "coordinates": [74.3, 31.5] },
      "created_at": "2026-03-01T10:00:00Z",
      "verified": true
    }
  ]
}
```

---

### `POST /events` _(Requires Auth)_
Submit road events from IMU sensor data.

**Request body:**
```json
{
  "events": [
    { "lat": 31.512, "lon": 74.332, "event_type": "pothole", "confidence": 0.85 }
  ]
}
```

---

### `GET /offline/packages`
List available offline map packages.

**Response:**
```json
{
  "packages": [
    {
      "id": "lahore",
      "name": "Lahore",
      "size_mb": 380,
      "available": true,
      "file_size_bytes": 398458880,
      "last_updated": "2026-03-01T00:00:00Z"
    }
  ]
}
```

---

### `GET /offline/packages/:city`
Download the MBTiles package for a city.

Returns the `.mbtiles` file as a binary download (`application/x-sqlite3`).

---

## WebSocket — Live Tracking

Connect to: `ws://localhost:4000/ws?session=<sessionId>`

**Outgoing messages:**
```json
{ "type": "location_update", "payload": { "lat": 33.7, "lon": 73.0 }, "ref": 1234 }
```

**Incoming messages:**
```json
{ "type": "ack", "ref": 1234 }
{ "type": "pong", "ts": 1700000000000 }
```

---

## Error Responses

All errors return JSON with an `error` field:

```json
{ "error": "Description of the problem" }
```

| Status | Meaning |
|--------|---------|
| 400 | Validation error |
| 401 | Authentication required |
| 404 | Resource not found |
| 422 | Routing error (e.g., no route found) |
| 429 | Rate limit exceeded |
| 502 | Upstream service error (OSRM/Nominatim) |
| 503 | Service unavailable |
