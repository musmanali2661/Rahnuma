import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/road_event_model.dart';
import '../../data/services/imu_service.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import 'service_providers.dart';

/// State for IMU-based road event detection.
class ImuState {
  const ImuState({
    this.isActive = false,
    this.pendingCount = 0,
    this.uploadedCount = 0,
    this.lastEvent,
  });

  final bool isActive;
  final int pendingCount;
  final int uploadedCount;
  final RoadEventModel? lastEvent;

  ImuState copyWith({
    bool? isActive,
    int? pendingCount,
    int? uploadedCount,
    RoadEventModel? lastEvent,
  }) =>
      ImuState(
        isActive: isActive ?? this.isActive,
        pendingCount: pendingCount ?? this.pendingCount,
        uploadedCount: uploadedCount ?? this.uploadedCount,
        lastEvent: lastEvent ?? this.lastEvent,
      );
}

class ImuNotifier extends StateNotifier<ImuState> {
  ImuNotifier(this._api) : super(const ImuState());

  final ApiService _api;
  final _imu = ImuService.instance;
  Timer? _batchTimer;

  void startDetection() {
    if (state.isActive) return;
    _imu.start();
    state = state.copyWith(isActive: true);
    // Batch upload every 30 seconds when we have pending events
    _batchTimer = Timer.periodic(const Duration(seconds: 30), (_) => _upload());
  }

  void stopDetection() {
    _imu.stop();
    _batchTimer?.cancel();
    state = state.copyWith(isActive: false);
  }

  void updatePosition(Position pos) {
    _imu.updatePosition(pos.latitude, pos.longitude);
    _imu.updateSpeed(pos.speed);
    // Update pending count state
    state = state.copyWith(pendingCount: _imu.pendingCount);
  }

  Future<void> _upload() async {
    final events = _imu.drainEvents();
    if (events.isEmpty) return;

    // Update last detected event for UI feedback
    state = state.copyWith(
      pendingCount: 0,
      lastEvent: events.last,
    );

    try {
      final count = await _api.submitEvents(events);
      state = state.copyWith(uploadedCount: state.uploadedCount + count);
    } catch (_) {
      // On failure re-queue would be ideal; for Phase 1 we silently drop
    }
  }

  /// Force an immediate upload (e.g., when WiFi is detected).
  Future<void> forceUpload() => _upload();

  @override
  void dispose() {
    _imu.stop();
    _batchTimer?.cancel();
    super.dispose();
  }
}

final imuProvider = StateNotifierProvider<ImuNotifier, ImuState>(
  (ref) => ImuNotifier(ref.watch(apiServiceProvider)),
);
