import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../features/household/data/household_repository.dart';
import '../../../../features/household/domain/household_model.dart';

class HouseholdProfileScreen extends ConsumerStatefulWidget {
  const HouseholdProfileScreen({super.key});

  @override
  ConsumerState<HouseholdProfileScreen> createState() => _HouseholdProfileScreenState();
}

class _HouseholdProfileScreenState extends ConsumerState<HouseholdProfileScreen> {
  void _showEditDialog(HouseholdModel household) {
    final headNameCtrl = TextEditingController(text: household.pendingHeadName ?? household.headName ?? 'Nguyễn Văn A');
    final contactPhoneCtrl = TextEditingController(text: household.pendingContactPhone ?? household.contactPhone ?? '0912.345.678');
    final addressCtrl = TextEditingController(text: household.pendingAddress ?? household.address);
    final memberCountCtrl = TextEditingController(text: (household.pendingMemberCount ?? household.memberCount).toString());

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cập nhật thông tin hộ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: headNameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên chủ hộ'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contactPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'SĐT liên hệ'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Địa chỉ hộ'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: memberCountCtrl,
                  decoration: const InputDecoration(labelText: 'Số nhân khẩu'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
              onPressed: () async {
                final headName = headNameCtrl.text.trim();
                final contactPhone = contactPhoneCtrl.text.trim();
                final address = addressCtrl.text.trim();
                final memberCount = int.tryParse(memberCountCtrl.text) ?? household.memberCount;

                if (headName.isEmpty || contactPhone.isEmpty || address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                // Cập nhật thông tin chờ Admin phê duyệt (DR-011)
                final updated = household.copyWith(
                  isUpdatePending: true,
                  pendingHeadName: headName,
                  pendingContactPhone: contactPhone,
                  pendingAddress: address,
                  pendingMemberCount: memberCount,
                );

                await ref.read(householdRepositoryProvider).update(updated);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi yêu cầu cập nhật thông tin. Đang chờ Admin duyệt!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('GỬI DUYỆT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myHouseholdAsync = ref.watch(myHouseholdStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Hồ Sơ Hộ Gia Đình',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: myHouseholdAsync.when(
        data: (household) {
          if (household == null) {
            return const Center(child: Text('Không tìm thấy thông tin hộ dân của bạn.'));
          }

          final headName = household.headName ?? 'Nguyễn Văn A';
          final contactPhone = household.contactPhone ?? '0912.345.678';
          final address = household.address;
          final memberCount = household.memberCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. Banner chờ duyệt (nếu có)
                if (household.isUpdatePending)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_actions, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YÊU CẦU ĐANG CHỜ DUYỆT',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Đang chờ Admin phê duyệt cập nhật thông tin: \n· Tên: ${household.pendingHeadName}\n· SĐT: ${household.pendingContactPhone}\n· Đ/c: ${household.pendingAddress}\n· Khẩu: ${household.pendingMemberCount}',
                                style: TextStyle(fontSize: 10.5, color: Colors.orange.shade900, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Thẻ thông tin Hộ gia đình
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hộ $headName',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue.shade900,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: const Icon(Icons.edit, size: 12),
                            label: const Text('Sửa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () => _showEditDialog(household),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('📍 Địa chỉ: $address', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('📞 SĐT Chủ hộ: $contactPhone', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('🌐 Tọa độ GPS: ${household.latitude.toStringAsFixed(4)} N, ${household.longitude.toStringAsFixed(4)} E', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. DANH SÁCH NHÂN KHẨU (5 THÀNH VIÊN)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DANH SÁCH NHÂN KHẨU ($memberCount NGƯỜI)',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 15, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Điểm danh an toàn',
                          style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildMemberCard(headName, '1980 (46 tuổi)', 'Nam', 'Chủ hộ · 👦 Lao động chính'),
                ...List.generate(
                  (memberCount > 1) ? memberCount - 1 : 0,
                  (i) => _buildMemberCard('Thành viên ${i + 1}', '1995 (${31 - i} tuổi)', i.isEven ? 'Nữ' : 'Nam', 'Thành viên'),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'ĐĂNG XUẤT TÀI KHOẢN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (mounted) context.go('/login');
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildMemberCard(String name, String year, String gender, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '$year · Giới tính: $gender',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
