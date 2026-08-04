import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/quantity_stepper.dart';
import '../../../../data/models/relief_models.dart';

class _DistributionRow {
  String itemName;
  SupplySource source;
  int quantity;

  _DistributionRow({
    required this.itemName,
    required this.source,
    required this.quantity,
  });
}

class ReliefDistributionScreen extends ConsumerStatefulWidget {
  final String householdId;
  final String householdName;
  final int memberCount;

  const ReliefDistributionScreen({
    super.key,
    required this.householdId,
    required this.householdName,
    required this.memberCount,
  });

  @override
  ConsumerState<ReliefDistributionScreen> createState() =>
      _ReliefDistributionScreenState();
}

class _ReliefDistributionScreenState
    extends ConsumerState<ReliefDistributionScreen> {
  final List<_DistributionRow> _rows = [];
  final List<String> _mockItems = [
    'Mì tôm',
    'Gạo',
    'Nước uống',
    'Chăn',
    'Thuốc y tế'
  ];

  @override
  void initState() {
    super.initState();
    // Add an initial row
    _rows.add(_DistributionRow(
      itemName: _mockItems[0],
      source: SupplySource.communeWarehouse,
      quantity: 1,
    ));
  }

  void _addRow() {
    setState(() {
      _rows.add(_DistributionRow(
        itemName: _mockItems[0],
        source: SupplySource.communeWarehouse,
        quantity: 1,
      ));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
    });
  }

  void _toggleSource(int index) {
    setState(() {
      if (_rows[index].source == SupplySource.communeWarehouse) {
        _rows[index].source = SupplySource.teamBrought;
      } else {
        _rows[index].source = SupplySource.communeWarehouse;
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.statusSafe),
              SizedBox(width: AppSpacing.sm),
              Text('Phát hàng thành công', style: AppTypography.h3),
            ],
          ),
          content: const Text(
            'Đã tạo biên nhận điện tử số BN-2026-0288.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: const Text('ĐÓNG'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMiTom = _rows.any((r) => r.itemName == 'Mì tôm');
    final int countKhoXa =
        _rows.where((r) => r.source == SupplySource.communeWarehouse).length;
    final int countDoiMang =
        _rows.where((r) => r.source == SupplySource.teamBrought).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('← Phát hàng cứu trợ'),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD Hộ nhận
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.base),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    const Icon(Icons.home, color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.householdName,
                            style: AppTypography.h3,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${widget.memberCount} nhân khẩu',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chức năng đổi hộ đang cập nhật'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.infoBlue,
                        textStyle: AppTypography.label,
                      ),
                      child: const Text('[Đổi ▾]'),
                    ),
                  ],
                ),
              ),
            ),

            // DUPLICATE WARNING
            if (hasMiTom)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.warningBanner,
                  borderRadius: AppRadius.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.priorityOrange),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Hộ này đã nhận Mì tôm lúc 14:30 hôm nay — xác nhận phát tiếp?',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'KHÔNG',
                            style: AppTypography.label.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.priorityOrange,
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('CÓ, PHÁT TIẾP'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // SECTION Chọn hàng phát
            Text('Chọn hàng phát', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),

            ...List.generate(_rows.length, (index) {
              final row = _rows[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: row.itemName,
                                isDense: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: _mockItems.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item,
                                        style: AppTypography.bodyLarge),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => row.itemName = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            GestureDetector(
                              onTap: () => _toggleSource(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: row.source == SupplySource.communeWarehouse
                                      ? AppColors.infoBlue.withValues(alpha: 0.1)
                                      : AppColors.statusSafe.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.chip,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      row.source == SupplySource.communeWarehouse
                                          ? Icons.account_balance
                                          : Icons.handshake,
                                      size: 14,
                                      color: row.source == SupplySource.communeWarehouse
                                          ? AppColors.infoBlue
                                          : AppColors.statusSafe,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      row.source == SupplySource.communeWarehouse
                                          ? 'Kho xã'
                                          : 'Đội mang',
                                      style: AppTypography.caption.copyWith(
                                        color: row.source ==
                                                SupplySource.communeWarehouse
                                            ? AppColors.infoBlue
                                            : AppColors.statusSafe,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      QuantityStepper(
                        value: row.quantity,
                        onChanged: (val) {
                          setState(() => row.quantity = val.toInt());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.priorityRed),
                        onPressed: () => _removeRow(index),
                      ),
                    ],
                  ),
                ),
              );
            }),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('Thêm loại hàng khác',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // CARD Biên nhận điện tử
            Text('Biên nhận điện tử', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mã BN:',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                        Text('BN-2026-0288',
                            style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian:',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                        const Text('14:30 - 04/08/2026',
                            style: AppTypography.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hộ nhận:',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                        Text(widget.householdName,
                            style: AppTypography.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Người phát:',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                        const Text('Nguyễn Văn A',
                            style: AppTypography.bodyMedium),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                    Text(
                      '$countKhoXa mặt hàng kho xã (trừ tồn) · $countDoiMang mặt hàng đội tự mang',
                      style: AppTypography.label.copyWith(
                          color: AppColors.primary, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textDisabled,
                                style: BorderStyle.solid,
                              ), // Should be dotted but using solid for standard Container
                              borderRadius: AppRadius.card,
                            ),
                            child: Center(
                              child: Text(
                                'Chữ ký hộ',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textDisabled,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: AppRadius.card,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt,
                                      color: AppColors.textSecondary),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Ảnh bàn giao',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton(
              onPressed: _showSuccessDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('XÁC NHẬN PHÁT — TẠO BIÊN NHẬN'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
