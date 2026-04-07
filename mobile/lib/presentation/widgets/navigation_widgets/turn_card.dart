import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/route_model.dart';

/// Turn card shown at the top of the screen during active navigation.
class TurnCard extends StatelessWidget {
  const TurnCard({
    super.key,
    required this.step,
    required this.distanceToStep,
    this.nextStep,
  });

  final RouteStep step;
  final double distanceToStep;
  final RouteStep? nextStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _TurnArrow(maneuverType: step.maneuverType, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDistance(distanceToStep),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (step.streetName != null &&
                          step.streetName!.isNotEmpty)
                        Text(
                          step.streetName!,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Then: preview of next step
            if (nextStep != null) ...[
              const Divider(color: Colors.white24, height: 16),
              Row(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Then: ${nextStep!.instruction.isNotEmpty ? nextStep!.instruction : nextStep!.maneuverType}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    final rounded = (meters / 50).round() * 50;
    return '$rounded m';
  }
}

class _TurnArrow extends StatelessWidget {
  const _TurnArrow({required this.maneuverType, this.size = 36});

  final String maneuverType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final lower = maneuverType.toLowerCase();
    IconData icon;
    if (lower.contains('left')) {
      icon = Icons.turn_left;
    } else if (lower.contains('right')) {
      icon = Icons.turn_right;
    } else if (lower.contains('arrive') || lower.contains('destination')) {
      icon = Icons.place;
    } else if (lower.contains('uturn') || lower.contains('u-turn')) {
      icon = Icons.u_turn_right;
    } else {
      icon = Icons.straight;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.65),
    );
  }
}
