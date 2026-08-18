import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescueTeamDetailAdminScreen extends StatefulWidget {
  const RescueTeamDetailAdminScreen({super.key});

  @override
  State<RescueTeamDetailAdminScreen> createState() => _RescueTeamDetailAdminScreenState();
}

class _RescueTeamDetailAdminScreenState extends State<RescueTeamDetailAdminScreen> {
  String _selectedType = 'Dân quân';
  final _leaderController = TextEditingController(text: 'Lý Văn Thắng');
  final _phoneController = TextEditingController(text: '0912 345 678');

  @override
  void dispose() {
    _leaderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveTeam() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Đã cập nhật và lưu thông tin Đội Dân quân Pắc Liềng!'),
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
          'Đội Dân quân Pắc Liềng',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: _saveTeam,
            child: const Text(
              'Lưu',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
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
                  // 1. Chọn loại đội
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Dân quân', 'Tổ xung kích', 'Y tế', 'Đường thuỷ'].map((type) {
                        final isSel = _selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.blue.shade800 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? Colors.blue.shade800 : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Tên và SĐT
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _leaderController,
                          decoration: InputDecoration(
                            labelText: 'Trưởng đội / Liên hệ',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. THÀNH VIÊN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'THÀNH VIÊN (8)',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('➕ Thêm thành viên vào đội')),
                          );
                        },
                        child: const Text(
                          '+ Thêm',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildMemberRow('Lý Văn Thắng — trưởng đội', '0912 345 678'),
                        const Divider(height: 16),
                        _buildMemberRow('Nông Văn Hùng', '0987 222 111'),
                        const Divider(height: 16),
                        _buildMemberRow('Chu Thị Mai', '0965 333 444'),
                        const Divider(height: 16),
                        Row(
                          children: const [
                            Text(
                              '... và 5 người khác',
                              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. PHƯƠNG TIỆN
                  const Text(
                    'PHƯƠNG TIỆN',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVehicleBadge('🛶 2 thuyền', Colors.green.shade700, true),
                      _buildVehicleBadge('🏍️ 3 xe máy', Colors.green.shade700, true),
                      _buildVehicleBadge('🚒 Xe tải', Colors.grey.shade500, false),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. BẢNG VẬT TƯ BIÊN CHẾ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('📦', style: const TextStyle(fontSize: 15)),
                                const SizedBox(width: 6),
                                Text(
                                  'VẬT TƯ BIÊN CHẾ',
                                  style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'standingEquipment',
                                style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Header bảng
                        Row(
                          children: const [
                            Expanded(flex: 4, child: Text('Vật tư', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                            Expanded(flex: 3, child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                            Expanded(flex: 3, child: Text('Đơn vị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                          ],
                        ),
                        const Divider(height: 12),
                        _buildTableItem('Áo phao', '10', 'cái'),
                        _buildTableItem('Đèn pin', '4', 'cái'),
                        _buildTableItem('Dây cứu hộ', '2', 'cuộn'),
                        
                        const SizedBox(height: 8),
                        
                        // Nút thêm vật tư
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green.shade800,
                              side: BorderSide(color: Colors.green.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('➕ Thêm vật tư biên chế mới')),
                              );
                            },
                            child: const Text('+ Thêm vật tư', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        Text(
                          'Khác "vật tư mang theo" của đội vãng lai: đây là tài sản biên chế, luôn có mặt mọi đợt thiên tai.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 9.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. KHU VỰC PHỤ TRÁCH
                  const Text(
                    'KHU VỰC PHỤ TRÁCH',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildZoneBadge('Thôn Pắc Liềng', true),
                      const SizedBox(width: 8),
                      _buildZoneBadge('Thôn Nà Lầu', false),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. MÃ QR CỦA ĐỘI
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Biểu tượng QR code nhỏ
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.qr_code_2, color: Colors.black, size: 36),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mã QR của đội',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'DR-BL-DQ-PL01',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Quét tại chốt để kích hoạt 1 chạm.',
                                style: TextStyle(color: Colors.grey, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('📋 Đã sao chép mã QR của đội!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 8. Nút LƯU ĐỘI THƯỜNG TRỰC dưới chân
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
                onPressed: _saveTeam,
                child: const Text(
                  'LƯU ĐỘI THƯỜNG TRỰC',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(String name, String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
        Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
      ],
    );
  }

  Widget _buildVehicleBadge(String text, Color color, bool hasColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasColor ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasColor ? color : Colors.grey.shade400,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: hasColor ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
        ),
      ),
    );
  }

  Widget _buildTableItem(String item, String qty, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(item, style: const TextStyle(fontSize: 11.5, color: Colors.black87, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(qty, style: const TextStyle(fontSize: 11.5, color: Colors.black87, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(unit, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildZoneBadge(String text, bool isAssigned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAssigned ? Colors.blue.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAssigned ? Colors.blue.shade800 : Colors.grey.shade400,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isAssigned ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
        ),
      ),
    );
  }
}
