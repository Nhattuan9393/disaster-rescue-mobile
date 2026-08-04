import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'auth_provider.dart';

/// Màn hình chọn vai trò hoạt động khi tài khoản có nhiều quyền hạn.
class RoleSelectorScreen extends ConsumerWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chọn vai trò hoạt động'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Tài khoản của bạn có nhiều quyền hạn. Vui lòng chọn một vai trò để làm việc:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: authState.availableRoles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final role = authState.availableRoles[index];
                    IconData icon;
                    String desc;

                    switch (role) {
                      case UserRole.household:
                        icon = Icons.home_rounded;
                        desc = 'Gửi SOS cứu nạn, khai báo y tế, sơ tán khẩn cấp';
                        break;
                      case UserRole.admin:
                        icon = Icons.admin_panel_settings_rounded;
                        desc = 'Điều phối nhân lực cứu nạn, phê duyệt yêu cầu hỗ trợ, theo dõi bản đồ trực quan';
                        break;
                      case UserRole.rescueTeam:
                        icon = Icons.health_and_safety_rounded;
                        desc = 'Nhận nhiệm vụ, định vị khu vực sự cố, cấp phát gói cứu trợ tại hiện trường';
                        break;
                      case UserRole.public:
                        icon = Icons.dashboard_rounded;
                        desc = 'Xem Situation Board công khai';
                        break;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          ref.read(authProvider.notifier).selectRole(role);
                          context.go('/');
                        },
                        borderRadius: AppRadius.card,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: AppSpacing.base),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.label,
                                      style: AppTypography.h3.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: AppTypography.fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
