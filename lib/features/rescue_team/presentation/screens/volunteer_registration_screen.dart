import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolunteerRegistrationScreen extends StatefulWidget {
  const VolunteerRegistrationScreen({super.key});

  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _orgCtrl = TextEditingController(text: 'Hội Chữ thập đỏ Hạ Long');
  final _leaderCtrl = TextEditingController(text: 'Nguyễn Văn Hùng');
  final _phoneCtrl = TextEditingController(text: '0912.888.777');
  final _membersCtrl = TextEditingController(text: '15');
  final _arrivalTimeCtrl = TextEditingController(text: '11:30 hôm nay');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orgCtrl.dispose();
    _leaderCtrl.dispose();
    _phoneCtrl.dispose();
    _membersCtrl.dispose();
    _arrivalTimeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Đã nộp đơn đăng ký thành công! Đang chờ Ban chỉ huy Xã duyệt.'),
        backgroundColor: Colors.green.shade800,
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
          'Đăng Ký Đội Cứu Hộ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          indicatorColor: Colors.blue.shade900,
          tabs: const [
            Tab(text: 'Tại chỗ (QR)'),
            Tab(text: 'Từ xa'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('THÔNG TIN ĐỘI', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),

            _buildInputField('Tên đơn vị / tổ chức *', _orgCtrl),
            Row(
              children: [
                Expanded(child: _buildInputField('Trưởng đoàn', _leaderCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField('Số điện thoại', _phoneCtrl)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInputField('Số nhân sự (người)', _membersCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField('Giờ đến dự kiến', _arrivalTimeCtrl)),
              ],
            ),

            const SizedBox(height: 12),
            const Text('Phương tiện', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: const [
                Chip(label: Text('🚚 Xe tải'), backgroundColor: Color(0xFFE8F5E9)),
                Chip(label: Text('🚤 Thuyền')),
                Chip(label: Text('🚑 Xe cứu thương'), backgroundColor: Color(0xFFE8F5E9)),
                Chip(label: Text('🏍️ Xe máy')),
              ],
            ),

            const SizedBox(height: 16),

            // Thẻ Vật tư mang theo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📦 VẬT TƯ MANG THEO', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(4)),
                        child: const Text('MỚI', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSupplyHeader(),
                        _buildSupplyRow('Mì tôm', '50', 'thùng'),
                        _buildSupplyRow('Nước suối', '200', 'chai'),
                        _buildSupplyRow('Áo phao', '20', 'cái'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vật tư này KHÔNG trừ tồn kho xã khi phát — được ghi nguồn "Đội tự mang" trong sổ cứu trợ.',
                    style: TextStyle(fontSize: 9.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('Khu vực muốn hỗ trợ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: const [
                Chip(label: Text('Thôn Pắc Liềng'), backgroundColor: Color(0xFFE3F2FD)),
                Chip(label: Text('Thôn Nà Lầu')),
                Chip(label: Text('Bất kỳ đâu cần'), backgroundColor: Color(0xFFE3F2FD)),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Text(
                '⏳ Chờ Admin duyệt — dự kiến 2-3 phút',
                style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text(
                  'GỬI ĐĂNG KÝ CỨU HỘ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.green.shade100,
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Loại hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
          Expanded(flex: 1, child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
          Expanded(flex: 1, child: Text('Đơn vị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _buildSupplyRow(String name, String qty, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ],
      ),
    );
  }
}
