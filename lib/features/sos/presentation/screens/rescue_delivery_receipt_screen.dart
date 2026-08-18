import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescueDeliveryReceiptScreen extends StatefulWidget {
  final String sosId;
  const RescueDeliveryReceiptScreen({super.key, required this.sosId});

  @override
  State<RescueDeliveryReceiptScreen> createState() => _RescueDeliveryReceiptScreenState();
}

class _RescueDeliveryReceiptScreenState extends State<RescueDeliveryReceiptScreen> {
  int _aoPhao = 2;
  int _luongKhong = 5;
  int _nuocSach = 12;
  int _tuiThuoc = 1;

  bool _isSigned = false;
  bool _hasPhoto = false;
  bool _committed = true;

  void _showSignaturePad() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✍️ Ký xác nhận bàn giao cứu trợ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Container(
          height: 150,
          width: double.maxFinite,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '[ Vẽ chữ ký điện tử của chủ hộ vào đây ]',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () {
              setState(() => _isSigned = true);
              Navigator.pop(ctx);
            },
            child: const Text('Đã ký', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _takeDeliveryPhoto() {
    setState(() => _hasPhoto = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📷 Đã chụp ảnh bàn giao vật tư trực tiếp tại thực địa!')),
    );
  }

  void _submitDelivery() {
    if (!_isSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng yêu cầu chủ hộ ký nhận chữ ký điện tử!'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã ghi nhận bàn giao cứu trợ thành công! Trừ tồn kho tương ứng.'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
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
        title: const Text(
          'Phát hàng cứu trợ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nhãn SOS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '📍 Tiếp tế cho SOS #${widget.sosId.substring(0, 5)} — Hộ Nguyễn Văn Tuấn',
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BẢNG LƯỢNG HÀNG BÀN GIAO
                  const Text(
                    'BẢNG LƯỢNG HÀNG BÀN GIAO',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),

                  _buildItemSelector('🦺 Áo phao cứu sinh (cái)', _aoPhao, (v) => setState(() => _aoPhao = v)),
                  _buildItemSelector('🍞 Lương khô khẩn cấp (thùng)', _luongKhong, (v) => setState(() => _luongKhong = v)),
                  _buildItemSelector('💧 Nước sạch đóng chai (chai)', _nuocSach, (v) => setState(() => _nuocSach = v)),
                  _buildItemSelector('💊 Túi thuốc y tế (túi)', _tuiThuoc, (v) => setState(() => _tuiThuoc = v)),

                  const SizedBox(height: 16),

                  // KHUNG KÝ XÁC NHẬN
                  const Text(
                    'KÝ XÁC NHẬN (ĐẠI DIỆN HỘ NHẬN)',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  
                  GestureDetector(
                    onTap: _showSignaturePad,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _isSigned ? Colors.green.shade400 : Colors.grey.shade300, width: 1.2),
                      ),
                      child: _isSigned
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Đại diện hộ đã ký xác nhận',
                                    style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text(
                                '✍️ Nhấp để vẽ chữ ký xác nhận của đại diện hộ',
                                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nút ảnh chụp bàn giao thực địa
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _hasPhoto ? Colors.green.shade800 : Colors.black87,
                        side: BorderSide(color: _hasPhoto ? Colors.green : Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(_hasPhoto ? Icons.check_circle : Icons.camera_alt, size: 18, color: _hasPhoto ? Colors.green : Colors.black87),
                      label: Text(_hasPhoto ? 'Đã chụp ảnh bàn giao' : '📷 Chụp ảnh bàn giao thực địa', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: _takeDeliveryPhoto,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cam kết checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _committed,
                        activeColor: Colors.green.shade800,
                        onChanged: (val) => setState(() => _committed = val ?? true),
                      ),
                      const Expanded(
                        child: Text(
                          'Cam kết đã phát đủ và đúng đối tượng thụ hưởng.',
                          style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút Xác nhận dưới cùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _submitDelivery,
                child: const Text(
                  'XÁC NHẬN BÀN GIAO & PHÁT HÀNG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSelector(String label, int val, ValueChanged<int> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.black87)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                onPressed: () {
                  if (val > 0) onChanged(val - 1);
                },
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text('$val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 20, color: Colors.green),
                onPressed: () => onChanged(val + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
