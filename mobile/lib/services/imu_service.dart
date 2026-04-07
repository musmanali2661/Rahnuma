import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../core/constants.dart';
import '../models/road_event.dart';

/// Gravity constant (m/s²).
const double _kG = 9.81;

/// Phase 1 threshold constants for heuristic road-event classification.
/// These will be replaced by an on-device LSTM model in Phase 2.
const double _kPotholeThresholdG = 2.0;
const double _kSpeedBumpThresholdG = 1.5;
const double _kRoughRoadStdG = 0.8;

/// Collects accelerometer data and classifies road events using the same
/// threshold-based algorithm as the Python ML service (Phase 1 prototype).
///
/// Usage:
/// ```dart
/// final imu = ImuService();
/// imu.start(onEvent: (event) { ... });
/// imu.stop();
/// ```
class ImuService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final List<_ImuReading> _buffer = [];
  Timer? _processTimer;

  /// Current GPS position injected from the location provider.
  double? currentLat;
  double? currentLon;

  void Function(RoadEvent event)? _onEvent;

  /// Start collecting IMU data.
  void start({required void Function(RoadEvent event) onEvent}) {
    _onEvent = onEvent;
    _buffer.clear();

    _subscription = accelerometerEventStream(
      samplingPeriod: Duration(milliseconds: kImuSampleIntervalMs),
    ).listen(_onAccelerometerEvent);

    _processTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _processBuffer();
    });
  }

  /// Stop collecting IMU data and clear the buffer.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _processTimer?.cancel();
    _processTimer = null;
    _buffer.clear();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final lat = currentLat;
    final lon = currentLon;
    if (lat == null || lon == null) return;

    _buffer.add(_ImuReading(
      az: event.z,
      lat: lat,
      lon: lon,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    ));

    if (_buffer.length > kImuBatchSize * 2) {
      _buffer.removeRange(0, kImuBatchSize);
    }
  }

  void _processBuffer() {
    if (_buffer.length < 10) return;

    final readings = List<_ImuReading>.from(_buffer);
    _buffer.clear();

    final events = _classifyWindow(readings);
    final deduped = _deduplicateEvents(events);
    for (final ev in deduped) {
      _onEvent?.call(ev);
    }
  }

  List<RoadEvent> _classifyWindow(List<_ImuReading> readings) {
    if (readings.isEmpty) return [];

    final azValues = readings.map((r) => r.az).toList()..sort();
    final median = azValues[azValues.length ~/ 2];

    final detrended = readings.map((r) => (r.az - median).abs()).toList();
    final filtered = _movingAverage(detrended, 5);

    final detected = <RoadEvent>[];
    int i = 0;

    while (i < filtered.length) {
      final valG = filtered[i] / _kG;

      if (valG > _kPotholeThresholdG) {
        final confidence =
            ((valG - _kPotholeThresholdG) / _kPotholeThresholdG * 0.5 + 0.7)
                .clamp(0.0, 1.0);
        detected.add(RoadEvent(
          eventType: 'pothole',
          confidence: confidence,
          lat: readings[i].lat,
          lon: readings[i].lon,
        ));
        i += 10;
        continue;
      }

      if (valG > _kSpeedBumpThresholdG) {
        final windowEnd = math.min(i + 5, filtered.length);
        final sustained = filtered
            .sublist(i, windowEnd)
            .where((v) => v / _kG > _kSpeedBumpThresholdG)
            .length;
        if (sustained >= 2) {
          detected.add(RoadEvent(
            eventType: 'speed_bump',
            confidence: (0.6 + 0.1 * sustained).clamp(0.0, 1.0),
            lat: readings[i].lat,
            lon: readings[i].lon,
          ));
          i += 8;
          continue;
        }
      }

      if (i + 20 < filtered.length) {
        final window =
            filtered.sublist(i, i + 20).map((v) => v / _kG).toList();
        final stdDev = _computeStdDev(window);
        if (stdDev > _kRoughRoadStdG) {
          final mid = i + 10;
          detected.add(RoadEvent(
            eventType: 'rough_road',
            confidence: (0.5 + stdDev * 0.2).clamp(0.0, 1.0),
            lat: readings[mid].lat,
            lon: readings[mid].lon,
          ));
          i += 20;
          continue;
        }
      }

      i++;
    }

    return detected;
  }

  List<double> _movingAverage(List<double> values, int window) {
    if (values.length < window) return values;
    final result = <double>[];
    for (int i = 0; i < values.length; i++) {
      final start = math.max(0, i - window ~/ 2);
      final end = math.min(values.length, i + window ~/ 2 + 1);
      final slice = values.sublist(start, end);
      result.add(slice.reduce((a, b) => a + b) / slice.length);
    }
    return result;
  }

  double _computeStdDev(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            values.length;
    return math.sqrt(variance);
  }

  List<RoadEvent> _deduplicateEvents(
    List<RoadEvent> events, {
    double radiusM = 20.0,
  }) {
    final kept = <RoadEvent>[];
    for (final ev in events) {
      bool tooClose = false;
      for (final k in kept) {
        if (k.eventType == ev.eventType) {
          final dlat = (ev.lat - k.lat) * 111320;
          final dlon = (ev.lon - k.lon) *
              111320 *
              math.cos(ev.lat * math.pi / 180);
          final dist = math.sqrt(dlat * dlat + dlon * dlon);
          if (dist < radiusM) {
            tooClose = true;
            break;
          }
        }
      }
      if (!tooClose) kept.add(ev);
    }
    return kept;
  }
}

class _ImuReading {
  final double az;
  final double lat;
  final double lon;
  final int timestampMs;

  const _ImuReading({
    required this.az,
    required this.lat,
    required this.lon,
    required this.timestampMs,
  });
}
