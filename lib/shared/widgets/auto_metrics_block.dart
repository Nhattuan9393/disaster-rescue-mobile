import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Khối hiển thị số liệu minh chứng tự sinh của hệ thống dùng trong màn hình gửi yêu cầu Leo thang (Escalation).
/// Hiển thị trực quan theo dạng lưới 2 cột, tuân thủ nguyên tắc số tuyệt đối.
class AutoMetricsBlock extends StatelessWidget {
  final int redSosUnassigned;
  final Duration longestWait;
  final int householdsMissing;
  final int teamsAvailable;
  final int teamsTotal;
  final int itemsBelowThreshold;
  final int evacuationSlotsFree;
  final DateTime computedAt;

  const AutoMetricsBlock({
    super.key,
    required this.redSosUnassigned,
    required this.longestWait,
    required this.householdsMissing,
    required this.teamsAvailable,
    required this.teamsTotal,
    required this.itemsBelowThreshold,
    required this.evacuationSlotsFree,
    required this.computedAt,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng thời gian chờ lâu nhất gọn gàng
    String formatDuration(Duration d) {
      if (d.inHours > 0) {
        final int remainingMins = d.inMinutes % 60;
        return '${d.inHours} giờ $remainingMins phút';
      }
      return '${d.inMinutes} phút';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.textDisabled.withOpacity(0.5), width: 1),
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minh chứng hệ thống (Tự động)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              Text(
                'Cập nhật: ${_formatTime(computedAt)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.2,
            children: [
              _buildMetricItem(
                icon: Icons.sos_rounded,
                color: AppColors.priorityRed,
                label: 'SOS đỏ chưa gán',
                value: '$redSosUnassigned vụ',
              ),
              _buildMetricItem(
                icon: Icons.timer_rounded,
                color: AppColors.priorityOrange,
                label: 'Chờ lâu nhất',
                value: formatDuration(longestWait),
              ),
              _buildMetricItem(
                icon: Icons.person_search_rounded,
                color: AppColors.statusMissing,
                label: 'Mất liên lạc',
                value: '$householdsMissing hộ',
              ),
              _buildMetricItem(
                icon: Icons.group_work_rounded,
                color: AppColors.statusRescuing,
                label: 'Đội khả dụng',
                value: '$teamsAvailable/$teamsTotal đội',
              ),
              _buildMetricItem(
                icon: Icons.inventory_rounded,
                color: AppColors.priorityYellow,
                label: 'Vật tư cạn ngưỡng',
                value: '$itemsBelowThreshold loại',
              ),
              _buildMetricItem(
                icon: Icons.warehouse_rounded,
                color: AppColors.statusSafe,
                label: 'Chỗ sơ tán trống',
                value: '$evacuationSlotsFree chỗ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.textDisabled.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
