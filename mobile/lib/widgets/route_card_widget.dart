import 'package:flutter/material.dart';
import '../models/route_model.dart';

/// Displays a summary card for the active route with start/repeat voice buttons.
class RouteCardWidget extends StatelessWidget {
  const RouteCardWidget({
    super.key,
    required this.route,
    required this.isNavigating,
    required this.currentStepIndex,
    required this.onStartNavigation,
    required this.onRepeat,
    required this.onClear,
  });

  final RouteModel route;
  final bool isNavigating;
  final int currentStepIndex;
  final VoidCallback onStartNavigation;
  final VoidCallback onRepeat;
  final VoidCallback onClear;

  String _formatDistance(double metres) {
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(double seconds) {
    final h = (seconds / 3600).floor();
    final m = ((seconds % 3600) / 60).floor();
    if (h > 0) return '$h hr $m min';
    if (m > 0) return '$m min';
    return '${seconds.round()} sec';
  }

  @override
  Widget build(BuildContext context) {
    final steps = route.allSteps;
    final currentStep =
        isNavigating && currentStepIndex < steps.length
            ? steps[currentStepIndex]
            : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDuration(route.duration),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDistance(route.distance),
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      if (route.tollEstimatePkr > 0)
                        Text(
                          'Toll ~PKR ${route.tollEstimatePkr}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        ),
                    ],
                  ),
                ),
                // Voice / start navigation button
                IconButton(
                  onPressed:
                      isNavigating ? onRepeat : onStartNavigation,
                  icon: Icon(
                    isNavigating ? Icons.volume_up : Icons.play_circle_filled,
                    size: 36,
                    color: isNavigating
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                  ),
                  tooltip: isNavigating
                      ? 'Repeat instruction'
                      : 'Start navigation',
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear route',
                ),
              ],
            ),

            // Current step highlight
            if (isNavigating && currentStep != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _maneuverIcon(currentStep.maneuver.type),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentStep.name.isNotEmpty
                            ? currentStep.name
                            : currentStep.maneuver.type,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      _formatDistance(currentStep.distance),
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Turn list
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: steps.length.clamp(0, 8),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final step = steps[i];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            _formatDistance(step.distance),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${step.maneuver.type} ${step.name}'.trim(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isNavigating && i == currentStepIndex
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade800,
                              fontWeight: isNavigating &&
                                      i == currentStepIndex
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maneuverIcon(String type) {
    final iconData = switch (type.toLowerCase()) {
      'turn right' || 'sharp right' => Icons.turn_right,
      'turn left' || 'sharp left' => Icons.turn_left,
      'slight right' => Icons.turn_slight_right,
      'slight left' => Icons.turn_slight_left,
      'arrive' => Icons.flag,
      'u-turn' => Icons.u_turn_left,
      _ => Icons.straight,
    };
    return Icon(iconData, color: Colors.blue.shade700, size: 20);
  }
}
