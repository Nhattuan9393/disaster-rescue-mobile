import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'auth_provider.dart';

/// Màn 09 (SRS) — Đăng ký hộ dân mới (FR-01.2).
/// Đầu vào: Họ tên, SĐT, mật khẩu, số thành viên, loại nhà, người yếu thế, vị trí GPS.
class RegisterHouseholdScreen extends ConsumerStatefulWidget {
  const RegisterHouseholdScreen({super.key});

  @override
  ConsumerState<RegisterHouseholdScreen> createState() =>
      _RegisterHouseholdScreenState();
}

class _RegisterHouseholdScreenState
    extends ConsumerState<RegisterHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noteController = TextEditingController();

  int _memberCount = 1;
  String _houseType = 'level4'; // level4 | multiStory
  String _hamlet = 'Thôn Bình An';
  bool _hasChildren = false;
  bool _hasElderly = false;
  bool _hasDisabled = false;
  bool _hasPregnant = false;
  bool _hasSeriouslyIll = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Mock GPS
  double _lat = 21.4617;
  double _lng = 107.3689;

  final _hamlets = [
    'Thôn Bình An',
    'Thôn Đồng Tâm',
    'Thôn Phú Lâm',
    'Thôn Hòa Bình',
    'Thôn Tân Lập',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Mock: đăng ký thành công → đăng nhập luôn
    ref.read(authProvider.notifier).login(
      _phoneController.text.trim(),
      [UserRole.household],
      displayName: _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Bạn có thể gửi SOS ngay.'),
          backgroundColor: AppColors.statusSafe,
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đăng ký hộ dân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            // ── Section 1: Thông tin chính ──
            _buildSectionHeader('Thông tin chính'),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ tên chủ hộ *',
                prefixIcon: Icon(Icons.person_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại *',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu *',
                prefixIcon: const Icon(Icons.lock_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) return 'Tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Thôn/xóm
            DropdownButtonFormField<String>(
              value: _hamlet,
              decoration: const InputDecoration(
                labelText: 'Thôn/Xóm *',
                prefixIcon: Icon(Icons.location_city_rounded),
                border: OutlineInputBorder(),
              ),
              items: _hamlets
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (v) => setState(() => _hamlet = v ?? _hamlet),
            ),
            const SizedBox(height: AppSpacing.md),

            // Số thành viên
            Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Số thành viên: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _memberCount > 1
                      ? () => setState(() => _memberCount--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text(
                  '$_memberCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _memberCount++),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Loại nhà
            const Text(
              'Loại nhà:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'level4', label: Text('Cấp 4')),
                ButtonSegment(value: 'multiStory', label: Text('Nhiều tầng')),
              ],
              selected: {_houseType},
              onSelectionChanged: (v) =>
                  setState(() => _houseType = v.first),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Section 2: Người dễ bị tổn thương ──
            _buildSectionHeader('Người dễ bị tổn thương'),
            const SizedBox(height: AppSpacing.sm),
            _buildCheckbox('Trẻ em', _hasChildren,
                (v) => setState(() => _hasChildren = v ?? false)),
            _buildCheckbox('Người già', _hasElderly,
                (v) => setState(() => _hasElderly = v ?? false)),
            _buildCheckbox('Khuyết tật', _hasDisabled,
                (v) => setState(() => _hasDisabled = v ?? false)),
            _buildCheckbox('Mang thai', _hasPregnant,
                (v) => setState(() => _hasPregnant = v ?? false)),
            _buildCheckbox('Ốm nặng', _hasSeriouslyIll,
                (v) => setState(() => _hasSeriouslyIll = v ?? false)),

            const SizedBox(height: AppSpacing.lg),

            // ── Section 3: Vị trí nhà ──
            _buildSectionHeader('Vị trí nhà'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.textDisabled),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded,
                        size: 48, color: AppColors.textDisabled),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                // Mock: lấy GPS hiện tại
                setState(() {
                  _lat = 21.4617 + (DateTime.now().millisecond / 100000);
                  _lng = 107.3689 + (DateTime.now().millisecond / 100000);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật vị trí GPS')),
                );
              },
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Dùng vị trí GPS hiện tại'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Section 4: Ghi chú ──
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tuỳ chọn)',
                hintText: 'VD: Nhà sát bờ sông, hay bị ngập...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Nút đăng ký
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: AppTypography.fontFamily,
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
