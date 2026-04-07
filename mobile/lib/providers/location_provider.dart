import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// State for the user's GPS location.
class LocationState {
  final LatLng? position;
  final bool isTracking;
  final String? error;

  const LocationState({
    this.position,
    this.isTracking = false,
    this.error,
  });

  LocationState copyWith({
    LatLng? position,
    bool? isTracking,
    String? error,
  }) =>
      LocationState(
        position: position ?? this.position,
        isTracking: isTracking ?? this.isTracking,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  StreamSubscription<Position>? _positionStream;

  /// Request location permission and start tracking.
  Future<void> startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      state = state.copyWith(
        error: 'Location permission denied',
        isTracking: false,
      );
      return;
    }

    state = state.copyWith(isTracking: true, error: null);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        state = state.copyWith(
          position: LatLng(position.latitude, position.longitude),
        );
      },
      onError: (Object err) {
        state = state.copyWith(
          error: err.toString(),
          isTracking: false,
        );
      },
    );
  }

  /// Stop GPS tracking.
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    state = state.copyWith(isTracking: false);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
