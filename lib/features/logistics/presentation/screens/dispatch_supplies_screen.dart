import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DispatchSuppliesScreen extends StatefulWidget {
  const DispatchSuppliesScreen({super.key});

  @override
  State<DispatchSuppliesScreen> createState() => _DispatchSuppliesScreenState();
}

class _DispatchSuppliesScreenState extends State<DispatchSuppliesScreen> {
  String _selectedTeam = 'PacLieng'; // 'PacLieng' hoặc 'MTQ'
  
  // Số lượng xuất
  int _aoPhaoQty = 10;
  int _nuocUongQty = 100;
  int _luongKhoQty = 30;

  bool _isSigned = false;
  bool _hasPhoto = false;

  void _showSignatureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✍️ Ký xác nhận bàn giao', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
              '[ Vẽ chữ ký điện tử của trưởng đội vào đây ]',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
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

  void _takePhoto() {
    setState(() => _hasPhoto = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📷 Đã chụp ảnh bàn giao vật tư trực tiếp tại kho!')),
    );
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã xuất kho thành công! Đã tạo phiếu PX-2025-0013.'),
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
          'Xuất kho cho đội',
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
                  // 1. CHỌN ĐỘI NHẬN
                  const Text(
                    '1. CHỌN ĐỘI NHẬN',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  
                  // Đội 1: Dân quân Pắc Liềng
                  _buildTeamSelectorCard(
                    id: 'PacLieng',
                    name: 'Đội Dân quân Pắc Liềng',
                    subtitle: '8 người · Thôn 1 · cách kho 1.4km',
                    statusText: 'Đang nhiệm vụ',
                    statusBg: Colors.blue.shade100,
                    statusFg: Colors.blue.shade900,
                  ),
                  const SizedBox(height: 8),

                  // Đội 2: Cứu hộ MTQ Bình Liêu
                  _buildTeamSelectorCard(
                    id: 'MTQ',
                    name: 'Đội Cứu hộ MTQ Bình Liêu',
                    subtitle: '12 người · Thôn 2-3 · tại kho',
                    statusText: 'Sẵn sàng',
                    statusBg: Colors.green.shade100,
                    statusFg: Colors.green.shade900,
                  ),
                  const SizedBox(height: 16),

                  // 2. CHỌN HÀNG XUẤT
                  const Text(
                    '2. CHỌN HÀNG XUẤT',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildQuantitySelector('🦺 Áo phao', 'Tồn: 15 cái', _aoPhaoQty, (v) {
                    setState(() => _aoPhaoQty = v);
                  }),
                  _buildQuantitySelector('💧 Nước uống', 'Tồn: 340 chai', _nuocUongQty, (v) {
                    setState(() => _nuocUongQty = v);
                  }),
                  _buildQuantitySelector('🍞 Lương khô', 'Tồn: 120 gói', _luongKhoQty, (v) {
                    setState(() => _luongKhoQty = v);
                  }),
                  
                  // Cảnh báo ngưỡng tồn kho
                  if (_aoPhaoQty >= 10)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade800, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Xuất $_aoPhaoQty/15 áo phao — tồn còn ${15 - _aoPhaoQty}, dưới ngưỡng cảnh báo (20)',
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 3. PHIẾU XUẤT
                  const Text(
                    '3. PHIẾU XUẤT',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'PX-2025-0013',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '03/08/2026 09:55',
                              style: TextStyle(color: Colors.grey, fontSize: 10.5),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildInvoiceRow('Người xuất', 'Trần Văn Nam (Admin xã)'),
                        const SizedBox(height: 6),
                        _buildInvoiceRow('Người nhận', _selectedTeam == 'PacLieng' ? 'Lý Văn Thắng — trưởng đội' : 'Nguyễn Văn C — trưởng đoàn'),
                        const SizedBox(height: 6),
                        _buildInvoiceRow('Tổng số dòng', '3 mặt hàng · ${_aoPhaoQty + _nuocUongQty + _luongKhoQty} đơn vị'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút ký nhận & ảnh bàn giao
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isSigned ? Colors.green.shade800 : Colors.black87,
                            side: BorderSide(color: _isSigned ? Colors.green : Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: Icon(_isSigned ? Icons.check_circle : Icons.edit, size: 16, color: _isSigned ? Colors.green : Colors.black87),
                          label: Text(_isSigned ? 'Đã ký nhận' : 'Ký nhận', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _showSignatureDialog,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _hasPhoto ? Colors.green.shade800 : Colors.black87,
                            side: BorderSide(color: _hasPhoto ? Colors.green : Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: Icon(_hasPhoto ? Icons.check_circle : Icons.camera_alt, size: 16, color: _hasPhoto ? Colors.green : Colors.black87),
                          label: Text(_hasPhoto ? 'Đã chụp ảnh' : 'Ảnh bàn giao', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _takePhoto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút XÁC NHẬN XUẤT KHO dưới cùng
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
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: const Text(
                  'XÁC NHẬN XUẤT KHO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSelectorCard({
    required String id,
    required String name,
    required String subtitle,
    required String statusText,
    required Color statusBg,
    required Color statusFg,
  }) {
    final isSelected = _selectedTeam == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTeam = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusFg, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: 2),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(String title, String stock, int currentVal, ValueChanged<int> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              Text(stock, style: TextStyle(color: Colors.red.shade800, fontSize: 10.5, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey),
                onPressed: () {
                  if (currentVal > 0) onChanged(currentVal - 1);
                },
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$currentVal',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 22, color: Colors.blue),
                onPressed: () {
                  onChanged(currentVal + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
