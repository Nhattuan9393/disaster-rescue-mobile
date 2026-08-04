import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/stock_card.dart';
import 'package:disaster_rescue/shared/widgets/line_entry_table.dart';

/// Màn hình Quản lý kho hai tầng của Xã (FR-10.7).
class AdminWarehouseScreen extends StatefulWidget {
  const AdminWarehouseScreen({super.key});

  @override
  State<AdminWarehouseScreen> createState() => _AdminWarehouseScreenState();
}

class _AdminWarehouseScreenState extends State<AdminWarehouseScreen> {
  List<LineEntryRow> _entryLines = [
    const LineEntryRow(name: 'Mì ăn liền', quantity: 200, unit: 'thùng'),
    const LineEntryRow(name: 'Nước đóng chai', quantity: 150, unit: 'lốc'),
  ];

  void _handleReceivePackage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tiếp nhận Gói Cứu trợ (Lô hỗn hợp)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hệ thống sẽ tự sinh mã GCT-2025-xxxx khẩn cấp mà không chặn luồng cứu trợ.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return LineEntryTable(
                      lines: _entryLines,
                      onChanged: (newLines) {
                        setDialogState(() {
                          _entryLines = newLines;
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã tiếp nhận thành công Gói cứu trợ GCT-2025-0082!')),
                );
              },
              child: const Text('Lưu & Phân loại sau'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _handleReceivePackage,
                  icon: const Icon(Icons.add_box_rounded),
                  label: const Text('Tiếp nhận Gói (MTQ)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                children: const [
                  StockCard(
                    itemName: 'Mì ăn liền Hảo Hảo',
                    currentQty: 320,
                    thresholdQty: 500,
                    unit: 'thùng',
                    capacity: 1000,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  StockCard(
                    itemName: 'Nước khoáng Lavie 1.5L',
                    currentQty: 850,
                    thresholdQty: 300,
                    unit: 'chai',
                    capacity: 1500,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  StockCard(
                    itemName: 'Áo phao cứu sinh',
                    currentQty: 45,
                    thresholdQty: 100,
                    unit: 'cái',
                    capacity: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
