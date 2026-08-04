import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Card thông tin vật tư trong kho.
/// Hiển thị thanh tiến độ sử dụng số tuyệt đối, KHÔNG hiển thị tỷ lệ phần trăm (%).
class StockCard extends StatelessWidget {
  final String itemName;
  final num currentQty;
  final num thresholdQty;
  final String unit;
  final num capacity;

  const StockCard({
    super.key,
    required this.itemName,
    required this.currentQty,
    required this.thresholdQty,
    required this.unit,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = currentQty < thresholdQty;
    final double progress = capacity > 0 ? (currentQty / capacity).clamp(0.0, 1.0) : 0.0;
    final Color progressColor = isLowStock ? AppColors.priorityRed : AppColors.statusSafe;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningBanner,
                      border: Border.all(color: AppColors.priorityOrange, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, color: AppColors.priorityOrange, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'DƯỚI NGƯỠNG',
                          style: TextStyle(
                            color: AppColors.priorityOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tồn kho: $currentQty / $capacity $unit',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                Text(
                  'Cảnh báo: <$thresholdQty $unit',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
