import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/route_model.dart';
import '../../data/services/location_service.dart';
import '../../data/services/voice_service.dart';
import '../../core/constants/app_constants.dart';

/// Possible states of the navigation session.
enum NavigationStatus {
  idle,
  active,
  rerouting,
  arrived,
}

class NavigationState {
  const NavigationState({
    this.status = NavigationStatus.idle,
    this.route,
    this.currentStepIndex = 0,
    this.distanceToNextStep = 0,
    this.distanceRemaining = 0,
    this.durationRemaining = 0,
    this.userPosition,
  });

  final NavigationStatus status;
  final RouteModel? route;
  final int currentStepIndex;

  /// Distance to the next maneuver in metres.
  final double distanceToNextStep;

  /// Total remaining distance in metres.
  final double distanceRemaining;

  /// Total remaining duration in seconds.
  final double durationRemaining;

  final Position? userPosition;

  bool get isActive => status == NavigationStatus.active;

  RouteStep? get currentStep =>
      route != null && currentStepIndex < route!.steps.length
          ? route!.steps[currentStepIndex]
          : null;

  RouteStep? get nextStep =>
      route != null && currentStepIndex + 1 < route!.steps.length
          ? route!.steps[currentStepIndex + 1]
          : null;

  NavigationState copyWith({
    NavigationStatus? status,
    RouteModel? route,
    int? currentStepIndex,
    double? distanceToNextStep,
    double? distanceRemaining,
    double? durationRemaining,
    Position? userPosition,
  }) =>
      NavigationState(
        status: status ?? this.status,
        route: route ?? this.route,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        distanceToNextStep: distanceToNextStep ?? this.distanceToNextStep,
        distanceRemaining: distanceRemaining ?? this.distanceRemaining,
        durationRemaining: durationRemaining ?? this.durationRemaining,
        userPosition: userPosition ?? this.userPosition,
      );
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  final _location = LocationService.instance;
  final _voice = VoiceService.instance;
  StreamSubscription<Position>? _positionSub;
  String? _lastPlayedManeuver;

  void startNavigation(RouteModel route) {
    state = NavigationState(
      status: NavigationStatus.active,
      route: route,
      distanceRemaining: route.distance,
      durationRemaining: route.duration,
    );

    // Announce first step
    if (route.steps.isNotEmpty) {
      _playStep(route.steps.first);
    }

    _positionSub?.cancel();
    _positionSub = _location.locationStream.listen(_onPosition);
  }

  void stopNavigation() {
    _positionSub?.cancel();
    state = const NavigationState(status: NavigationStatus.idle);
    _lastPlayedManeuver = null;
  }

  void _onPosition(Position pos) {
    if (!state.isActive || state.route == null) return;

    final route = state.route!;
    final steps = route.steps;

    if (steps.isEmpty) {
      _checkArrival(pos, route);
      return;
    }

    // Advance steps when close enough to the next maneuver
    int stepIndex = state.currentStepIndex;
    while (stepIndex < steps.length) {
      final step = steps[stepIndex];
      final dist = _distanceToStepEnd(pos, stepIndex, steps);

      if (dist < AppConstants.waypointReachedRadiusM &&
          stepIndex < steps.length - 1) {
        stepIndex++;
        _playStep(steps[stepIndex]);
      } else {
        state = state.copyWith(
          currentStepIndex: stepIndex,
          distanceToNextStep: dist,
          distanceRemaining: _totalRemainingDistance(stepIndex, steps),
          durationRemaining:
              _totalRemainingDuration(stepIndex, steps),
          userPosition: pos,
        );
        break;
      }
    }

    _checkArrival(pos, route);
  }

  void _checkArrival(Position pos, RouteModel route) {
    // Approximate destination from last step
    if (route.steps.isEmpty) return;
    final lastStep = route.steps.last;
    // We use the cumulative distance shrinking to near zero as arrival signal
    if (state.distanceRemaining < AppConstants.waypointReachedRadiusM) {
      state = state.copyWith(status: NavigationStatus.arrived);
      _voice.playDestinationReached();
      _positionSub?.cancel();
    }
  }

  double _distanceToStepEnd(
    Position pos,
    int stepIndex,
    List<RouteStep> steps,
  ) {
    // TODO(phase2): Decode the route geometry and compute the actual distance
    // from the user's GPS position to the end of the current step using
    // nearest-point-on-polyline projection.
    // For Phase 1 we use a simplified half-step distance as a proxy.
    return steps[stepIndex].distance * 0.5;
  }

  double _totalRemainingDistance(int fromStep, List<RouteStep> steps) {
    double total = 0;
    for (int i = fromStep; i < steps.length; i++) {
      total += steps[i].distance;
    }
    return total;
  }

  double _totalRemainingDuration(int fromStep, List<RouteStep> steps) {
    double total = 0;
    for (int i = fromStep; i < steps.length; i++) {
      total += steps[i].duration;
    }
    return total;
  }

  void _playStep(RouteStep step) {
    final key = '${step.maneuverType}_${state.currentStepIndex}';
    if (_lastPlayedManeuver == key) return;
    _lastPlayedManeuver = key;
    _voice.playManeuver(step.maneuverType);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);
