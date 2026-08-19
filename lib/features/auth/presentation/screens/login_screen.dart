import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_model.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final input = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (input.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập tài khoản và mật khẩu.');
      return;
    }

    final user = await ref
        .read(authControllerProvider.notifier)
        .signIn(input, password);

    if (!mounted) return;
    if (user == null) {
      final error = ref.read(authControllerProvider).error;
      _showLoginFailedDialog(error);
      return;
    }
    _routeByRole(user);
  }

  void _routeByRole(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        _snack('🏛️ Đăng nhập Admin thành công', Colors.blue.shade900);
        context.go('/admin');
        break;
      case UserRole.rescueTeam:
        final type = user.teamType == RescueTeamType.volunteer
            ? 'volunteer'
            : 'permanent';
        _snack('⛑️ Đăng nhập Đội cứu hộ thành công', Colors.green.shade800);
        context.go('/rescue?type=$type');
        break;
      case UserRole.household:
        _snack('🏠 Đăng nhập Hộ dân thành công', const Color(0xFFD32F2F));
        context.go('/resident');
        break;
      case UserRole.public:
        context.go('/situation-board');
        break;
    }
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showLoginFailedDialog(String? error) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Đăng nhập thất bại',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          error ??
              'Mật khẩu không khớp hoặc tài khoản không tồn tại. Bạn muốn đăng ký tài khoản mới?',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/register-household');
            },
            child: const Text('Đăng ký Hộ dân',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/volunteer-register');
            },
            child: const Text('Đăng ký Cứu hộ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Thử lại', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _logoBadge(),
                const SizedBox(height: 12),
                const Text(
                  'DisasterRescue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đăng nhập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đăng nhập để gửi SOS và nhận cảnh báo sớm',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12.5),
                ),
                const SizedBox(height: 24),
                _loginForm(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: authState.isLoading ? null : _submitLogin,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 0.5),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/situation-board'),
                    icon: Icon(Icons.visibility,
                        color: Colors.blue.shade800, size: 18),
                    label: Text(
                      '👁️ Xem tình hình thiên tai (không cần đăng nhập)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/register-household'),
                      child: const Text(
                        'Đăng ký hộ dân',
                        style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('·',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/volunteer-register'),
                      child: const Text(
                        'Đăng ký đội cứu hộ',
                        style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _testAccountsHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoBadge() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87, width: 2.5),
          ),
          child: const Center(
            child: Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SỐ ĐIỆN THOẠI HOẶC TÊN TÀI KHOẢN',
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _usernameCtrl,
          decoration: InputDecoration(
            hintText: 'admin / dq01 / 0987654321',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        const Text(
          'MẬT KHẨU',
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _testAccountsHint() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('🧪 Tài khoản demo (auto-provision lần đầu):',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
          SizedBox(height: 4),
          Text('• admin / 123456 → Admin',
              style: TextStyle(fontSize: 10.5, color: Colors.brown)),
          Text('• dq01 / 123456 → Đội cứu hộ thường trực',
              style: TextStyle(fontSize: 10.5, color: Colors.brown)),
          Text('• vl1 / 12345 → Đội cứu hộ vãng lai',
              style: TextStyle(fontSize: 10.5, color: Colors.brown)),
          Text('• 0987654321 / 123456 → Hộ dân',
              style: TextStyle(fontSize: 10.5, color: Colors.brown)),
        ],
      ),
    );
  }
}
