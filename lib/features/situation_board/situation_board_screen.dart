import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/kpi_card.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';

/// Situation Board công khai dành cho tất cả mọi người (không cần đăng nhập).
class SituationBoardScreen extends ConsumerWidget {
  const SituationBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảng Tin Tình Hình Xã'),
        actions: [
          if (!authState.isAuthenticated)
            TextButton.icon(
              icon: const Icon(Icons.login_rounded, color: AppColors.primary),
              label: const Text('Đăng nhập', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onPressed: () => context.go('/login'),
            )
          else
            IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () => context.go('/'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ CẬP NHẬT THIÊN TAI realtime',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bão lũ dâng cao ở lưu vực sông Ba Chẽ và Bình Liêu. Người dân hạn chế di chuyển trong vùng trũng thấp.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Số liệu tổng hợp cứu trợ (Số tuyệt đối)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.6,
              children: [
                KpiCard(
                  title: 'Tổng số hộ cần cứu',
                  value: '18 vụ',
                  icon: Icons.sos_rounded,
                  color: AppColors.priorityRed,
                ),
                KpiCard(
                  title: 'Đã đưa cứu an toàn',
                  value: '126 hộ',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.statusSafe,
                ),
                KpiCard(
                  title: 'Hộ đang mất liên lạc',
                  value: '4 hộ',
                  icon: Icons.phone_locked_rounded,
                  color: AppColors.statusMissing,
                ),
                KpiCard(
                  title: 'Lực lượng điều phối',
                  value: '12 đội',
                  icon: Icons.group_work_rounded,
                  color: AppColors.statusRescuing,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Vị trí vùng nguy hiểm (Bản đồ công khai)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.textDisabled.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    'Bản đồ OpenStreetMap (Offline Cache)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
