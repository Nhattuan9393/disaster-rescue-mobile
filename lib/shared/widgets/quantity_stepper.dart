import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Bộ chọn tăng giảm số lượng (- Số lượng +) dùng trong quản lý kho và check-in.
class QuantityStepper extends StatelessWidget {
  final num value;
  final ValueChanged<num> onChanged;
  final num min;
  final num max;
  final num step;
  final String? unit;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = double.infinity,
    this.step = 1,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = value - step >= min;
    final bool canIncrement = value + step <= max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onTap: canDecrement ? () => onChanged(value - step) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            unit != null ? '$value $unit' : '$value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onTap: canIncrement ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    final Color color = isEnabled ? AppColors.primary : AppColors.textDisabled;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
