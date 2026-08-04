import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'auth_provider.dart';

/// Màn hình đăng nhập giả lập hỗ trợ thử nghiệm nhanh.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '0987654321');
  final List<UserRole> _selectedRoles = [UserRole.household];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleRole(UserRole role) {
    setState(() {
      if (_selectedRoles.contains(role)) {
        if (_selectedRoles.length > 1) {
          _selectedRoles.remove(role);
        }
      } else {
        _selectedRoles.add(role);
      }
    });
  }

  void _handleLogin() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    ref.read(authProvider.notifier).login(phone, _selectedRoles);
    context.go('/');
  }

  void _handleEnterPublic() {
    ref.read(authProvider.notifier).enterAsPublic();
    context.go('/public-board');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'DisasterRescue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const Text(
                'Điều phối cứu hộ khẩn cấp thiên tai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'ĐĂNG NHẬP THỬ NGHIỆM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Chọn vai trò giả lập (có thể chọn nhiều):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...UserRole.values
                          .where((r) => r != UserRole.public)
                          .map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return CheckboxListTile(
                          title: Text(
                            role.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (_) => _toggleRole(role),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                      const SizedBox(height: AppSpacing.base),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButtonThemeData().style?.copyWith(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: AppSpacing.md),
                          ),
                        ) ?? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: AppColors.surface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              OutlinedButton.icon(
                onPressed: _handleEnterPublic,
                icon: const Icon(Icons.dashboard_rounded, color: AppColors.textPrimary),
                label: const Text(
                  'Xem Situation Board công khai',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: const BorderSide(color: AppColors.textPrimary, width: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
