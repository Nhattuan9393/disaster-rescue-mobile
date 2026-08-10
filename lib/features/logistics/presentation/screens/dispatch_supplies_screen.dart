import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DispatchSuppliesScreen extends StatefulWidget {
  final bool isImportMode;
  const DispatchSuppliesScreen({super.key, this.isImportMode = false});

  @override
  State<DispatchSuppliesScreen> createState() => _DispatchSuppliesScreenState();
}

class _DispatchSuppliesScreenState extends State<DispatchSuppliesScreen> {
  String _selectedPoint = 'Trường TH Bình Liêu (Đang có 185 người)';
  String _selectedTeam = 'Đội Dân quân Thôn Pắc Liềng';

  final _lifeJacketCtrl = TextEditingController(text: '20');
  final _blanketCtrl = TextEditingController(text: '50');
  final _waterCtrl = TextEditingController(text: '100');
  final _foodCtrl = TextEditingController(text: '30');

  @override
  void dispose() {
    _lifeJacketCtrl.dispose();
    _blanketCtrl.dispose();
    _waterCtrl.dispose();
    _foodCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isImportMode
              ? '✅ Đã ghi nhận nhập kho vật tư thành công!'
              : '📦 Đã duyệt lệnh xuất kho tiếp tế cho ${_selectedPoint.split(" (")[0]}!',
        ),
        backgroundColor: Colors.green.shade800,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isImportMode ? '📥 Nhập Kho Cứu Trợ ủng Hộ' : '📦 Xuất Kho Tiếp Tế Điểm Sơ Tán';

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
          titleText,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Địa điểm tiếp nhận
            const Text('ĐỊA ĐIỂM TIẾP NHẬN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPoint,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'Trường TH Bình Liêu (Đang có 185 người)', child: Text('🏫 Trường TH Bình Liêu (185 người)')),
                DropdownMenuItem(value: 'Nhà văn hóa Pắc Liềng (Đang có 95 người)', child: Text('🏫 Nhà văn hóa Pắc Liềng (95 người)')),
                DropdownMenuItem(value: 'Trạm Y Tế Xã (Đang có 40 người)', child: Text('🏥 Trạm Y Tế Xã (40 người)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedPoint = val);
              },
            ),
            const SizedBox(height: 16),

            // 2. Danh mục số lượng vật tư
            const Text('DANH MỤC VẬT TƯ TIẾP TẾ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),

            _buildQuantityInput('🦺 Áo phao cứu sinh (cái)', _lifeJacketCtrl),
            _buildQuantityInput('🛏️ Chăn ấm (cái)', _blanketCtrl),
            _buildQuantityInput('💧 Nước sạch đóng chai (chai)', _waterCtrl),
            _buildQuantityInput('🍞 Lương khô (thùng)', _foodCtrl),

            const SizedBox(height: 16),

            // 3. Đội vận chuyển
            if (!widget.isImportMode) ...[
              const Text('ĐỘI VẬN CHUYỂN GIAO HÀNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedTeam,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Đội Dân quân Thôn Pắc Liềng', child: Text('🛶 Đội Dân quân Thôn Pắc Liềng')),
                  DropdownMenuItem(value: 'Tổ Xung kích Nà Lầu', child: Text('🛶 Tổ Xung kích Nà Lầu')),
                  DropdownMenuItem(value: 'CLB Tình Nguyện Quảng Ninh', child: Text('🚐 CLB Tình Nguyện Quảng Ninh')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTeam = val);
                },
              ),
              const SizedBox(height: 24),
            ],

            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: Text(
                  widget.isImportMode ? '📥 XÁC NHẬN NHẬP KHO' : '📦 DUYỆT LỆNH XUẤT KHO TIẾP TẾ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
