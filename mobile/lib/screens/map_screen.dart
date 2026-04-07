import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';
import '../models/search_result.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/route_card_widget.dart';
import '../widgets/turn_indicator_widget.dart';

/// The main map screen — the app's primary view.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Start GPS tracking as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Fly the map to the user's current GPS position.
  void _flyToUserLocation() {
    final pos = ref.read(locationProvider).position;
    if (pos == null) return;
    _mapController.move(pos, kNavigationZoom);
  }

  /// Handle a place selection from the search bar.
  Future<void> _onPlaceSelected(SearchResult place) async {
    final userPos = ref.read(locationProvider).position;

    // Fly to the selected destination
    _mapController.move(LatLng(place.lat, place.lon), 14);

    if (userPos != null) {
      await ref.read(routeProvider.notifier).calculateRoute(
            place,
            originLat: userPos.latitude,
            originLon: userPos.longitude,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final routeState = ref.watch(routeProvider);

    // Update route step when location changes (during navigation)
    ref.listen<LocationState>(locationProvider, (_, next) {
      final pos = next.position;
      if (pos != null) {
        ref
            .read(routeProvider.notifier)
            .updateFromLocation(pos.latitude, pos.longitude);
      }
    });

    // Build route polyline
    final polylines = <Polyline>[];
    if (routeState.activeRoute != null) {
      polylines.add(Polyline(
        points: routeState.activeRoute!.geometry.coordinates,
        strokeWidth: 5,
        color: const Color(0xFF1976D2),
      ));
    }

    // Build markers
    final markers = <Marker>[];
    if (locationState.position != null) {
      markers.add(Marker(
        point: locationState.position!,
        child: const Icon(Icons.navigation, color: Color(0xFF1976D2), size: 32),
      ));
    }
    if (routeState.destination != null) {
      markers.add(Marker(
        point: LatLng(
            routeState.destination!.lat, routeState.destination!.lon),
        child:
            const Icon(Icons.location_pin, color: Color(0xFFF44336), size: 36),
      ));
    }

    // Current step for the turn indicator
    final steps = routeState.activeRoute?.allSteps ?? [];
    final currentStep = routeState.isNavigating &&
            routeState.currentStepIndex < steps.length
        ? steps[routeState.currentStepIndex]
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locationState.position ?? kPakistanCenter,
              initialZoom: locationState.position != null
                  ? kNavigationZoom
                  : kDefaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'app.rahnuma.mobile',
              ),
              if (polylines.isNotEmpty)
                PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          ),

          // ── Search bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SearchBarWidget(
                onPlaceSelected: _onPlaceSelected,
                userPosition: locationState.position,
              ),
            ),
          ),

          // ── Turn indicator (during navigation) ───────────────────────────
          if (routeState.isNavigating && currentStep != null)
            Positioned(
              top: 100,
              left: 12,
              right: 12,
              child: TurnIndicatorWidget(step: currentStep),
            ),

          // ── Route card ────────────────────────────────────────────────────
          if (routeState.activeRoute != null)
            Positioned(
              bottom: 24,
              left: 12,
              right: 12,
              child: RouteCardWidget(
                route: routeState.activeRoute!,
                isNavigating: routeState.isNavigating,
                currentStepIndex: routeState.currentStepIndex,
                onStartNavigation: () =>
                    ref.read(routeProvider.notifier).startNavigation(),
                onRepeat: () =>
                    ref.read(routeProvider.notifier).repeatCurrentInstruction(),
                onClear: () =>
                    ref.read(routeProvider.notifier).clearRoute(),
              ),
            ),

          // ── Error snackbar ────────────────────────────────────────────────
          if (routeState.error != null || locationState.error != null)
            Positioned(
              top: 80,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Text(
                    routeState.error ?? locationState.error ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),

      // ── FABs ─────────────────────────────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'offline',
            onPressed: () => context.push('/offline'),
            tooltip: 'Offline maps',
            child: const Icon(Icons.download_for_offline),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'locate',
            onPressed: _flyToUserLocation,
            tooltip: 'My location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
