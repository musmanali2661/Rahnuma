import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/router/app_router.dart';
import '../../data/models/road_event_model.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/map_widgets/map_tile_layer.dart';
import '../widgets/map_widgets/route_layer.dart';
import '../widgets/map_widgets/hazard_layer.dart';
import '../widgets/navigation_widgets/route_bottom_card.dart';
import '../widgets/common/app_bottom_sheet.dart';

/// Main map screen – the app's home screen.
///
/// Shows an OSM map, the user's location, the active route (if any),
/// road hazard markers, and a FAB for searching/reporting.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  List<RoadEventModel> _events = [];
  bool _isFetchingEvents = false;

  @override
  void initState() {
    super.initState();
    // Defer until the map controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForCurrentView();
    });
  }

  Future<void> _fetchEventsForCurrentView() async {
    if (_isFetchingEvents) return;
    setState(() => _isFetchingEvents = true);
    try {
      final api = ref.read(apiServiceProvider);
      final camera = _mapController.camera;
      final bounds = camera.visibleBounds;
      final events = await api.getEvents(
        minLat: bounds.south,
        minLon: bounds.west,
        maxLat: bounds.north,
        maxLon: bounds.east,
      );
      if (mounted) setState(() => _events = events);
    } catch (_) {
      // Events are non-critical; silently ignore
    } finally {
      if (mounted) setState(() => _isFetchingEvents = false);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd || event is MapEventScrollWheelZoom) {
      _fetchEventsForCurrentView();
    }
  }

  void _centerOnUser() {
    final pos = ref.read(locationProvider).position;
    if (pos != null) {
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        15,
      );
    }
  }

  Future<void> _showReportSheet() async {
    final pos = ref.read(locationProvider).position;
    if (pos == null) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => ReportHazardSheet(
        onReportType: (type) async {
          try {
            final api = ref.read(apiServiceProvider);
            await api.submitReport(
              lat: pos.latitude,
              lon: pos.longitude,
              reportType: type,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted – thank you!'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to submit: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final routeState = ref.watch(routeProvider);

    final userPos = locationState.position;
    final initialCenter = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : const LatLng(AppConstants.defaultLat, AppConstants.defaultLon);

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: AppConstants.defaultZoom,
              onMapEvent: _onMapEvent,
            ),
            children: [
              const MapTileLayer(),
              // Route layer
              if (routeState.selectedRoute != null)
                RouteLayer(route: routeState.selectedRoute!),
              // Hazard markers
              HazardLayer(events: _events),
              // User location
              if (userPos != null)
                LocationMarkerWidget(
                  position: LatLng(userPos.latitude, userPos.longitude),
                  heading: userPos.heading,
                ),
            ],
          ),

          // ── Top search bar ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.search),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          routeState.destination?.name ??
                              'Search Rahnuma…',
                          style: TextStyle(
                            color: routeState.destination != null
                                ? AppColors.darkGray
                                : Colors.grey,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Language indicator
                      const Text(
                        'اردو',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Right side FABs ────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: routeState.selectedRoute != null ? 220 : 100,
            child: Column(
              children: [
                // Center on user
                FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: _centerOnUser,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location,
                      color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 8),
                // Report hazard
                FloatingActionButton.small(
                  heroTag: 'report',
                  onPressed: _showReportSheet,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.report_problem,
                      color: AppColors.warningOrange),
                ),
                const SizedBox(height: 8),
                // Offline maps
                FloatingActionButton.small(
                  heroTag: 'offline',
                  onPressed: () => context.push(AppRoutes.offline),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.download_for_offline,
                      color: AppColors.infoBlue),
                ),
              ],
            ),
          ),

          // ── Route card (bottom) ────────────────────────────────────────────
          if (routeState.selectedRoute != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RouteBottomCard(
                route: routeState.selectedRoute!,
                onStartNavigation: () {
                  context.push(
                    AppRoutes.navigation,
                    extra: routeState.selectedRoute,
                  );
                },
                onClear: () => ref.read(routeProvider.notifier).clearRoute(),
              ),
            ),

          // ── Loading indicator for route ────────────────────────────────────
          if (routeState.isLoading)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Calculating route…'),
                    ],
                  ),
                ),
              ),
            ),

          // ── Route error ───────────────────────────────────────────────────
          if (routeState.error != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        routeState.error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () =>
                          ref.read(routeProvider.notifier).clearRoute(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
