import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterHouseholdScreen extends StatefulWidget {
  const RegisterHouseholdScreen({super.key});

  @override
  State<RegisterHouseholdScreen> createState() => _RegisterHouseholdScreenState();
}

class _RegisterHouseholdScreenState extends State<RegisterHouseholdScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villageCtrl = TextEditingController(text: 'Thôn Pắc Liềng');
  final _membersCtrl = TextEditingController(text: '4');

  String _houseType = 'Cấp 4 — Trũng thấp';
  bool _hasElderly = true;
  bool _hasChildren = false;
  bool _hasDisabled = false;
  bool _hasPregnant = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _villageCtrl.dispose();
    _membersCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Đăng Ký Thành Công', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Đã gửi thông tin khai báo Hộ dân thành công!\n\nVui lòng liên hệ Trưởng thôn hoặc Cán bộ Xã Bình Liêu để xác minh và kích hoạt tài khoản của bạn.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('ĐÃ HIỂU — QUA TRANG ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
        ],
      ),
    );
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: const Text(
          'Đăng Ký Hộ Dân Mới',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade900, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Khai báo đúng thông tin nhân khẩu và loại nhà giúp Ban chỉ huy Xã tính điểm ưu tiên cứu hộ khi có bão lũ.',
                      style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField('Họ và tên chủ hộ *', _nameCtrl, 'VD: Nguyễn Văn A'),
            _buildInputField('Số điện thoại liên lạc chính *', _phoneCtrl, 'VD: 0912.345.678'),
            Row(
              children: [
                Expanded(child: _buildInputField('Thôn / Bản *', _villageCtrl, 'VD: Thôn Pắc Liềng')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField('Số nhân khẩu *', _membersCtrl, 'VD: 4')),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Loại nhà và nguy cơ ngập *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🏚️ Cấp 4 — Trũng thấp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: _houseType == 'Cấp 4 — Trũng thấp',
                    selectedColor: Colors.orange.shade100,
                    onSelected: (val) => setState(() => _houseType = 'Cấp 4 — Trũng thấp'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🏢 Nhà nhiều tầng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: _houseType == 'Nhà nhiều tầng',
                    selectedColor: Colors.blue.shade100,
                    onSelected: (val) => setState(() => _houseType = 'Nhà nhiều tầng'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text('ĐỐI TƯỢNG ƯU TIÊN YẾU THẾ TRONG GIA ĐÌNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('👴 Có người già (>70 tuổi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    value: _hasElderly,
                    activeColor: const Color(0xFFD32F2F),
                    onChanged: (val) => setState(() => _hasElderly = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('👶 Có trẻ em nhỏ (<6 tuổi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    value: _hasChildren,
                    activeColor: const Color(0xFFD32F2F),
                    onChanged: (val) => setState(() => _hasChildren = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('♿ Có người khuyết tật / Tai biến', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    value: _hasDisabled,
                    activeColor: const Color(0xFFD32F2F),
                    onChanged: (val) => setState(() => _hasDisabled = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('🤰 Có phụ nữ mang thai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    value: _hasPregnant,
                    activeColor: const Color(0xFFD32F2F),
                    onChanged: (val) => setState(() => _hasPregnant = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text(
                  '✓ GỬI THÔNG TIN ĐĂNG KÝ HỘ DÂN',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
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
              hintText: hint,
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
}
