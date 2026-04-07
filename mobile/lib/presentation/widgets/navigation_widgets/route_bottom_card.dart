import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/route_model.dart';

/// Bottom sheet card shown when a route has been calculated.
class RouteBottomCard extends StatelessWidget {
  const RouteBottomCard({
    super.key,
    required this.route,
    required this.onStartNavigation,
    required this.onClear,
  });

  final RouteModel route;
  final VoidCallback onStartNavigation;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Summary row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        route.formattedDuration,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.straighten,
                          color: AppColors.darkGray, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        route.formattedDistance,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toll cost
                if (route.tollEstimatePkr != null &&
                    route.tollEstimatePkr! > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Toll ~PKR ${route.tollEstimatePkr!.toInt()}',
                      style: const TextStyle(
                        color: AppColors.warningOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // First few steps preview
            if (route.steps.isNotEmpty) ...[
              const Divider(),
              ...route.steps.take(3).map((step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        _ManeuverIcon(type: step.maneuverType),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.instruction.isNotEmpty
                                ? step.instruction
                                : step.streetName ?? step.maneuverType,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDist(step.distance),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartNavigation,
                icon: const Icon(Icons.navigation),
                label: const Text('Start Navigation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }
}

class _ManeuverIcon extends StatelessWidget {
  const _ManeuverIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final lower = type.toLowerCase();
    IconData icon;
    if (lower.contains('left')) {
      icon = Icons.turn_left;
    } else if (lower.contains('right')) {
      icon = Icons.turn_right;
    } else if (lower.contains('arrive')) {
      icon = Icons.place;
    } else {
      icon = Icons.straight;
    }
    return Icon(icon, size: 18, color: AppColors.primaryGreen);
  }
}
