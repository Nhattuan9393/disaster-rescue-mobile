import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Badge hiển thị độ ưu tiên dựa trên điểm ưu tiên (SOS score).
/// Đỏ: >= 70 (Khẩn cấp), Cam: 40-69 (Nguy hiểm), Vàng: < 40 (Cần hỗ trợ).
class PriorityBadge extends StatelessWidget {
  final int score;

  const PriorityBadge({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String text;

    if (score >= 70) {
      backgroundColor = AppColors.priorityRed;
      text = 'KHẨN CẤP';
    } else if (score >= 40) {
      backgroundColor = AppColors.priorityOrange;
      text = 'NGUY HIỂM';
    } else {
      backgroundColor = AppColors.priorityYellow;
      text = 'CẦN HỖ TRỢ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$text ($score điểm)',
        style: const TextStyle(
          color: AppColors.surface,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: AppTypography.fontFamily,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
