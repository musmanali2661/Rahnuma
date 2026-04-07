import 'package:flutter/material.dart';
import '../models/route_model.dart';

/// Displays the upcoming turn instruction with an icon and distance label.
class TurnIndicatorWidget extends StatelessWidget {
  const TurnIndicatorWidget({super.key, required this.step});

  final RouteStep step;

  String _formatDistance(double metres) {
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name.isNotEmpty ? step.name : 'Continue',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDistance(step.distance),
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final type = step.maneuver.type.toLowerCase();
    final (iconData, color) = switch (type) {
      'turn right' || 'sharp right' => (Icons.turn_right, Colors.blue),
      'turn left' || 'sharp left' => (Icons.turn_left, Colors.blue),
      'slight right' => (Icons.turn_slight_right, Colors.blue),
      'slight left' => (Icons.turn_slight_left, Colors.blue),
      'arrive' => (Icons.flag, Colors.green),
      'u-turn' => (Icons.u_turn_left, Colors.orange),
      _ => (Icons.straight, Colors.blue),
    };

    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withAlpha(26),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
