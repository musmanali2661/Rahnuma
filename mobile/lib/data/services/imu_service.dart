import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/constants/app_constants.dart';
import '../models/road_event_model.dart';

/// IMU Service – detects potholes and speed bumps from accelerometer data.
///
/// Algorithm:
/// 1. Compute the magnitude of the acceleration vector (excluding gravity).
/// 2. Compare with thresholds from [AppConstants].
/// 3. Enforce a per-event cooldown to avoid duplicates.
/// 4. Accumulate detected events; caller drains them via [drainEvents].
class ImuService {
  ImuService._();

  static final ImuService instance = ImuService._();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastEventTime;
  final List<RoadEventModel> _pendingEvents = [];
  double _currentSpeedKmh = 0;
  double? _currentLat;
  double? _currentLon;

  /// Update the current speed (from GPS) to gate IMU event detection.
  void updateSpeed(double speedMs) {
    _currentSpeedKmh = speedMs * 3.6;
  }

  /// Update current GPS position so events can be geo-tagged.
  void updatePosition(double lat, double lon) {
    _currentLat = lat;
    _currentLon = lon;
  }

  /// Start listening to the accelerometer.
  void start() {
    _accelSub ??= accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20), // ~50 Hz
    ).listen(_onAccelerometer);
  }

  /// Stop listening.
  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
  }

  /// Return and clear all pending events collected since the last call.
  List<RoadEventModel> drainEvents() {
    final copy = List<RoadEventModel>.from(_pendingEvents);
    _pendingEvents.clear();
    return copy;
  }

  int get pendingCount => _pendingEvents.length;

  void _onAccelerometer(AccelerometerEvent event) {
    // Only detect when vehicle is moving
    if (_currentSpeedKmh < AppConstants.imuMinSpeedKmh) return;
    if (_currentLat == null || _currentLon == null) return;

    // Magnitude of the acceleration vector
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Subtract gravity (≈9.81 m/s²) to get net impact
    final impact = (magnitude - 9.81).abs();

    RoadEventType? detectedType;
    double confidence = 0;

    if (impact >= AppConstants.imuPotholeThreshold) {
      detectedType = RoadEventType.pothole;
      confidence = math.min(1.0, impact / 25.0);
    } else if (impact >= AppConstants.imuSpeedBumpThreshold) {
      detectedType = RoadEventType.speedBump;
      confidence = math.min(1.0, impact / 20.0);
    }

    if (detectedType == null) return;

    // Cooldown check
    final now = DateTime.now();
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!).inSeconds <
            AppConstants.imuEventCooldownSec) {
      return;
    }

    _lastEventTime = now;
    _pendingEvents.add(RoadEventModel(
      lat: _currentLat!,
      lon: _currentLon!,
      eventType: detectedType,
      confidence: (confidence * 100).round() / 100,
    ));
  }
}
