import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/shared/widgets/status_chip.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';
import 'package:disaster_rescue/features/household/providers/safety_status_provider.dart';
import 'package:disaster_rescue/features/household/widgets/action_tier_button.dart';

class HouseholdHomeScreen extends ConsumerWidget {
  const HouseholdHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(sosProvider);
    final safetyStatus = ref.watch(safetyStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              
              // === HEADER: Báo cáo an toàn ===
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái an toàn của tôi:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StatusChip(
                        status: safetyStatus.status,
                        source: safetyStatus.source,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (safetyStatus.note != null)
                        Text(
                          safetyStatus.note!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // === TẦNG 1: SOS (Tính bằng phút) ===
              Center(
                child: Column(
                  children: [
                    SosButton(
                      state: sosState,
                      onTap: () => ref.read(sosProvider.notifier).sendSos(),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    const Text(
                      'BẤM 1 CHẠM ĐỂ GỬI SOS KHẨN CẤP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTypography.fontFamily,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Hệ thống tự động lấy tọa độ và tính điểm ưu tiên.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // === TẦNG 2: Yêu cầu sơ tán & Xác nhận an toàn (Tính bằng giờ) ===
              Row(
                children: [
                  Expanded(
                    child: ActionTierButton(
                      icon: Icons.airport_shuttle_rounded,
                      label: 'Cần hỗ trợ\nsơ tán',
                      backgroundColor: AppColors.primaryLight,
                      contentColor: Colors.white,
                      height: 88,
                      onTap: () => context.go('/evacuation-request'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: ActionTierButton(
                      icon: Icons.check_circle_outline,
                      label: 'Tôi vẫn\nan toàn',
                      backgroundColor: AppColors.statusSafe,
                      contentColor: Colors.white,
                      height: 88,
                      onTap: () {
                        ref.read(safetyStatusProvider.notifier).markAsSafe();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật trạng thái an toàn lên hệ thống.'),
                            backgroundColor: AppColors.statusSafe,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              
              // === TẦNG 3: Báo tin cho xã (Không khẩn cấp) ===
              Row(
                children: [
                  Expanded(
                    child: ActionTierButton(
                      icon: Icons.people_outline,
                      label: 'Báo giúp\nngười khác',
                      backgroundColor: AppColors.surface,
                      contentColor: AppColors.textPrimary,
                      height: 72,
                      isOutline: true,
                      onTap: () => context.go('/report-to-commune?type=others'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: ActionTierButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Báo tình hình\nkhu vực',
                      backgroundColor: AppColors.surface,
                      contentColor: AppColors.textPrimary,
                      height: 72,
                      isOutline: true,
                      onTap: () => context.go('/report-to-commune?type=area'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
