import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EscalateToDistrictScreen extends StatefulWidget {
  const EscalateToDistrictScreen({super.key});

  @override
  State<EscalateToDistrictScreen> createState() => _EscalateToDistrictScreenState();
}

class _EscalateToDistrictScreenState extends State<EscalateToDistrictScreen> {
  bool _reason1 = true;
  bool _reason2 = true;
  bool _reason3 = true;

  bool _force1 = true;
  bool _force2 = true;
  bool _force3 = true;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚨 ĐÃ GỬI BÁO ĐỘNG LEO THANG LÊN BAN CHỈ ĐẠO CỨU HỘ HUYỆN BÌNH LIÊU & TỈNH QUẢNG NINH!'),
        backgroundColor: Colors.red.shade900,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '🚨 Leo Thang Lên Cấp Huyện / Tỉnh',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ Cảnh báo khẩn cấp
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notification_important, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KÍCH HOẠT LEO THANG THIÊN TAI CỰC ĐOAN',
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Dành cho Admin xã khi tình hình lũ quét/sạt lở vượt quá khả năng ứng cứu của lực lượng tại chỗ.',
                          style: TextStyle(color: Colors.black87, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Lý do leo thang
            const Text(
              '1. LÝ DO LEO THANG BÁO ĐỘNG',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 6),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('🌊 Mực nước sông dâng vượt Báo động 3 (+2.8m)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _reason1,
                    activeColor: Colors.red.shade800,
                    onChanged: (val) => setState(() => _reason1 = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('🆘 Số lượng ca SOS chờ vượt quá 20 ca khẩn cấp', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _reason2,
                    activeColor: Colors.red.shade800,
                    onChanged: (val) => setState(() => _reason2 = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('🚧 Sạt lở chia cắt hoàn toàn đèo Khe Tiền', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _reason3,
                    activeColor: Colors.red.shade800,
                    onChanged: (val) => setState(() => _reason3 = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Đề xuất lực lượng chi viện
            const Text(
              '2. YÊU CẦU LỰC LƯỢNG CHI VIỆN KHẨN CẤP',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 6),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('🛶 4 Xuồng máy công suất lớn (>30HP)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _force1,
                    activeColor: Colors.blue.shade900,
                    onChanged: (val) => setState(() => _force1 = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('🚁 Trực thăng cứu hộ hàng không', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _force2,
                    activeColor: Colors.blue.shade900,
                    onChanged: (val) => setState(() => _force2 = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('🪖 2 Đội Bộ đội Biên phòng & Xe đặc chủng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    value: _force3,
                    activeColor: Colors.blue.shade900,
                    onChanged: (val) => setState(() => _force3 = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút bấm Kích hoạt Leo Thang
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                icon: const Icon(Icons.warning, color: Colors.white),
                label: const Text(
                  '🚨 PHÁT LỆNH LEO THANG LÊN HUYỆN / TỈNH KHẨN CẤP',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
