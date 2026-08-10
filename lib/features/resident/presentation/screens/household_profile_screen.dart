import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseholdProfileScreen extends StatelessWidget {
  const HouseholdProfileScreen({super.key});

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
          'Hồ Sơ Hộ Gia Đình',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin Hộ gia đình
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hộ Nguyễn Văn A',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '🏚️ Cấp 4 — Trũng thấp',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('📍 Địa chỉ: Thôn Pắc Liềng, Xã Bình Liêu, Quảng Ninh', style: TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('📞 SĐT Chủ hộ: 0912.345.678', style: TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('🌐 Tọa độ GPS: 21.5430 N, 107.3990 E', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. DANH SÁCH NHÂN KHẨU (5 THÀNH VIÊN)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DANH SÁCH NHÂN KHẨU (5 NGƯỜI)',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/members-safety'),
                  icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  label: const Text('Điểm danh an toàn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            _buildMemberCard('Nguyễn Văn A', '1948 (78 tuổi)', 'Nam', 'Chủ hộ · 👴 Người già'),
            _buildMemberCard('Trần Thị B', '1951 (75 tuổi)', 'Nữ', 'Vợ · 👵 Người già'),
            _buildMemberCard('Nguyễn Văn C', '1980 (46 tuổi)', 'Nam', 'Con trai · 👨 Lao động chính'),
            _buildMemberCard('Lê Thị D', '1983 (43 tuổi)', 'Nữ', 'Con dâu'),
            _buildMemberCard('Nguyễn Văn E', '2021 (5 tuổi)', 'Nam', 'Cháu nội · 👶 Trẻ em nhỏ'),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(String name, String year, String gender, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87)),
              const SizedBox(height: 2),
              Text('$year · Giới tính: $gender', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
