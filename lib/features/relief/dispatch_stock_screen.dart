import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

class DispatchStockScreen extends ConsumerStatefulWidget {
  const DispatchStockScreen({super.key});

  @override
  ConsumerState<DispatchStockScreen> createState() => _DispatchStockScreenState();
}

class _DispatchStockScreenState extends ConsumerState<DispatchStockScreen> {
  String? _selectedItemId;
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reliefProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xuất Kho Cứu Trợ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chọn mặt hàng xuất kho:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedItemId,
              hint: const Text('Chọn mặt hàng'),
              items: state.items.map((item) => DropdownMenuItem(
                value: item.id,
                child: Text('${item.name} (Tồn: ${item.quantity.toInt()} ${item.unit})'),
              )).toList(),
              onChanged: (val) => setState(() => _selectedItemId = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.md),

            const Text('Số lượng xuất:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'VD: 50',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(_qtyController.text) ?? 0;
                if (_selectedItemId == null || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn mặt hàng và số lượng hợp lệ.')),
                  );
                  return;
                }

                final success = ref.read(reliefProvider.notifier).dispatchStock(_selectedItemId!, qty);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xuất kho thành công!'), backgroundColor: AppColors.statusSafe),
                  );
                  context.pop();
                } else if (mounted) {
                  final error = ref.read(reliefProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Lỗi không xác định khi xuất kho.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: const Text('XÁC NHẬN XUẤT KHO'),
            ),
          ],
        ),
      ),
    );
  }
}
