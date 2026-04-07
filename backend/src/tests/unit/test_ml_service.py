"""
Unit tests for the Rahnuma ML classification service.

Tests the pure classification logic directly — no FastAPI server is started.
"""
import sys
import os
import math

import pytest
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'services'))

from mlService import (
    SensorReading,
    ClassifyRequest,
    EventResult,
    moving_average,
    classify_imu_window,
    deduplicate_events,
)

G = 9.81  # m/s² per g


# ── Helpers ───────────────────────────────────────────────────────────────────

def make_reading(az: float, lat: float = 31.5, lon: float = 74.3, t: int = 0) -> SensorReading:
    return SensorReading(timestamp_ms=t, ax=0.0, ay=0.0, az=az, lat=lat, lon=lon)


def make_event(event_type: str, lat: float = 31.5, lon: float = 74.3) -> EventResult:
    return EventResult(event_type=event_type, confidence=0.8, lat=lat, lon=lon, timestamp_ms=0)


# ── moving_average ────────────────────────────────────────────────────────────

class TestMovingAverage:
    def test_output_length_same_as_input(self):
        arr = np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0])
        result = moving_average(arr, window=3)
        assert len(result) == len(arr)

    def test_smoothing_effect(self):
        """Output should have lower variance than raw spiky input."""
        arr = np.array([0.0, 10.0, 0.0, 10.0, 0.0, 10.0, 0.0, 10.0, 0.0, 10.0])
        result = moving_average(arr, window=5)
        assert np.std(result) < np.std(arr)

    def test_passes_through_short_array(self):
        arr = np.array([1.0, 2.0])
        result = moving_average(arr, window=5)
        np.testing.assert_array_equal(result, arr)


# ── classify_imu_window ───────────────────────────────────────────────────────

class TestClassifyPothole:
    def test_classifies_spike_above_2g_as_pothole(self):
        # Spike at position 0 (start of readings) — the moving-average at i=0
        # includes the spike via the convolution window, so val_g > 2g fires
        # before the rough-road std check can fire.
        readings = [make_reading(az=25 * G, t=0)]
        readings += [make_reading(az=G, t=10 + i * 10) for i in range(20)]

        events = classify_imu_window(readings)
        potholes = [e for e in events if e.event_type == 'pothole']
        assert len(potholes) >= 1

    def test_no_pothole_without_spike(self):
        readings = [make_reading(az=G, t=i * 10) for i in range(20)]
        events = classify_imu_window(readings)
        potholes = [e for e in events if e.event_type == 'pothole']
        assert len(potholes) == 0


class TestClassifySpeedBump:
    def test_classifies_sustained_1_5g_as_speed_bump(self):
        # Need 10 consecutive readings at 2.8g so the moving average of the
        # detrended signal reaches ~1.8g, above the 1.5g speed-bump threshold.
        readings = [make_reading(az=G, t=i * 10) for i in range(10)]
        for i in range(10):
            readings.append(make_reading(az=2.8 * G, t=100 + i * 10))
        readings += [make_reading(az=G, t=200 + i * 10) for i in range(5)]

        events = classify_imu_window(readings)
        speed_bumps = [e for e in events if e.event_type == 'speed_bump']
        assert len(speed_bumps) >= 1


class TestClassifyRoughRoad:
    def test_classifies_high_variance_signal_as_rough_road(self):
        # 11 calm readings followed by alternating 10g / baseline creates a
        # high-std window starting at index 0 (val_g ≈ 0 there), so the
        # rough-road branch is reached with window_std >> 0.8.
        readings = [make_reading(az=G, t=i * 10) for i in range(11)]
        for i in range(10):
            az = 10 * G if i % 2 == 0 else G
            readings.append(make_reading(az=az, lat=31.5, lon=74.3, t=110 + i * 10))

        events = classify_imu_window(readings)
        rough_roads = [e for e in events if e.event_type == 'rough_road']
        assert len(rough_roads) >= 1


class TestClassifyEmpty:
    def test_empty_readings_returns_empty_list(self):
        events = classify_imu_window([])
        assert events == []


# ── deduplicate_events ────────────────────────────────────────────────────────

class TestDeduplicateEvents:
    def test_removes_two_potholes_within_5m(self):
        """Two potholes 5m apart should be deduplicated to 1."""
        # 5m difference in lat ≈ 5 / 111320 degrees
        delta = 5.0 / 111320
        e1 = make_event('pothole', lat=31.5, lon=74.3)
        e2 = make_event('pothole', lat=31.5 + delta, lon=74.3)

        result = deduplicate_events([e1, e2])
        assert len(result) == 1

    def test_keeps_pothole_and_speed_bump_at_same_location(self):
        """Different event types at same location should both be kept."""
        e1 = make_event('pothole', lat=31.5, lon=74.3)
        e2 = make_event('speed_bump', lat=31.5, lon=74.3)

        result = deduplicate_events([e1, e2])
        assert len(result) == 2

    def test_keeps_two_potholes_50m_apart(self):
        """Two potholes 50m apart should NOT be deduplicated."""
        delta = 50.0 / 111320
        e1 = make_event('pothole', lat=31.5, lon=74.3)
        e2 = make_event('pothole', lat=31.5 + delta, lon=74.3)

        result = deduplicate_events([e1, e2])
        assert len(result) == 2

    def test_single_event_unchanged(self):
        e = make_event('pothole')
        result = deduplicate_events([e])
        assert len(result) == 1

    def test_empty_list(self):
        assert deduplicate_events([]) == []


# ── confidence_bounds ─────────────────────────────────────────────────────────

class TestConfidenceBounds:
    def test_all_confidence_values_between_0_and_1(self):
        # Use a large spike (15g) to ensure at least one event is classified
        readings = [make_reading(az=G, t=i * 10) for i in range(5)]
        readings.append(make_reading(az=15 * G, t=60))
        readings += [make_reading(az=G, t=70 + i * 10) for i in range(5)]

        events = classify_imu_window(readings)
        for ev in events:
            assert 0.0 <= ev.confidence <= 1.0, f"Confidence {ev.confidence} out of bounds"
