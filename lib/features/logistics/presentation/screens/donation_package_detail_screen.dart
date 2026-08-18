import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonationPackageDetailScreen extends StatefulWidget {
  const DonationPackageDetailScreen({super.key});

  @override
  State<DonationPackageDetailScreen> createState() => _DonationPackageDetailScreenState();
}

class _DonationPackageDetailScreenState extends State<DonationPackageDetailScreen> {
  // Danh sách các mặt hàng trong gói và trạng thái map
  final List<Map<String, dynamic>> _items = [
    {'name': 'Nước suối', 'qty': '500', 'unit': 'chai', 'mapped': true, 'target': '💧 Nước uống'},
    {'name': 'Thuốc cảm', 'qty': '30', 'unit': 'hộp', 'mapped': true, 'target': '💊 Thuốc y tế'},
    {'name': 'Mì tôm', 'qty': '200', 'unit': 'thùng', 'mapped': false, 'target': ''},
    {'name': 'Quần áo cũ', 'qty': '12', 'unit': 'bao', 'mapped': false, 'target': ''},
  ];

  void _mapItem(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Map mặt hàng: ${_items[index]['name']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn danh mục chuẩn trong kho xã để cộng dồn tồn kho cho mặt hàng này:', style: const TextStyle(fontSize: 11.5)),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const Text('🍞', style: TextStyle(fontSize: 18)),
              title: const Text('Lương khô khẩn cấp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                setState(() {
                  _items[index]['mapped'] = true;
                  _items[index]['target'] = '🍞 Lương khô';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Đã map thành công ${_items[index]['name']} -> Lương khô khẩn cấp và cộng dồn tồn kho!'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _dispatchWholePackage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 Đã xuất phát nguyên gói GCT-2025-0007 cho hộ dân lánh nạn khẩn cấp!'),
        backgroundColor: Colors.orange,
      ),
    );
    context.pop();
  }

  void _completeClassification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Đã hoàn tất phân loại gói GCT-2025-0007! Toàn bộ hàng đã cộng vào kho chung.'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final mappedCount = _items.where((i) => i['mapped'] == true).length;

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
          'GCT-2025-0007',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Đã nhận',
              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hộp đen thông tin gói cứu trợ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GCT-2025-0007',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Nhóm thiện nguyện Hạ Long · 0988 123 456',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nhận 03/08/2026 14:20 bởi Trần Văn Nam',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Chỉ báo trạng thái tiến trình (3 bước)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStepIndicator('Đã nhận', true, true),
                        _buildStepDivider(),
                        _buildStepIndicator('Đã phân loại', false, mappedCount == _items.length),
                        _buildStepDivider(),
                        _buildStepIndicator('Đã phát', false, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Banner xanh lá
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Phân loại: map từng dòng vào danh mục chuẩn. Dòng map được -> cộng tồn kho. Dòng không map -> giữ dạng "hàng khác" theo mã gói này.',
                            style: TextStyle(color: Colors.green.shade900, fontSize: 10, height: 1.4, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. NỘI DUNG GÓI
                  Text(
                    'NỘI DUNG GÓI — $mappedCount/${_items.length} ĐÃ MAP',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (ctx, idx) {
                      final item = _items[idx];
                      final isMapped = item['mapped'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isMapped ? Colors.grey.shade200 : Colors.orange.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['name']} — ${item['qty']} ${item['unit']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      isMapped ? Icons.check_circle : Icons.warning_amber_rounded,
                                      size: 13,
                                      color: isMapped ? Colors.green : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isMapped
                                          ? 'đã map -> ${item['target']} - đã cộng tồn kho'
                                          : 'chưa map — giữ theo mã gói',
                                      style: TextStyle(
                                        color: isMapped ? Colors.green.shade800 : Colors.orange.shade800,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isMapped)
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _mapItem(idx),
                                  child: const Text('Map →', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 5. LỊCH SỬ PHÁT TỪ GÓI NÀY
                  const Text(
                    'LỊCH SỬ PHÁT TỪ GÓI NÀY',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildHistoryRow('15:10', 'Hộ Nguyễn Văn A', '1 gói nguyên (chưa phân loại)'),
                        const Divider(height: 16),
                        _buildHistoryRow('15:35', 'Hộ Trần Thị B', '2 thùng mì tôm'),
                        const Divider(height: 16),
                        _buildHistoryRow('16:02', 'Đội MTQ Bình Liêu', '100 chai nước'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2 Nút dưới chân
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade900,
                      side: BorderSide(color: Colors.orange.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _dispatchWholePackage,
                    child: const Text('📥 Phát nguyên gói', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _completeClassification,
                    child: const Text('✓ Hoàn tất phân loại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? Colors.green.shade700 : (isActive ? Colors.blue.shade800 : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    label == 'Đã nhận' ? '1' : (label == 'Đã phân loại' ? '2' : '3'),
                    style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDone || isActive ? Colors.black87 : Colors.grey,
            fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 40,
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildHistoryRow(String time, String recipient, String detail) {
    return Row(
      children: [
        Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            recipient,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
        ),
        Text(detail, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
      ],
    );
  }
}
