import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';
import '../models/search_result.dart';
import '../services/api_service.dart';
import '../services/voice_service.dart';
import '../core/constants.dart';

/// State for the active route and turn-by-turn navigation.
class RouteState {
  final List<RouteModel> routes;
  final RouteModel? activeRoute;
  final bool isLoading;
  final String? error;
  final bool isNavigating;
  final int currentStepIndex;
  final SearchResult? destination;

  const RouteState({
    this.routes = const [],
    this.activeRoute,
    this.isLoading = false,
    this.error,
    this.isNavigating = false,
    this.currentStepIndex = 0,
    this.destination,
  });

  RouteState copyWith({
    List<RouteModel>? routes,
    RouteModel? activeRoute,
    bool clearActiveRoute = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isNavigating,
    int? currentStepIndex,
    SearchResult? destination,
    bool clearDestination = false,
  }) =>
      RouteState(
        routes: routes ?? this.routes,
        activeRoute: clearActiveRoute ? null : activeRoute ?? this.activeRoute,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        isNavigating: isNavigating ?? this.isNavigating,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        destination:
            clearDestination ? null : destination ?? this.destination,
      );
}

class RouteNotifier extends StateNotifier<RouteState> {
  final ApiService _api;
  final VoiceService _voice;

  RouteNotifier(this._api, this._voice) : super(const RouteState());

  /// Calculate a route from [origin] to [destination].
  Future<void> calculateRoute(
    SearchResult destination, {
    required double originLat,
    required double originLon,
    String profile = 'car',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, destination: destination);

    try {
      final routes = await _api.getRoute(
        [
          {'lat': originLat, 'lon': originLon},
          {'lat': destination.lat, 'lon': destination.lon},
        ],
        profile: profile,
      );

      if (routes.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No route found',
        );
        return;
      }

      state = state.copyWith(
        routes: routes,
        activeRoute: routes.first,
        isLoading: false,
        currentStepIndex: 0,
        isNavigating: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Begin turn-by-turn navigation and announce the first step.
  void startNavigation() {
    if (state.activeRoute == null) return;
    state = state.copyWith(isNavigating: true, currentStepIndex: 0);
    _announceCurrentStep();
  }

  /// Repeat the voice instruction for the current step.
  void repeatCurrentInstruction() => _announceCurrentStep();

  /// Update the current step based on the user's GPS position.
  void updateFromLocation(double lat, double lon) {
    if (!state.isNavigating || state.activeRoute == null) return;

    final steps = state.activeRoute!.allSteps;
    if (steps.isEmpty) return;

    for (int i = state.currentStepIndex; i < steps.length; i++) {
      final coords = steps[i].geometry?.coordinates;
      if (coords == null || coords.isEmpty) continue;

      final end = coords.last;
      final dist = _haversine(lat, lon, end.latitude, end.longitude);

      if (dist > kAnnounceTurnDistanceM / 2) {
        // User hasn't passed this step yet
        if (i != state.currentStepIndex) {
          state = state.copyWith(currentStepIndex: i);
          _announceCurrentStep();
        }
        return;
      }
    }
  }

  void _announceCurrentStep() {
    final steps = state.activeRoute?.allSteps ?? [];
    if (state.currentStepIndex >= steps.length) return;
    final step = steps[state.currentStepIndex];
    _voice.announceManeuver(step.maneuver.type);
  }

  /// Clear the active route and stop navigation.
  void clearRoute() {
    state = state.copyWith(
      clearActiveRoute: true,
      clearDestination: true,
      routes: [],
      isNavigating: false,
      currentStepIndex: 0,
    );
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLambda = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(dLambda / 2) * math.sin(dLambda / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

// Singleton services shared across providers
final _apiServiceProvider = Provider((_) => ApiService());
final _voiceServiceProvider = Provider((_) => VoiceService());

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>(
  (ref) => RouteNotifier(
    ref.read(_apiServiceProvider),
    ref.read(_voiceServiceProvider),
  ),
);

/// Expose the API service for use in other parts of the app.
final apiServiceProvider = _apiServiceProvider;
