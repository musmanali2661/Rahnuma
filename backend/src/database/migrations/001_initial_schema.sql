-- Rahnuma — Initial database schema
-- Requires PostgreSQL 14+ and PostGIS 3.x

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username      VARCHAR(64) UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name  VARCHAR(128),
    language      VARCHAR(8) DEFAULT 'ur',        -- 'ur' or 'en'
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at  TIMESTAMPTZ,
    is_active     BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS users_email_idx ON users (email);

-- ── Vehicles ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vehicles (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(32) NOT NULL,  -- car, motorcycle, truck, bus, rickshaw
    make        VARCHAR(64),
    model       VARCHAR(64),
    year        SMALLINT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS vehicles_user_idx ON vehicles (user_id);

-- ── Road Events (IMU sensor detections) ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS road_events (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type  VARCHAR(32) NOT NULL,  -- pothole, speed_bump, rough_road
    confidence  FLOAT NOT NULL CHECK (confidence BETWEEN 0 AND 1),
    location    GEOMETRY(Point, 4326) NOT NULL,
    verified    BOOLEAN DEFAULT FALSE,
    upvotes     INTEGER DEFAULT 0,
    downvotes   INTEGER DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS road_events_location_idx ON road_events USING GIST (location);
CREATE INDEX IF NOT EXISTS road_events_type_idx ON road_events (event_type);
CREATE INDEX IF NOT EXISTS road_events_verified_idx ON road_events (verified);

-- ── User Reports (crowd-sourced incidents) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS user_reports (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID REFERENCES users(id) ON DELETE SET NULL,
    report_type  VARCHAR(32) NOT NULL,  -- accident, road_closure, flood, construction
    description  TEXT,
    location     GEOMETRY(Point, 4326) NOT NULL,
    verified     BOOLEAN DEFAULT FALSE,
    resolved     BOOLEAN DEFAULT FALSE,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    expires_at   TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours'
);

CREATE INDEX IF NOT EXISTS user_reports_location_idx ON user_reports USING GIST (location);
CREATE INDEX IF NOT EXISTS user_reports_type_idx ON user_reports (report_type);
CREATE INDEX IF NOT EXISTS user_reports_expires_idx ON user_reports (expires_at);

-- ── Points of Interest ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pois (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    osm_id      BIGINT UNIQUE,
    name        VARCHAR(256),
    name_ur     VARCHAR(256),          -- Urdu name
    category    VARCHAR(64),           -- petrol, food, mosque, hospital, etc.
    location    GEOMETRY(Point, 4326) NOT NULL,
    address     JSONB,
    tags        JSONB,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS pois_location_idx ON pois USING GIST (location);
CREATE INDEX IF NOT EXISTS pois_category_idx ON pois (category);
CREATE INDEX IF NOT EXISTS pois_name_idx ON pois USING GIN (to_tsvector('simple', coalesce(name, '')));

-- ── Trips ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS trips (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID REFERENCES users(id) ON DELETE SET NULL,
    vehicle_id     UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    origin         GEOMETRY(Point, 4326),
    destination    GEOMETRY(Point, 4326),
    route_geometry GEOMETRY(LineString, 4326),
    distance_m     FLOAT,
    duration_s     FLOAT,
    started_at     TIMESTAMPTZ,
    ended_at       TIMESTAMPTZ,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS trips_user_idx ON trips (user_id);
CREATE INDEX IF NOT EXISTS trips_created_idx ON trips (created_at DESC);
