-- Rahnuma — Road events geospatial optimisation
-- Run after 001_initial_schema.sql

-- Cluster road_events by location for faster spatial queries
CLUSTER road_events USING road_events_location_idx;

-- Partial index: only verified events (most queries filter by verified = true)
CREATE INDEX IF NOT EXISTS road_events_verified_location_idx
    ON road_events USING GIST (location)
    WHERE verified = true;

-- Add spatial aggregation helper function
CREATE OR REPLACE FUNCTION cluster_road_events(
    p_radius_m FLOAT DEFAULT 30.0
)
RETURNS TABLE (
    event_type  VARCHAR,
    lat         FLOAT,
    lon         FLOAT,
    count       BIGINT,
    avg_confidence FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        re.event_type,
        AVG(ST_Y(re.location)) AS lat,
        AVG(ST_X(re.location)) AS lon,
        COUNT(*)               AS count,
        AVG(re.confidence)     AS avg_confidence
    FROM road_events re
    WHERE re.verified = TRUE
    GROUP BY
        re.event_type,
        ST_SnapToGrid(re.location, p_radius_m / 111320.0)
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;
