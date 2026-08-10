import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfflineSmsFallbackScreen extends StatelessWidget {
  const OfflineSmsFallbackScreen({super.key});

  final String _smsPayload = 'SOS#HH100#21.5430,107.3990#P85#5#Cấp4_TrũngThấp';
  final String _targetPhone = '0203.123.456';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '📶 Cứu Hộ SMS Ngoại Tuyến',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ Cảnh báo Mất mạng
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mất kết nối Internet 4G / Wifi',
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Hệ thống tự động nén thông tin tọa độ GPS & mức ưu tiên thành 1 tin nhắn SMS duy nhất.',
                          style: TextStyle(color: Colors.black87, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Chuỗi Cú pháp SMS mã hóa nén
            const Text(
              'CÚ PHÁP SMS NÉN MÃ HÓA (DƯỚI 140 KÝ TỰ)',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _smsPayload,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Số tổng đài tiếp nhận: $_targetPhone', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Icon(Icons.content_copy, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Giải mã các trường dữ liệu
            const Text(
              'GIẢI MÃ NỘI DUNG GỬI',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildDecodedRow('Mã hộ dân', 'HH100 (Hộ Nguyễn Văn A)'),
                  _buildDecodedRow('Tọa độ GPS', '21.5430° N, 107.3990° E'),
                  _buildDecodedRow('Điểm ưu tiên', 'P85 (Ưu tiên Đỏ)'),
                  _buildDecodedRow('Nhân khẩu', '5 người (Có người già 78T)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút bấm gửi SMS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📱 Đã mở trình nhắn tin SMS với cú pháp: $_smsPayload'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                },
                icon: const Icon(Icons.sms, color: Colors.white),
                label: const Text(
                  '📱 MỞ ỨNG DỤNG NHẮN TIN GỬI SMS NGAY',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecodedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}
