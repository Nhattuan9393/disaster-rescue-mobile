import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/team_provider.dart';
import 'team_status_screen.dart';

class TeamRegisterScreen extends ConsumerStatefulWidget {
  final String qrCode;

  const TeamRegisterScreen({super.key, required this.qrCode});

  @override
  ConsumerState<TeamRegisterScreen> createState() => _TeamRegisterScreenState();
}

class _TeamRegisterScreenState extends ConsumerState<TeamRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final List<String> _members = [];
  final _memberInputController = TextEditingController();

  // Vật tư mang theo (Supplies brought)
  final Map<String, double> _supplies = {
    'Áo phao': 0.0,
    'Mì tôm (thùng)': 0.0,
    'Nước suối (thùng)': 0.0,
    'Lương khô (thùng)': 0.0,
    'Thuốc men (hộp)': 0.0,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _memberInputController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberInputController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _members.add(name);
        _memberInputController.clear();
      });
    }
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  void _submitRegistration() {
    if (!_formKey.currentState!.validate()) return;
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một thành viên vào đội')),
      );
      return;
    }

    // Gửi đăng ký lên provider
    ref.read(activeTeamProvider.notifier).registerAdhocTeam(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          members: _members,
          supplies: Map.from(_supplies)..removeWhere((key, value) => value <= 0),
          qrCode: widget.qrCode,
        );
  }

  void _simulateAdminApprove() {
    ref.read(activeTeamProvider.notifier).approveAdhocTeam();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TeamStatusScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(activeTeamProvider);

    // Nếu đang ở trạng thái chờ duyệt, hiển thị màn hình chờ phê duyệt
    if (teamState.isPendingApproval) {
      return _buildPendingApprovalView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text('ĐĂNG KÝ ĐỘI VÃNG LAI', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin chung
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('THÔNG TIN CHUNG', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Đội / Đoàn thiện nguyện *',
                          hintText: 'Ví dụ: Đoàn thiện nguyện Hạ Long',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên Đội/Đoàn';
                          }
                          return null;
                        },
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại trưởng đoàn *',
                          hintText: 'Nhập số điện thoại để liên hệ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Thành viên
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('THÀNH VIÊN ĐỘI (Ít nhất 1 người) *', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _memberInputController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập họ tên thành viên...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              ),
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(AppSpacing.base),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            onPressed: _addMember,
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_members.isEmpty)
                        Text(
                          'Chưa có thành viên nào được thêm',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: AppColors.background,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.person, color: AppColors.textSecondary),
                                title: Text(_members[index], style: AppTypography.bodyMedium),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeMember(index),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Vật tư mang theo (Supplies)
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VẬT TƯ MANG THEO CỨU TRỢ', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.md),
                      ..._supplies.keys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(key, style: AppTypography.bodyMedium),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: _supplies[key]! > 0
                                        ? () {
                                            setState(() {
                                              _supplies[key] = _supplies[key]! - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      _supplies[key]!.toInt().toString(),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _supplies[key] = _supplies[key]! + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: _submitRegistration,
                child: const Text('GỬI ĐĂNG KÝ CHO XÃ DUYỆT', style: AppTypography.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApprovalView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5.0,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'ĐANG CHỜ ADMIN DUYỆT ĐỘI',
                textAlign: TextAlign.center,
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Thông tin đội của bạn đã được gửi tới hệ thống chỉ huy xã Bình Liêu.\n\nThông thường cán bộ tại chốt sẽ phê duyệt trong vòng 2-3 phút. Giao diện sẽ tự động chuyển đổi khi được duyệt.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Simulator panel dành cho Giáo viên / Tester (FR-09.1)
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                  side: BorderSide(color: Colors.amber.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    children: [
                      Text(
                        'TRÌNH GIẢ LẬP KIỂM THỬ (QA)',
                        style: AppTypography.label.copyWith(color: Colors.amber.shade900),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Bấm nút dưới đây để giả lập hành vi Admin chốt bấm nút "Phê duyệt" trên Dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        onPressed: _simulateAdminApprove,
                        child: const Text('PHÊ DUYỆT NHANH (APPROVE)'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
