import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'auth_provider.dart';

/// Màn Hồ sơ người dùng — xem thông tin, đổi vai trò (FR-01.5), đăng xuất.
/// Phải có nút đổi vai trò không cần đăng xuất (quyết định 2.6).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // Avatar + Tên
          Card(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _getInitials(auth.displayName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    auth.displayName ?? 'Người dùng',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    auth.phoneNumber ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Vai trò hiện tại
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      'Vai trò: ${auth.activeRole?.label ?? 'Chưa chọn'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.base),

          // Thao tác
          Card(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: Column(
              children: [
                // Đổi vai trò — chỉ hiện khi có >= 2 vai trò
                if (auth.availableRoles.length >= 2)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz_rounded,
                        color: AppColors.infoBlue),
                    title: const Text(
                      'Đổi vai trò',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                    subtitle: Text(
                      'Các vai trò: ${auth.availableRoles.map((r) => r.label).join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ref.read(authProvider.notifier).switchRole();
                      context.go('/role-selector');
                    },
                  ),
                if (auth.availableRoles.length >= 2) const Divider(height: 1),

                // Thông tin hộ gia đình
                ListTile(
                  leading: const Icon(Icons.home_rounded,
                      color: AppColors.textSecondary),
                  title: const Text(
                    'Thông tin hộ gia đình',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo: Mở chi tiết hồ sơ hộ')),
                    );
                  },
                ),
                const Divider(height: 1),

                // Cài đặt ngôn ngữ
                ListTile(
                  leading: const Icon(Icons.language_rounded,
                      color: AppColors.textSecondary),
                  title: const Text(
                    'Ngôn ngữ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  subtitle: const Text('Tiếng Việt'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Demo: Hỗ trợ vi_VN và tay_VN')),
                    );
                  },
                ),
                const Divider(height: 1),

                // Phiên bản
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded,
                      color: AppColors.textSecondary),
                  title: Text(
                    'Phiên bản',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  subtitle: Text('DisasterRescue v1.0.0+1'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Đăng xuất
          OutlinedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
