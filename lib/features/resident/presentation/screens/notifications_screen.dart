import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách thông báo giả lập chi tiết theo thiết kế
    final notifications = [
      {
        'title': '🚨 Lệnh Sơ Tán Khẩn Cấp',
        'content': 'UBND Xã Bình Liêu yêu cầu toàn bộ các hộ dân thuộc khu vực trũng thấp Thôn Pắc Liềng di chuyển khẩn cấp đến điểm sơ tán Trường Tiểu học Bình Liêu.',
        'time': '10 phút trước',
        'isUnread': true,
        'type': 'alert',
      },
      {
        'title': '⛑️ Đội Cứu Hộ Đã Tiếp Nhận SOS',
        'content': 'Đội Cứu Hộ Bình Liêu 01 đã tiếp nhận yêu cầu SOS từ gia đình bạn và đang trên đường di chuyển đến vị trí định vị.',
        'time': '30 phút trước',
        'isUnread': true,
        'type': 'dispatch',
      },
      {
        'title': '📦 Cấp Phát Nhu Yếu Phẩm',
        'content': 'Mạnh thường quân và UBND Xã đã tiếp tế 20 thùng mì tôm, 10 thùng nước sạch tại nhà Văn Hóa Thôn Pắc Liềng.',
        'time': '2 giờ trước',
        'isUnread': false,
        'type': 'supply',
      },
      {
        'title': '⚠️ Cảnh Báo Lũ Quét',
        'content': 'Cảnh báo mưa lớn kéo dài, nguy cơ sạt lở đất đá tại các sườn đồi Thôn Pắc Liềng. Đề nghị nhân dân nâng cao cảnh giác.',
        'time': '5 giờ trước',
        'isUnread': false,
        'type': 'warning',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thông Báo & Chỉ Thị',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Đã đánh dấu tất cả là đã đọc')),
              );
            },
            child: const Text('Đọc tất cả', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isUnread = item['isUnread'] as bool;
          final type = item['type'] as String;

          IconData icon;
          Color iconColor;
          Color bgColor;

          switch (type) {
            case 'alert':
              icon = Icons.campaign;
              iconColor = const Color(0xFFD32F2F);
              bgColor = const Color(0xFFFFEBEE);
              break;
            case 'dispatch':
              icon = Icons.healing;
              iconColor = Colors.orange.shade800;
              bgColor = Colors.orange.shade50;
              break;
            case 'supply':
              icon = Icons.local_shipping;
              iconColor = Colors.blue.shade800;
              bgColor = Colors.blue.shade50;
              break;
            default:
              icon = Icons.warning_amber_rounded;
              iconColor = Colors.amber.shade900;
              bgColor = Colors.amber.shade50;
          }

          return Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                border: isUnread
                    ? const Border(left: BorderSide(color: Color(0xFFD32F2F), width: 4))
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isUnread ? Colors.black87 : Colors.black54,
                              ),
                            ),
                            Text(
                              item['time'] as String,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['content'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? Colors.black87 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
