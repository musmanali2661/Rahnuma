import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../data/models/route_model.dart';
import '../../data/models/road_event_model.dart';
import '../../data/services/voice_service.dart';
import '../providers/location_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/imu_provider.dart';
import '../widgets/map_widgets/map_tile_layer.dart';
import '../widgets/map_widgets/route_layer.dart';
import '../widgets/map_widgets/hazard_layer.dart';
import '../widgets/navigation_widgets/turn_card.dart';
import '../widgets/navigation_widgets/eta_bar.dart';
import '../widgets/navigation_widgets/hazard_alert_banner.dart';

/// Active turn-by-turn navigation screen.
///
/// Features:
/// - Map locked to user heading (north-up for Phase 1)
/// - Turn card at top with maneuver + distance
/// - ETA / distance bar at bottom
/// - Voice guidance (Urdu)
/// - IMU pothole detection running in background
/// - Hazard alert banners
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, this.route});

  final RouteModel? route;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final _mapController = MapController();
  final _voice = VoiceService.instance;
  RoadEventModel? _currentAlert;
  StreamSubscription? _locationSub;
  bool _arrivedDialogShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.route != null) {
      // Start navigation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(navigationProvider.notifier)
            .startNavigation(widget.route!);
        ref.read(imuProvider.notifier).startDetection();
      });
    }

    // Listen for IMU events to show alert banners
    _startImuAlertListener();
  }

  void _startImuAlertListener() {
    // Poll IMU state for new events every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final imuState = ref.read(imuProvider);
      if (imuState.lastEvent != null && _currentAlert == null) {
        setState(() => _currentAlert = imuState.lastEvent);
        _voice.playSpeedBreaker();
      }
    });
  }

  void _stopNavigation() {
    ref.read(navigationProvider.notifier).stopNavigation();
    ref.read(imuProvider.notifier).stopDetection();
    context.pop();
  }

  void _centerOnUser() {
    final pos = ref.read(locationProvider).position;
    if (pos != null) {
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        17,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final locationState = ref.watch(locationProvider);
    final imuState = ref.watch(imuProvider);

    final userPos = locationState.position;

    // Auto-follow user position on map
    if (userPos != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && navState.isActive) {
          _mapController.move(
            LatLng(userPos.latitude, userPos.longitude),
            17,
          );
        }
      });

      // Update IMU with current position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(imuProvider.notifier).updatePosition(userPos);
        }
      });
    }

    // Check arrival
    if (navState.status == NavigationStatus.arrived && !_arrivedDialogShown) {
      _arrivedDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showArrivalDialog();
      });
    }

    final initialCenter = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : const LatLng(AppConstants.defaultLat, AppConstants.defaultLon);

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 17,
            ),
            children: [
              const MapTileLayer(),
              if (widget.route != null) RouteLayer(route: widget.route!),
              HazardLayer(events: const []),
              if (userPos != null)
                LocationMarkerWidget(
                  position: LatLng(userPos.latitude, userPos.longitude),
                  heading: userPos.heading,
                ),
            ],
          ),

          // ── Turn card (top) ────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (navState.currentStep != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: TurnCard(
                      step: navState.currentStep!,
                      distanceToStep: navState.distanceToNextStep,
                      nextStep: navState.nextStep,
                    ),
                  ),

                // ── Hazard alert banner ──────────────────────────────────
                if (_currentAlert != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: HazardAlertBanner(
                      event: _currentAlert!,
                      onDismiss: () =>
                          setState(() => _currentAlert = null),
                    ),
                  ),
              ],
            ),
          ),

          // ── Re-center button ───────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 100,
            child: FloatingActionButton.small(
              heroTag: 'nav_center',
              onPressed: _centerOnUser,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location,
                  color: AppColors.primaryGreen),
            ),
          ),

          // ── IMU badge ─────────────────────────────────────────────────
          if (imuState.isActive)
            Positioned(
              right: 12,
              bottom: 150,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successTeal.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sensors, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'IMU',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // ── ETA bar (bottom) ───────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: EtaBar(
                distanceRemaining: navState.distanceRemaining,
                durationRemaining: navState.durationRemaining,
                isMuted: _voice.isMuted,
                onMuteToggle: () {
                  _voice.toggleMute();
                  setState(() {});
                },
                onStop: _stopNavigation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArrivalDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place, color: AppColors.primaryGreen, size: 60),
            const SizedBox(height: 12),
            const Text(
              'آپ اپنی منزل پر پہنچ گئے',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'You have reached your destination',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopNavigation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }
}
