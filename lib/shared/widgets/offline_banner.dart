import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Banner cảnh báo khi mất kết nối mạng.
/// Hiển thị ở trên cùng ứng dụng, nền vàng warningBanner (#FFF8E1) và đếm số SOS/thao tác đang đợi đồng bộ.
class OfflineBanner extends StatelessWidget {
  final int pendingSosCount;
  final int pendingActionsCount;

  const OfflineBanner({
    super.key,
    this.pendingSosCount = 0,
    this.pendingActionsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.warningBanner,
        border: Border(
          bottom: BorderSide(
            color: AppColors.priorityOrange,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.priorityOrange,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Không có kết nối mạng. Thiết bị đang chạy ngoại tuyến.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                if (pendingSosCount > 0 || pendingActionsCount > 0) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: AppSpacing.base,
                    children: [
                      if (pendingSosCount > 0)
                        Text(
                          '🆘 Đang chờ gửi $pendingSosCount yêu cầu SOS',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      if (pendingActionsCount > 0)
                        Text(
                          '🔄 Chờ đồng bộ $pendingActionsCount thao tác',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
