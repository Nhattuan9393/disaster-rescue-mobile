import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/evacuation_provider.dart';
import '../../domain/evacuation_point_model.dart';

class EvacuationPointDetailScreen extends ConsumerStatefulWidget {
  final EvacuationPointModel point;

  const EvacuationPointDetailScreen({
    super.key,
    required this.point,
  });

  @override
  ConsumerState<EvacuationPointDetailScreen> createState() => _EvacuationPointDetailScreenState();
}

class _EvacuationPointDetailScreenState extends ConsumerState<EvacuationPointDetailScreen> {
  late int _currentCount;
  late String _status;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.point.currentCount;
    _status = widget.point.status;
  }

  void _saveUpdates() async {
    final repo = ref.read(evacuationRepositoryProvider);
    final updatedPoint = widget.point.copyWith(
      currentCount: _currentCount,
      status: _status,
    );

    await repo.updateEvacuationPoint(updatedPoint);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã lưu cập nhật tình trạng điểm sơ tán!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.point.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SỐ NGƯỜI HIỆN TẠI (+ / -)
            const Text(
              'SỐ NGƯỜI HIỆN TẠI',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentCount > 0) {
                        setState(() => _currentCount--);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('−', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_currentCount / ${widget.point.capacity}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green.shade700),
                      ),
                      Text(
                        'còn ${widget.point.capacity - _currentCount} chỗ',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _currentCount++);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. TRẠNG THÁI ĐIỂM
            const Text(
              'TRẠNG THÁI ĐIỂM SƠ TÁN',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusChip('open', 'Mở', Colors.green),
                _buildStatusChip('nearly_full', 'Sắp đầy', Colors.orange),
                _buildStatusChip('full', 'Đã đầy', Colors.red),
                _buildStatusChip('closed', 'Đóng — hỏng', Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // 3. CHECK-IN HỘ DÂN (Nâng 95% độ tin cậy an toàn)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade600, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ CHECK-IN HỘ DÂN — tự đặt trạng thái An toàn (95% Tin cậy)',
                    style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Giải bài toán "hết pin / mất điện thoại" — hộ được xác nhận an toàn dù app không hoạt động.',
                    style: TextStyle(color: Colors.black54, fontSize: 9.5, height: 1.4),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 16, color: Colors.white),
                          label: const Text('Quét QR app hộ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          onPressed: () async {
                            final repo = ref.read(evacuationRepositoryProvider);
                            await repo.checkInHousehold(widget.point.id, 'household_my_family');
                            setState(() {
                              _currentCount += 5;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ Đã check-in hộ Nguyễn Văn A (5 người)!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(color: Colors.green.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Tìm theo tên/SĐT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Danh sách mẫu đã checkin
                  _buildCheckinRow('✓ Nguyễn Văn A — Pắc Liềng', '5/5 người · check-in 09:52'),
                  const SizedBox(height: 4),
                  _buildCheckinRow('✓ Hoàng Thị D — Khe Tiền', '2/2 người · check-in 09:40'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. VẬT TƯ TẠI ĐIỂM
            const Text(
              'VẬT TƯ TẠI ĐIỂM SƠ TÁN',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildSupplyItemRow('🛏️ Chăn', '30 cái', false),
                  const Divider(height: 1),
                  _buildSupplyItemRow('💧 Nước', '120 chai', false),
                  const Divider(height: 1),
                  _buildSupplyItemRow('🍞 Lương khô', '8 gói ⚠️ sắp hết', true),
                  const Divider(height: 1),
                  _buildSupplyItemRow('💊 Thuốc', '15 hộp', false),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.inventory_2, size: 18),
                label: const Text('📦 Yêu cầu bổ sung vật tư từ kho xã', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📦 Đã gửi yêu cầu tiếp tế Lương khô tới kho xã Bình Liêu')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 5. Thẻ người phụ trách
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 16, child: const Text('👤', style: TextStyle(fontSize: 14))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phụ trách: ${widget.point.inChargeName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                        Text('${widget.point.inChargePhone} — Đội cứu hộ gọi trước khi chở người đến', style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Lưu cập nhật
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _saveUpdates,
                child: const Text('LƯU CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusKey, String label, MaterialColor color) {
    final isSelected = _status == statusKey;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: color.shade100,
      labelStyle: TextStyle(
        color: isSelected ? color.shade900 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (val) {
        if (val) setState(() => _status = statusKey);
      },
    );
  }

  Widget _buildCheckinRow(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSupplyItemRow(String title, String count, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
