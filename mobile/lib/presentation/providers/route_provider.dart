import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/route_model.dart';
import '../../data/models/place_model.dart';
import '../../data/services/api_service.dart';
import 'service_providers.dart';

/// State for route calculation.
class RouteState {
  const RouteState({
    this.routes = const [],
    this.selectedRoute,
    this.destination,
    this.origin,
    this.isLoading = false,
    this.error,
  });

  final List<RouteModel> routes;
  final RouteModel? selectedRoute;
  final PlaceModel? destination;
  final LatLon? origin;
  final bool isLoading;
  final String? error;

  RouteState copyWith({
    List<RouteModel>? routes,
    RouteModel? selectedRoute,
    PlaceModel? destination,
    LatLon? origin,
    bool? isLoading,
    String? error,
  }) =>
      RouteState(
        routes: routes ?? this.routes,
        selectedRoute: selectedRoute ?? this.selectedRoute,
        destination: destination ?? this.destination,
        origin: origin ?? this.origin,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier(this._api) : super(const RouteState());

  final ApiService _api;

  Future<void> calculateRoute({
    required LatLon origin,
    required LatLon destination,
    String profile = 'car',
    PlaceModel? destinationPlace,
  }) async {
    state = state.copyWith(isLoading: true, error: null, origin: origin);

    try {
      final routes = await _api.getRoute(
        [origin, destination],
        profile: profile,
        alternatives: true,
      );
      state = state.copyWith(
        routes: routes,
        selectedRoute: routes.isNotEmpty ? routes.first : null,
        destination: destinationPlace,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectRoute(RouteModel route) {
    state = state.copyWith(selectedRoute: route);
  }

  void clearRoute() {
    state = const RouteState();
  }
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>(
  (ref) => RouteNotifier(ref.watch(apiServiceProvider)),
);
