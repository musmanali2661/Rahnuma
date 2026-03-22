#!/usr/bin/env python3
"""
Rahnuma IMU Sensor Classification Service (Phase 1 Prototype)

Provides a FastAPI server for classifying road events from accelerometer data.
Uses simple threshold-based classification for Phase 1; LSTM/CNN in Phase 2.
"""

import os
import json
import logging
from typing import List, Optional
from datetime import datetime

import numpy as np
import psycopg2
import psycopg2.extras
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("mlService")

app = FastAPI(title="Rahnuma ML Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Database connection ───────────────────────────────────────────────────────

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", "5432")),
        dbname=os.getenv("POSTGRES_DB", "rahnuma"),
        user=os.getenv("POSTGRES_USER", "rahnuma"),
        password=os.getenv("POSTGRES_PASSWORD", "rahnuma_secret"),
    )

# ── Pydantic models ───────────────────────────────────────────────────────────

class SensorReading(BaseModel):
    timestamp_ms: int
    ax: float  # m/s²
    ay: float
    az: float
    gx: Optional[float] = 0.0  # rad/s
    gy: Optional[float] = 0.0
    gz: Optional[float] = 0.0
    lat: float
    lon: float

class ClassifyRequest(BaseModel):
    user_id: Optional[str] = None
    readings: List[SensorReading] = Field(..., min_length=1, max_length=500)

class EventResult(BaseModel):
    event_type: str
    confidence: float
    lat: float
    lon: float
    timestamp_ms: int

class ClassifyResponse(BaseModel):
    events: List[EventResult]
    processed: int

# ── Classification logic ──────────────────────────────────────────────────────

# Threshold constants (Phase 1 simple heuristics)
# These values are based on empirical testing with consumer Android devices
# on Pakistani roads. Values in g-force units (1g = 9.81 m/s²):
#   - Pothole: sharp vertical spike typically exceeds 2g on the Z-axis
#   - Speed bump: moderate sustained rise of 1.5g over ~200ms
#   - Rough road: sustained Z-axis variance > 0.8g RMS over 400ms window
# All thresholds will be replaced by an LSTM/CNN model in Phase 2 once
# labelled training data is collected.
POTHOLE_THRESHOLD_G = 2.0       # > 2g peak on Z-axis
SPEED_BUMP_THRESHOLD_G = 1.5    # 1.5–2g sustained over ~200ms
ROUGH_ROAD_THRESHOLD_G = 0.8    # Sustained variance > 0.8g

G = 9.81  # m/s² per g

def moving_average(values: np.ndarray, window: int = 5) -> np.ndarray:
    """Apply a simple moving average filter."""
    if len(values) < window:
        return values
    kernel = np.ones(window) / window
    return np.convolve(values, kernel, mode="same")

def classify_imu_window(readings: List[SensorReading]) -> List[EventResult]:
    """
    Classify a window of IMU readings into road events.

    Algorithm:
    1. Apply moving average to remove high-frequency noise
    2. Compute Z-axis acceleration magnitude (subtract gravity)
    3. Detect peaks above thresholds
    4. Classify based on peak magnitude and duration
    """
    if not readings:
        return []

    az = np.array([r.az for r in readings])
    timestamps = np.array([r.timestamp_ms for r in readings])
    lats = np.array([r.lat for r in readings])
    lons = np.array([r.lon for r in readings])

    # Remove gravity component (assume device is roughly level)
    az_detrended = az - np.median(az)

    # Apply noise filter
    az_filtered = moving_average(np.abs(az_detrended), window=5)

    events = []

    i = 0
    while i < len(az_filtered):
        val_g = az_filtered[i] / G

        if val_g > POTHOLE_THRESHOLD_G:
            # Sharp high-magnitude spike → pothole
            confidence = min(1.0, (val_g - POTHOLE_THRESHOLD_G) / POTHOLE_THRESHOLD_G * 0.5 + 0.7)
            events.append(EventResult(
                event_type="pothole",
                confidence=round(confidence, 3),
                lat=float(lats[i]),
                lon=float(lons[i]),
                timestamp_ms=int(timestamps[i]),
            ))
            i += 10  # skip ahead to avoid duplicate detection
            continue

        if val_g > SPEED_BUMP_THRESHOLD_G:
            # Moderate peak → speed bump
            # Check if it's sustained (at least 3 samples above threshold)
            window_end = min(i + 5, len(az_filtered))
            sustained = np.sum(az_filtered[i:window_end] / G > SPEED_BUMP_THRESHOLD_G)
            if sustained >= 2:
                confidence = min(1.0, 0.6 + 0.1 * sustained)
                events.append(EventResult(
                    event_type="speed_bump",
                    confidence=round(confidence, 3),
                    lat=float(lats[i]),
                    lon=float(lons[i]),
                    timestamp_ms=int(timestamps[i]),
                ))
                i += 8
                continue

        # Check for rough road (high variance over a 20-sample window)
        if i + 20 < len(az_filtered):
            window_std = np.std(az_filtered[i:i + 20] / G)
            if window_std > ROUGH_ROAD_THRESHOLD_G:
                mid = i + 10
                confidence = min(1.0, 0.5 + window_std * 0.2)
                events.append(EventResult(
                    event_type="rough_road",
                    confidence=round(confidence, 3),
                    lat=float(lats[mid]),
                    lon=float(lons[mid]),
                    timestamp_ms=int(timestamps[mid]),
                ))
                i += 20
                continue

        i += 1

    return events

def deduplicate_events(events: List[EventResult], radius_m: float = 20.0) -> List[EventResult]:
    """Remove duplicate events within radius_m metres of each other."""
    if len(events) <= 1:
        return events

    kept = []
    for ev in events:
        too_close = False
        for k in kept:
            if k.event_type == ev.event_type:
                dlat = (ev.lat - k.lat) * 111320
                dlon = (ev.lon - k.lon) * 111320 * abs(np.cos(np.radians(ev.lat)))
                dist = np.sqrt(dlat ** 2 + dlon ** 2)
                if dist < radius_m:
                    too_close = True
                    break
        if not too_close:
            kept.append(ev)

    return kept

# ── API endpoints ─────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "ts": datetime.utcnow().isoformat()}

@app.post("/classify", response_model=ClassifyResponse)
def classify(req: ClassifyRequest):
    """Classify IMU sensor readings into road events."""
    raw_events = classify_imu_window(req.readings)
    events = deduplicate_events(raw_events)

    # Persist to database
    if events:
        try:
            conn = get_db_connection()
            with conn.cursor() as cur:
                for ev in events:
                    cur.execute(
                        """
                        INSERT INTO road_events (user_id, event_type, confidence, location)
                        VALUES (%s, %s, %s, ST_SetSRID(ST_MakePoint(%s, %s), 4326))
                        ON CONFLICT DO NOTHING
                        """,
                        (req.user_id, ev.event_type, ev.confidence, ev.lon, ev.lat),
                    )
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"DB insert error: {e}")

    return ClassifyResponse(events=events, processed=len(req.readings))

if __name__ == "__main__":
    port = int(os.getenv("ML_SERVICE_PORT", "8000"))
    uvicorn.run(app, host="0.0.0.0", port=port)
