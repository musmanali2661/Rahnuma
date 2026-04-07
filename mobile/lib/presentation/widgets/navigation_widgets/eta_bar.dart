import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Bottom ETA / distance bar shown during active navigation.
class EtaBar extends StatelessWidget {
  const EtaBar({
    super.key,
    required this.distanceRemaining,
    required this.durationRemaining,
    required this.onStop,
    this.onMuteToggle,
    this.isMuted = false,
  });

  final double distanceRemaining;
  final double durationRemaining;
  final VoidCallback onStop;
  final VoidCallback? onMuteToggle;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final eta = DateTime.now().add(Duration(seconds: durationRemaining.toInt()));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // Distance
          _InfoChip(
            icon: Icons.straighten,
            label: _formatDist(distanceRemaining),
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 12),
          // Duration
          _InfoChip(
            icon: Icons.timer_outlined,
            label: _formatDur(durationRemaining),
            color: AppColors.infoBlue,
          ),
          const SizedBox(width: 12),
          // ETA
          _InfoChip(
            icon: Icons.access_time,
            label: _formatTime(eta),
            color: AppColors.darkGray,
          ),
          const Spacer(),
          // Mute button
          if (onMuteToggle != null)
            IconButton(
              onPressed: onMuteToggle,
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: isMuted ? Colors.grey : AppColors.primaryGreen,
              ),
              iconSize: 22,
              tooltip: isMuted ? 'Unmute' : 'Mute',
            ),
          // Stop button
          GestureDetector(
            onTap: onStop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Stop',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }

  String _formatDur(double seconds) {
    final mins = (seconds / 60).round();
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '$h hr $m min' : '$h hr';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $suffix';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}
