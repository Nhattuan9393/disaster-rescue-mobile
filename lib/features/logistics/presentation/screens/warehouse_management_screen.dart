import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryItem {
  final String id;
  final String icon;
  final String name;
  final int currentStock;
  final int standingStock; // biên chế
  final int donatedStock; // ủng hộ
  final int maxCapacity;
  final String unit;
  final bool isLowStock;

  const InventoryItem({
    required this.id,
    required this.icon,
    required this.name,
    required this.currentStock,
    required this.standingStock,
    required this.donatedStock,
    required this.maxCapacity,
    required this.unit,
    required this.isLowStock,
  });
}

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  State<WarehouseManagementScreen> createState() => _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  final List<InventoryItem> _inventory = const [
    InventoryItem(id: 'inv_01', icon: '🦺', name: 'Áo phao cứu sinh', currentStock: 15, standingStock: 10, donatedStock: 5, maxCapacity: 100, unit: 'cái', isLowStock: true),
    InventoryItem(id: 'inv_02', icon: '🛏️', name: 'Chăn ấm mùa đông', currentStock: 120, standingStock: 100, donatedStock: 20, maxCapacity: 150, unit: 'cái', isLowStock: false),
    InventoryItem(id: 'inv_03', icon: '💧', name: 'Nước sạch đóng chai', currentStock: 240, standingStock: 140, donatedStock: 100, maxCapacity: 300, unit: 'chai', isLowStock: false),
    InventoryItem(id: 'inv_04', icon: '🍞', name: 'Lương khô khẩn cấp', currentStock: 30, standingStock: 20, donatedStock: 10, maxCapacity: 200, unit: 'thùng', isLowStock: true),
    InventoryItem(id: 'inv_05', icon: '💊', name: 'Túi thuốc y tế sơ cứu', currentStock: 45, standingStock: 40, donatedStock: 5, maxCapacity: 50, unit: 'túi', isLowStock: false),
  ];

  String _sourceFilter = 'Tất cả vật tư';

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _inventory.where((i) => i.isLowStock).length;

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
          'Kho Cứu Trợ Xã',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // 1. Thẻ Cảnh báo tồn kho thấp
          if (lowStockCount > 0)
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ $lowStockCount mặt hàng sắp hết — cần bổ sung gấp',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Áo phao và Lương khô còn dưới 20% dung lượng tồn kho.',
                          style: TextStyle(color: Colors.black87, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Thanh lọc theo nguồn vật tư chuẩn Ảnh 1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: Row(
              children: ['Tất cả vật tư', 'Biên chế xã', 'Ủng hộ từ thiện'].map((src) {
                final isSel = _sourceFilter == src;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      selected: isSel,
                      label: Text(src, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.blue.shade900 : Colors.black87)),
                      selectedColor: Colors.blue.shade100,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        if (val) setState(() => _sourceFilter = src);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // 2. Danh sách các mặt hàng tồn kho
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                
                int displayStock = item.currentStock;
                int maxCap = item.maxCapacity;
                if (_sourceFilter == 'Biên chế xã') {
                  displayStock = item.standingStock;
                } else if (_sourceFilter == 'Ủng hộ từ thiện') {
                  displayStock = item.donatedStock;
                }
                
                final percent = displayStock / maxCap;
                final isLow = _sourceFilter == 'Tất cả vật tư' ? item.isLowStock : (displayStock / maxCap < 0.2);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isLow ? Colors.red.shade300 : Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(item.icon, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
                                      ),
                                      if (_sourceFilter == 'Tất cả vật tư')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '(${item.standingStock} biên chế · ${item.donatedStock} ủng hộ)',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$displayStock',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isLow ? Colors.red.shade700 : Colors.green.shade800,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / $maxCap ${item.unit}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),


                      // Thanh tiến trình dung lượng
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.isLowStock ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. Nút Thao tác Xuất / Nhập Kho
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/dispatch-supplies'),
                    icon: const Icon(Icons.outbox, color: Colors.white, size: 18),
                    label: const Text('📦 Xuất kho tiếp tế', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue.shade900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/receive-donations'),
                    icon: Icon(Icons.move_to_inbox, color: Colors.blue.shade900, size: 18),
                    label: Text('📥 Nhập kho ủng hộ', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

