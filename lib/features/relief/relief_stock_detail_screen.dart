import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

class ReliefStockDetailScreen extends ConsumerWidget {
  const ReliefStockDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reliefProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Quản lý Kho Cứu Trợ'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tồn Kho Chuẩn (Tầng 1)'),
              Tab(text: 'Lô Hàng Hỗn Hợp (Tầng 2)'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Thanh hành động nhanh
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/receive-stock'),
                      icon: const Icon(Icons.add_box_rounded),
                      label: const Text('NHẬP KHO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusSafe,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/dispatch-stock'),
                      icon: const Icon(Icons.indeterminate_check_box_rounded),
                      label: const Text('XUẤT KHO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildStandardStockTab(context, state.items),
                  _buildMixedPackagesTab(context, state.packages),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardStockTab(BuildContext context, List<ReliefItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isBelow = isBelowThreshold(item);

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          borderOnForeground: true,
          child: ListTile(
            leading: Icon(
              Icons.inventory_2_rounded,
              color: isBelow ? AppColors.priorityRed : AppColors.infoBlue,
              size: 32,
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isBelow ? AppColors.priorityRed : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Tối thiểu cần: ${item.threshold} ${item.unit}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.quantity.toInt()} ${item.unit}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isBelow ? AppColors.priorityRed : AppColors.textPrimary,
                  ),
                ),
                if (isBelow)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.priorityRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DƯỚI NGƯỠNG',
                      style: TextStyle(color: AppColors.priorityRed, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMixedPackagesTab(BuildContext context, List<ReliefPackage> packages) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          child: ExpansionTile(
            leading: const Icon(Icons.card_giftcard_rounded, color: AppColors.priorityOrange),
            title: Text(
              package.code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Đoàn: ${package.donorName}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SĐT: ${package.donorPhone}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      'Nhận bởi: ${package.receivedBy} lúc ${package.receivedAt.hour}:${package.receivedAt.minute}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Divider(height: AppSpacing.md),
                    const Text('Danh sách đồ thô (Chưa phân loại):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...package.lines.map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('• ${line.rawName}', style: const TextStyle(fontSize: 13)),
                              Text('${line.quantity.toInt()} ${line.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
