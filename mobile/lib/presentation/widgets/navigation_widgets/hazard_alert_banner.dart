import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/road_event_model.dart';

/// Overlay popup shown when a road hazard is detected nearby.
class HazardAlertBanner extends StatefulWidget {
  const HazardAlertBanner({
    super.key,
    required this.event,
    this.onDismiss,
  });

  final RoadEventModel event;
  final VoidCallback? onDismiss;

  @override
  State<HazardAlertBanner> createState() => _HazardAlertBannerState();
}

class _HazardAlertBannerState extends State<HazardAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismiss?.call());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (widget.event.eventType) {
      RoadEventType.pothole =>
        (Icons.warning_amber_rounded, AppColors.dangerRed, 'Pothole Ahead!'),
      RoadEventType.speedBump =>
        (Icons.speed, AppColors.warningOrange, 'Speed Breaker Ahead'),
      RoadEventType.roughRoad =>
        (Icons.terrain, AppColors.accentGold, 'Rough Road Ahead'),
    };

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(230),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _ctrl.reverse().then((_) => widget.onDismiss?.call());
              },
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
