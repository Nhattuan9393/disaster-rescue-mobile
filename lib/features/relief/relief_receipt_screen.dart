import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';
import 'package:disaster_rescue/features/household_registry/providers/household_registry_provider.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

class ReliefReceiptScreen extends ConsumerStatefulWidget {
  const ReliefReceiptScreen({super.key});

  @override
  ConsumerState<ReliefReceiptScreen> createState() => _ReliefReceiptScreenState();
}

class _ReceiveItemEntry {
  final String itemId;
  double qty;

  _ReceiveItemEntry(this.itemId, this.qty);
}

class _ReliefReceiptScreenState extends ConsumerState<ReliefReceiptScreen> {
  String? _selectedHouseholdId;
  SupplySource _source = SupplySource.communeWarehouse;
  String? _packageCode;
  final List<_ReceiveItemEntry> _itemsToDistribute = [];
  final _noteController = TextEditingController();

  String? _newItemId;
  final _newQtyController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _newQtyController.dispose();
    super.dispose();
  }

  void _addItemEntry() {
    final qty = double.tryParse(_newQtyController.text) ?? 0;
    if (_newItemId == null || qty <= 0) return;

    // Tránh trùng lặp trong danh sách tạm thời
    final exists = _itemsToDistribute.any((e) => e.itemId == _newItemId);
    if (exists) return;

    setState(() {
      _itemsToDistribute.add(_ReceiveItemEntry(_newItemId!, qty));
      _newQtyController.clear();
      _newItemId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reliefState = ref.watch(reliefProvider);
    final registryState = ref.watch(householdRegistryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lập Biên Nhận Cứu Trợ'),
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
            const Text('Hộ dân nhận cứu trợ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedHouseholdId,
              hint: const Text('Chọn hộ dân'),
              items: registryState.households.map((h) => DropdownMenuItem(
                value: h.id,
                child: Text('${h.ownerName} (${h.address})'),
              )).toList(),
              onChanged: (val) => setState(() => _selectedHouseholdId = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.md),

            const Text('Nguồn cấp phát (QĐ 2.4):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<SupplySource>(
              value: _source,
              items: const [
                DropdownMenuItem(value: SupplySource.communeWarehouse, child: Text('Kho xã (Trừ tồn kho)')),
                DropdownMenuItem(value: SupplySource.teamStanding, child: Text('Đội thường trực cấp phát')),
                DropdownMenuItem(value: SupplySource.teamBrought, child: Text('Đoàn thiện nguyện tự mang phát')),
                DropdownMenuItem(value: SupplySource.packageDirect, child: Text('Phát nguyên Gói Cứu Trợ')),
              ],
              onChanged: (val) => setState(() => _source = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_source == SupplySource.packageDirect) ...[
              const Text('Chọn gói cứu trợ nguyên đai:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _packageCode,
                hint: const Text('Chọn gói cứu trợ'),
                items: reliefState.packages.map((pkg) => DropdownMenuItem(
                  value: pkg.code,
                  child: Text('${pkg.code} - ${pkg.donorName}'),
                )).toList(),
                onChanged: (val) => setState(() => _packageCode = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (_source != SupplySource.packageDirect) ...[
              const Text('Thêm mặt hàng phát:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _newItemId,
                      hint: const Text('Chọn món'),
                      items: reliefState.items.map((item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      )).toList(),
                      onChanged: (val) => setState(() => _newItemId = val),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _newQtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'SL', border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(
                    onPressed: _addItemEntry,
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.statusSafe, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (_itemsToDistribute.isNotEmpty && _source != SupplySource.packageDirect) ...[
              const Text('Danh sách đồ cấp phát:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: _itemsToDistribute.map<Widget>((entry) {
                    final item = reliefState.items.firstWhere((i) => i.id == entry.itemId);
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      trailing: Text('${entry.qty.toInt()} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            const Text('Ghi chú phiếu:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'VD: Phát trực tiếp tại UBND xã',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: () {
                if (_selectedHouseholdId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn hộ dân nhận hàng.')),
                  );
                  return;
                }

                if (_source == SupplySource.packageDirect && _packageCode == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn Gói Cứu Trợ phát trực tiếp.')),
                  );
                  return;
                }

                if (_source != SupplySource.packageDirect && _itemsToDistribute.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng thêm ít nhất một mặt hàng.')),
                  );
                  return;
                }

                // Chuyển danh sách tạm thời sang Map
                final Map<String, double> finalItems = {};
                for (var entry in _itemsToDistribute) {
                  finalItems[entry.itemId] = entry.qty;
                }

                final receipt = ReliefReceipt(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  householdId: _selectedHouseholdId!,
                  distributedAt: DateTime.now(),
                  distributedBy: 'Cán bộ Xã',
                  source: _source,
                  items: finalItems,
                  packageCode: _source == SupplySource.packageDirect ? _packageCode : null,
                  note: _noteController.text.trim(),
                );

                ref.read(reliefProvider.notifier).createReceipt(receipt);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lập Biên Nhận phát hàng thành công!'), backgroundColor: AppColors.statusSafe),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSafe,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: const Text('LẬP BIÊN NHẬN & PHÁT HÀNG'),
            ),
          ],
        ),
      ),
    );
  }
}
