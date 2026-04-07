import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/place_model.dart';

/// A single search result row.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.place,
    required this.onTap,
  });

  final PlaceModel place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _iconForCategory(place.category);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(categoryIcon, color: AppColors.primaryGreen, size: 22),
      ),
      title: Text(
        place.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: place.address != null
          ? Text(
              place.address!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  IconData _iconForCategory(String? category) {
    if (category == null) return Icons.place;
    final c = category.toLowerCase();
    if (c.contains('petrol') || c.contains('fuel') || c.contains('gas')) {
      return Icons.local_gas_station;
    }
    if (c.contains('mosque') || c.contains('masjid')) return Icons.mosque;
    if (c.contains('hospital') || c.contains('clinic')) {
      return Icons.local_hospital;
    }
    if (c.contains('restaurant') || c.contains('food') || c.contains('dhaba')) {
      return Icons.restaurant;
    }
    if (c.contains('atm') || c.contains('bank')) return Icons.atm;
    if (c.contains('park')) return Icons.local_parking;
    if (c.contains('road') || c.contains('street') || c.contains('highway')) {
      return Icons.route;
    }
    return Icons.place;
  }
}
