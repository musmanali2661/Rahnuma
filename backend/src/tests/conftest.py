"""
Shared pytest fixtures for Rahnuma ML service tests.
"""
import sys
import os

import pytest

# Make the services directory importable
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'services'))

from mlService import SensorReading, ClassifyRequest


def _make_reading(az: float, lat: float = 31.5, lon: float = 74.3, t: int = 0) -> SensorReading:
    """Create a SensorReading with the given vertical acceleration."""
    return SensorReading(
        timestamp_ms=t,
        ax=0.0,
        ay=0.0,
        az=az,
        lat=lat,
        lon=lon,
    )


@pytest.fixture
def synthetic_pothole_readings() -> ClassifyRequest:
    """
    A ClassifyRequest with a large spike at position 0 so the moving-average
    output at i=0 exceeds the 2g pothole threshold before the rough-road
    window check fires.
    """
    G = 9.81
    readings = []
    # Large spike at position 0 (25g)
    readings.append(_make_reading(az=25 * G, lat=31.5, lon=74.3, t=0))
    # Return to baseline
    for i in range(20):
        readings.append(_make_reading(az=G, lat=31.5, lon=74.3, t=10 + i * 10))
    return ClassifyRequest(readings=readings)


@pytest.fixture
def synthetic_speed_bump_readings() -> ClassifyRequest:
    """
    A ClassifyRequest with 10 consecutive readings at 2.8g so the
    moving-average filtered value reaches ~1.8g, above the 1.5g
    speed-bump threshold with sufficient sustained count.
    """
    G = 9.81
    readings = []
    # Baseline
    for i in range(10):
        readings.append(_make_reading(az=G, lat=31.5, lon=74.3, t=i * 10))
    # Speed bump: 2.8g sustained over 10 samples
    for i in range(10):
        readings.append(_make_reading(az=2.8 * G, lat=31.5, lon=74.3, t=100 + i * 10))
    # Return to baseline
    for i in range(5):
        readings.append(_make_reading(az=G, lat=31.5, lon=74.3, t=200 + i * 10))
    return ClassifyRequest(readings=readings)


@pytest.fixture
def synthetic_rough_road_readings() -> ClassifyRequest:
    """
    A ClassifyRequest with 11 calm readings followed by alternating
    10g / baseline readings, creating a high-std window at i=0 that
    triggers rough_road classification.
    """
    G = 9.81
    readings = []
    # Calm beginning
    for i in range(11):
        readings.append(_make_reading(az=G, lat=31.5, lon=74.3, t=i * 10))
    # High-variance: alternating 10g and baseline
    for i in range(10):
        az = 10 * G if i % 2 == 0 else G
        readings.append(_make_reading(az=az, lat=31.5, lon=74.3, t=110 + i * 10))
    return ClassifyRequest(readings=readings)
