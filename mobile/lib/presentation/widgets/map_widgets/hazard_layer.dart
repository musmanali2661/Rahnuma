import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/road_event_model.dart';

/// Renders road event markers (potholes, speed bumps) on the map.
class HazardLayer extends StatelessWidget {
  const HazardLayer({super.key, required this.events});

  final List<RoadEventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return MarkerLayer(
      markers: events.map((e) {
        return Marker(
          point: LatLng(e.lat, e.lon),
          width: 32,
          height: 32,
          child: _HazardMarker(event: e),
        );
      }).toList(),
    );
  }
}

class _HazardMarker extends StatelessWidget {
  const _HazardMarker({required this.event});

  final RoadEventModel event;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (event.eventType) {
      RoadEventType.pothole => (Icons.warning_amber_rounded, AppColors.dangerRed),
      RoadEventType.speedBump => (Icons.speed, AppColors.warningOrange),
      RoadEventType.roughRoad => (Icons.terrain, AppColors.accentGold),
    };

    return Tooltip(
      message: _label(event.eventType),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(230),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  String _label(RoadEventType type) => switch (type) {
        RoadEventType.pothole => 'Pothole',
        RoadEventType.speedBump => 'Speed Bump',
        RoadEventType.roughRoad => 'Rough Road',
      };
}
