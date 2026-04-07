import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';

/// Wraps [Geolocator] to provide a simplified location stream.
///
/// Call [initialise] once at app start (requests permissions).
/// Subscribe to [locationStream] for continuous updates.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  final StreamController<Position> _controller =
      StreamController<Position>.broadcast();
  StreamSubscription<Position>? _subscription;

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  Stream<Position> get locationStream => _controller.stream;

  /// Request permission and start the location stream.
  /// Returns `true` if permission was granted.
  Future<bool> initialise() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    await _startStream();
    return true;
  }

  Future<void> _startStream() async {
    _subscription?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // metres
    );
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      _lastPosition = pos;
      _controller.add(pos);
    });
  }

  /// One-shot position fetch (useful for initial map centering).
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Distance in metres between two positions.
  static double distanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) =>
      Geolocator.distanceBetween(startLat, startLon, endLat, endLon);

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
