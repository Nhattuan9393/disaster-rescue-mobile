import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/household/data/household_repository.dart';

class VerifyProfileUpdatesScreen extends ConsumerWidget {
  const VerifyProfileUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingHouseholdsStreamProvider);

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
          'Duyệt Thay Đổi Hồ Sơ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: pendingAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✅', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'Không có yêu cầu chỉnh sửa hồ sơ nào cần duyệt!',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final household = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          radius: 16,
                          child: const Icon(Icons.person, color: Colors.orange, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Yêu cầu từ: Hộ ${household.headName ?? "Chưa rõ"}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // So sánh thông tin
                    const Text('THÔNG TIN THAY ĐỔI:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 9.5)),
                    const SizedBox(height: 8),
                    _buildCompareRow('Tên chủ hộ', household.headName, household.pendingHeadName),
                    const SizedBox(height: 6),
                    _buildCompareRow('Số điện thoại', household.contactPhone, household.pendingContactPhone),
                    const SizedBox(height: 6),
                    _buildCompareRow('Địa chỉ nhà', household.address, household.pendingAddress),
                    const SizedBox(height: 6),
                    _buildCompareRow('Số nhân khẩu', '${household.memberCount} người', '${household.pendingMemberCount} người'),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final rejected = household.copyWith(
                              isUpdatePending: false,
                              pendingHeadName: null,
                              pendingContactPhone: null,
                              pendingAddress: null,
                              pendingMemberCount: null,
                            );
                            await ref.read(householdRepositoryProvider).update(rejected);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã từ chối cập nhật hồ sơ.'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: const Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final approved = household.copyWith(
                              isUpdatePending: false,
                              headName: household.pendingHeadName ?? household.headName,
                              contactPhone: household.pendingContactPhone ?? household.contactPhone,
                              address: household.pendingAddress ?? household.address,
                              memberCount: household.pendingMemberCount ?? household.memberCount,
                              pendingHeadName: null,
                              pendingContactPhone: null,
                              pendingAddress: null,
                              pendingMemberCount: null,
                            );
                            await ref.read(householdRepositoryProvider).update(approved);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã phê duyệt cập nhật hồ sơ thành công!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                          child: const Text('PHÊ DUYỆT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildCompareRow(String fieldLabel, String? oldValue, String? newValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$fieldLabel:',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                oldValue ?? 'Trống',
                style: const TextStyle(fontSize: 11.5, color: Colors.black54, decoration: TextDecoration.lineThrough),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_right_alt, size: 14, color: Colors.orange),
              ),
              Text(
                newValue ?? 'Không đổi',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
