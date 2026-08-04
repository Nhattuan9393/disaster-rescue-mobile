import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/kpi_card.dart';
import 'package:disaster_rescue/shared/widgets/auto_metrics_block.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';

/// Màn hình Bản đồ Điều phối chính của Ban chỉ đạo xã.
class AdminMapScreen extends ConsumerWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bản đồ Điều phối Xã'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chỉ số cứu nạn toàn xã (Số tuyệt đối)',
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
                  title: 'Đang chờ cứu hộ',
                  value: '3 hộ',
                  icon: Icons.sos_rounded,
                  color: AppColors.priorityRed,
                ),
                KpiCard(
                  title: 'Đang tiếp cận',
                  value: '2 đội',
                  icon: Icons.directions_boat_rounded,
                  color: AppColors.priorityOrange,
                ),
                KpiCard(
                  title: 'Đã giải cứu xong',
                  value: '42 hộ',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.statusSafe,
                ),
                KpiCard(
                  title: 'Mất liên lạc',
                  value: '8 hộ',
                  icon: Icons.phone_locked_rounded,
                  color: AppColors.statusMissing,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Bản đồ Realtime cứu hộ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 250,
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
                    'Bản đồ OpenStreetMap và Marker SOS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Khối minh chứng leo thang tự sinh hệ thống (Mục 18 trong SRS)
            AutoMetricsBlock(
              redSosUnassigned: 3,
              longestWait: const Duration(hours: 1, minutes: 45),
              householdsMissing: 8,
              teamsAvailable: 1,
              teamsTotal: 6,
              itemsBelowThreshold: 2,
              evacuationSlotsFree: 25,
              computedAt: DateTime.now(),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yêu cầu Leo thang đã gửi thành công lên huyện kèm minh chứng.')),
                );
              },
              icon: const Icon(Icons.arrow_upward_rounded),
              label: const Text('Gửi yêu cầu Leo thang lên Huyện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
