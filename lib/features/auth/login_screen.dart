import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'auth_provider.dart';

/// Dữ liệu giả lập 5 tài khoản mock (FR-01.1).
/// SĐT 0901000001~05, mật khẩu luôn là "123456".
class _MockUser {
  final String phone;
  final String name;
  final String password;
  final List<UserRole> roles;

  const _MockUser({
    required this.phone,
    required this.name,
    this.password = '123456',
    required this.roles,
  });
}

const _mockUsers = [
  _MockUser(phone: '0901000001', name: 'Nguyễn Văn An', roles: [UserRole.household]),
  _MockUser(phone: '0901000002', name: 'Trần Thị Bình', roles: [UserRole.admin]),
  _MockUser(phone: '0901000003', name: 'Lê Văn Cường', roles: [UserRole.rescueTeam]),
  _MockUser(phone: '0901000004', name: 'Phạm Thị Dung', roles: [UserRole.household, UserRole.admin]),
  _MockUser(phone: '0901000005', name: 'Hoàng Văn Em', roles: [UserRole.household, UserRole.rescueTeam]),
];

/// Màn 02 — Đăng nhập bằng SĐT + mật khẩu.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Mô phỏng network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // Tìm mock user
    final mockUser = _mockUsers.cast<_MockUser?>().firstWhere(
      (u) => u!.phone == phone,
      orElse: () => null,
    );

    if (mockUser == null || mockUser.password != password) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Thông tin đăng nhập không đúng';
      });
      return;
    }

    // Đăng nhập thành công
    ref.read(authProvider.notifier).login(
      phone,
      mockUser.roles,
      displayName: mockUser.name,
    );

    setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
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

                // Card đăng nhập
                Card(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // SĐT
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            hintText: '0901000001',
                            prefixIcon: Icon(Icons.phone_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            hintText: '123456',
                            prefixIcon: const Icon(Icons.lock_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            return null;
                          },
                        ),

                        // Lỗi đăng nhập
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.card,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.primary, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.base),

                        // Nút đăng nhập
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppTypography.fontFamily,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Đăng ký hộ dân
                OutlinedButton.icon(
                  onPressed: () => context.go('/register-household'),
                  icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
                  label: const Text(
                    'Đăng ký hộ dân',
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

                const SizedBox(height: AppSpacing.sm),

                // Xem công khai
                TextButton.icon(
                  onPressed: _handleEnterPublic,
                  icon: const Icon(Icons.dashboard_rounded, color: AppColors.textSecondary),
                  label: const Text(
                    'Xem tình hình thiên tai',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),

                // Gợi ý tài khoản test
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningBanner,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.priorityYellow.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TÀI KHOẢN THỬ NGHIỆM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ..._mockUsers.map((u) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: GestureDetector(
                          onTap: () {
                            _phoneController.text = u.phone;
                            _passwordController.text = u.password;
                          },
                          child: Text(
                            '${u.phone} — ${u.roles.map((r) => r.label).join(', ')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.infoBlue,
                              fontFamily: AppTypography.fontFamily,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
