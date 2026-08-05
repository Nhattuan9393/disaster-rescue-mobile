import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({super.key});

  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  // Tab 1: Standard
  String? _selectedItemId;
  final _standardQtyController = TextEditingController();

  // Tab 2: Package
  final _donorNameController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final List<PackageLine> _packageLines = [];

  final _rawNameController = TextEditingController();
  final _rawQtyController = TextEditingController();
  String _rawUnit = 'thùng';

  @override
  void dispose() {
    _standardQtyController.dispose();
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _rawNameController.dispose();
    _rawQtyController.dispose();
    super.dispose();
  }

  void _addRawLine() {
    final name = _rawNameController.text.trim();
    final qty = double.tryParse(_rawQtyController.text) ?? 0;
    if (name.isEmpty || qty <= 0) return;

    setState(() {
      _packageLines.add(PackageLine(rawName: name, quantity: qty, unit: _rawUnit, mappedItemId: null));
      _rawNameController.clear();
      _rawQtyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reliefProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Nhập Kho Cứu Trợ'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Nhập Kho Chuẩn'),
              Tab(text: 'Nhập Gói Cứu Trợ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStandardTab(state.items),
            _buildPackageTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardTab(List<ReliefItem> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Chọn mặt hàng nhập kho:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedItemId,
            hint: const Text('Chọn mặt hàng'),
            items: items.map((item) => DropdownMenuItem(
              value: item.id,
              child: Text('${item.name} (${item.unit})'),
            )).toList(),
            onChanged: (val) => setState(() => _selectedItemId = val),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: AppSpacing.md),

          const Text('Số lượng nhập:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _standardQtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'VD: 100',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(_standardQtyController.text) ?? 0;
              if (_selectedItemId == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn mặt hàng và nhập số lượng hợp lệ.')),
                );
                return;
              }
              ref.read(reliefProvider.notifier).receiveItemStock(_selectedItemId!, qty);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật tồn kho!'), backgroundColor: AppColors.statusSafe),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSafe,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: const Text('XÁC NHẬN NHẬP KHO'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Thông tin nhà tài trợ:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _donorNameController,
            decoration: const InputDecoration(labelText: 'Tên đoàn từ thiện / Nhà hảo tâm', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _donorPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Thêm đồ thô vào gói (Tầng 2):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _rawNameController,
                  decoration: const InputDecoration(hintText: 'Tên món đồ (VD: Mì tôm)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _rawQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'SL', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _rawUnit,
                items: const [
                  DropdownMenuItem(value: 'thùng', child: Text('thùng')),
                  DropdownMenuItem(value: 'bao', child: Text('bao')),
                  DropdownMenuItem(value: 'cái', child: Text('cái')),
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                ],
                onChanged: (val) => setState(() => _rawUnit = val!),
              ),
              IconButton(
                onPressed: _addRawLine,
                icon: const Icon(Icons.add_circle_rounded, color: AppColors.statusSafe, size: 32),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (_packageLines.isNotEmpty) ...[
            const Text('Danh sách đồ đã thêm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: _packageLines.map<Widget>((line) => ListTile(
                      dense: true,
                      title: Text(line.rawName),
                      trailing: Text('${line.quantity.toInt()} ${line.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          ElevatedButton(
            onPressed: () {
              final name = _donorNameController.text.trim();
              final phone = _donorPhoneController.text.trim();
              if (name.isEmpty || _packageLines.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên đoàn và thêm ít nhất 1 món đồ.')),
                );
                return;
              }

              ref.read(reliefProvider.notifier).receiveReliefPackage(name, phone, _packageLines);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo Gói Cứu Trợ khẩn cấp!'), backgroundColor: AppColors.statusSafe),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSafe,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: const Text('TIẾP NHẬN GÓI CỨU TRỢ'),
          ),
        ],
      ),
    );
  }
}
