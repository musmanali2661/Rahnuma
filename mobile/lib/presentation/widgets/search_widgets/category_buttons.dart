import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Quick-access POI category filter buttons.
class CategoryButtons extends StatelessWidget {
  const CategoryButtons({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  final void Function(String? category) onCategorySelected;
  final String? selectedCategory;

  static const _categories = [
    _Category('petrol', 'Petrol', Icons.local_gas_station),
    _Category('mosque', 'Mosque', Icons.mosque),
    _Category('hospital', 'Hospital', Icons.local_hospital),
    _Category('restaurant', 'Food', Icons.restaurant),
    _Category('atm', 'ATM', Icons.atm),
    _Category('parking', 'Parking', Icons.local_parking),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = selectedCategory == cat.key;
          return GestureDetector(
            onTap: () => onCategorySelected(isSelected ? null : cat.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Category {
  const _Category(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;
}
