import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/household_registry/providers/household_registry_provider.dart';
import 'package:disaster_rescue/data/models/household_model.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class DuplicateResolutionScreen extends ConsumerWidget {
  const DuplicateResolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(householdRegistryProvider);
    final duplicates = state.duplicates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đối chiếu xử lý trùng lặp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: duplicates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.statusSafe),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Không phát hiện trùng lặp dữ liệu!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('QUAY LẠI'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: duplicates.length,
              itemBuilder: (context, index) {
                final duplicate = duplicates[index];
                final existing = duplicate['existing']!;
                final imported = duplicate['imported']!;
                return _buildResolutionCard(context, ref, existing, imported, index + 1, duplicates.length);
              },
            ),
    );
  }

  Widget _buildResolutionCard(
    BuildContext context,
    WidgetRef ref,
    HouseholdModel existing,
    HouseholdModel imported,
    int current,
    int total,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cặp trùng lặp $current / $total',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.priorityOrange),
                ),
                Text('SĐT: ${existing.ownerPhone}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            
            // Layout 2 cột: Hiện tại vs Mới import
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DỮ LIỆU HIỆN TẠI',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoBlock(existing, imported, isExisting: true),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(width: 1, height: 180, color: const Color(0xFFE0E0E0)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DỮ LIỆU MỚI IMPORT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.infoBlue),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoBlock(imported, existing, isExisting: false),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(householdRegistryProvider.notifier).resolveDuplicate(existing.ownerPhone, 'skip');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã bỏ qua dữ liệu mới')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('BỎ QUA (GIỮ CŨ)'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(householdRegistryProvider.notifier).resolveDuplicate(existing.ownerPhone, 'overwrite');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã ghi đè thành công')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('GHI ĐÈ (LẤY MỚI)'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(householdRegistryProvider.notifier).resolveDuplicate(existing.ownerPhone, 'merge');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hợp nhất dữ liệu')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusSafe,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('HỢP NHẤT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(HouseholdModel current, HouseholdModel other, {required bool isExisting}) {
    // Check khác biệt để highlight màu vàng
    final bool nameDiff = current.ownerName != other.ownerName;
    final bool addrDiff = current.address != other.address;
    final bool peopleDiff = current.peopleCount != other.peopleCount;
    final bool typeDiff = current.houseType != other.houseType;
    final bool childrenDiff = current.hasChildren != other.hasChildren;
    final bool elderlyDiff = current.hasElderly != other.hasElderly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem('Chủ hộ:', current.ownerName, hasDiff: nameDiff),
        _buildItem('Địa chỉ:', current.address, hasDiff: addrDiff),
        _buildItem('Nhân khẩu:', '${current.peopleCount} người', hasDiff: peopleDiff),
        _buildItem('Loại nhà:', current.houseType == HouseType.level4 ? 'Cấp 4' : 'Nhiều tầng', hasDiff: typeDiff),
        _buildItem('Yếu thế:', _vulnerableText(current), hasDiff: childrenDiff || elderlyDiff),
      ],
    );
  }

  Widget _buildItem(String label, String value, {required bool hasDiff}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDisabled)),
          Container(
            padding: hasDiff ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) : EdgeInsets.zero,
            decoration: hasDiff
                ? BoxDecoration(
                    color: AppColors.warningBanner,
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasDiff ? FontWeight.bold : FontWeight.normal,
                color: hasDiff ? AppColors.priorityOrange : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _vulnerableText(HouseholdModel model) {
    final List<String> list = [];
    if (model.hasChildren) list.add('Trẻ em');
    if (model.hasElderly) list.add('Người già');
    if (model.hasSeriouslyIll) list.add('Bệnh nặng');
    if (model.hasDisabled) list.add('Tàn tật');
    return list.isEmpty ? 'Không có' : list.join(', ');
  }
}
