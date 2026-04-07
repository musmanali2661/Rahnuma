import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/location_service.dart';

/// State class for the user's current location.
class LocationState {
  const LocationState({
    this.position,
    this.permissionGranted = false,
    this.isLoading = false,
    this.error,
  });

  final Position? position;
  final bool permissionGranted;
  final bool isLoading;
  final String? error;

  LocationState copyWith({
    Position? position,
    bool? permissionGranted,
    bool? isLoading,
    String? error,
  }) =>
      LocationState(
        position: position ?? this.position,
        permissionGranted: permissionGranted ?? this.permissionGranted,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  StreamSubscription<Position>? _sub;
  final _service = LocationService.instance;

  Future<void> _init() async {
    final granted = await _service.initialise();
    if (!granted) {
      state = state.copyWith(
        isLoading: false,
        permissionGranted: false,
        error: 'Location permission denied',
      );
      return;
    }

    // Get current position immediately
    final pos = await _service.getCurrentPosition();
    state = state.copyWith(
      position: pos,
      permissionGranted: true,
      isLoading: false,
    );

    // Subscribe to stream
    _sub = _service.locationStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
  }

  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);
    final granted = await _service.initialise();
    state = state.copyWith(
      isLoading: false,
      permissionGranted: granted,
      error: granted ? null : 'Location permission denied',
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
