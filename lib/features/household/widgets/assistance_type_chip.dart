import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

class AssistanceTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const AssistanceTypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? AppColors.surface : AppColors.primary,
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.surface : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontFamily: AppTypography.fontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
      backgroundColor: AppColors.surface,
    );
  }
}
