import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// A simple loading indicator with optional label.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(
              label!,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

/// A rounded bottom sheet wrapper with a drag handle.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Report hazard quick action bottom sheet.
class ReportHazardSheet extends StatelessWidget {
  const ReportHazardSheet({
    super.key,
    required this.onReportType,
  });

  final void Function(String type) onReportType;

  static const _types = [
    _ReportType('accident', 'Accident', Icons.car_crash, AppColors.dangerRed),
    _ReportType('police', 'Police', Icons.local_police, AppColors.infoBlue),
    _ReportType(
        'road_closed', 'Road Closed', Icons.block, AppColors.warningOrange),
    _ReportType('flood', 'Flood', Icons.water, AppColors.infoBlue),
    _ReportType(
        'protest', 'Protest', Icons.campaign, AppColors.warningOrange),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Hazard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: _types
                .map((t) => _ReportButton(type: t, onTap: onReportType))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.type, required this.onTap});

  final _ReportType type;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap(type.key);
      },
      child: Container(
        decoration: BoxDecoration(
          color: type.color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: type.color.withAlpha(77)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: type.color, size: 28),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: TextStyle(
                color: type.color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportType {
  const _ReportType(this.key, this.label, this.icon, this.color);

  final String key;
  final String label;
  final IconData icon;
  final Color color;
}
