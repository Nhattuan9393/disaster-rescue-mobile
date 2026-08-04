import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';

/// Chip hiển thị trạng thái an toàn kèm theo nguồn xác nhận.
/// Được thiết kế phân tách rõ màu xám cho "Mất liên lạc" để điều phối viên dễ nhận biết.
class StatusChip extends StatelessWidget {
  final SafetyState status;
  final SafetySource? source;

  const StatusChip({
    super.key,
    required this.status,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    if (status == SafetyState.sos) {
      color = AppColors.primary;
      icon = Icons.warning_amber_rounded;
      label = 'SOS — Cần cứu hộ';
    } else if (status == SafetyState.missingContact) {
      color = AppColors.statusMissing;
      icon = Icons.phone_locked_rounded;
      label = 'Mất liên lạc — Thiết bị im lặng';
    } else {
      // Trạng thái an toàn/đã cứu/sơ tán (Màu xanh lá)
      color = AppColors.statusSafe;
      switch (source) {
        case SafetySource.rescueTeam:
          icon = Icons.health_and_safety_rounded; // ⛑️
          label = 'An toàn — Đội xác nhận';
          break;
        case SafetySource.evacuationCheckin:
          icon = Icons.school_rounded; // 🏫
          label = 'An toàn — Check-in sơ tán';
          break;
        case SafetySource.selfApp:
          icon = Icons.phone_android_rounded; // 📱
          label = 'An toàn — Tự báo';
          break;
        case SafetySource.adminManual:
          icon = Icons.person_pin_rounded;
          label = 'An toàn — Thôn xác nhận';
          break;
        case SafetySource.neighborReport:
          icon = Icons.supervisor_account_rounded;
          label = 'An toàn — Hàng xóm báo';
          break;
        case null:
          icon = Icons.check_circle_rounded;
          label = 'An toàn';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
