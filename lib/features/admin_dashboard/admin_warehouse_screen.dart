import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/stock_card.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';

/// Màn hình Quản lý kho hai tầng của Xã (FR-10.7).
class AdminWarehouseScreen extends ConsumerWidget {
  const AdminWarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reliefProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tồn kho vật tư chính thức',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/relief-stock'),
                  icon: const Icon(Icons.inventory_rounded),
                  label: const Text('Chi Tiết Kho'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Thanh hành động nhanh cho Admin
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/receive-stock'),
                    icon: const Icon(Icons.add_box_rounded, color: AppColors.statusSafe),
                    label: const Text('Nhập Kho', style: TextStyle(color: AppColors.statusSafe)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusSafe),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/dispatch-stock'),
                    icon: const Icon(Icons.indeterminate_check_box_rounded, color: AppColors.primary),
                    label: const Text('Xuất Kho', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/relief-receipt'),
                    icon: const Icon(Icons.receipt_long_rounded, color: AppColors.infoBlue),
                    label: const Text('Phát Hàng', style: TextStyle(color: AppColors.infoBlue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.infoBlue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final isBelow = item.quantity < item.threshold;
                  return StockCard(
                    itemName: item.name,
                    currentQty: item.quantity.toInt(),
                    thresholdQty: item.threshold.toInt(),
                    unit: item.unit,
                    capacity: (item.threshold * 3).toInt(), // Giả lập sức chứa tối đa
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
