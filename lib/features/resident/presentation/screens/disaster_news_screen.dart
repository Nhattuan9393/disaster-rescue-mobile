import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/connectivity_service.dart';

class DisasterNewsScreen extends ConsumerWidget {
  const DisasterNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Bản tin thiên tai',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Bản tin'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/resident');
          } else if (index == 2) {
            context.push('/household-profile');
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trạng thái mạng nếu offline
            if (!isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Đang xem bản tin lưu offline. Thông tin có thể chưa được cập nhật mới nhất.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

            // 1. Chỉ số cảnh báo lũ thực tế
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'CẢNH BÁO LŨ NGUY CẤP'.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sông Tiên Yên: 3.52m',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đạt ngưỡng Báo động III (Vượt lũ lịch sử 0.12m)',
                    style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Divider(color: Colors.white30, height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lượng mưa đo được: 180mm', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Xu hướng: Tiếp tục tăng', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Tiêu đề: Tin tức từ UBND Xã
            const Text(
              'TIN NỔI BẬT TỪ BAN CHỈ HUY XÃ',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            _buildNewsCard(
              title: 'Cầu Bản Sen ngập sâu 1m - Cấm lưu thông',
              time: '11:15 hôm nay',
              content: 'Nước lũ từ thượng nguồn đổ về khiến Cầu Bản Sen ngập sâu, dòng chảy xiết nguy hiểm. Công an xã đã lập chốt cấm toàn bộ người dân và phương tiện lưu thông qua lại.',
              icon: Icons.block,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 12),

            _buildNewsCard(
              title: 'Cấp phát mì tôm & nước sạch tại Nhà văn hóa',
              time: '10:00 hôm nay',
              content: 'UBND Xã phối hợp với Mặt trận Tổ quốc tổ chức cấp phát nhu yếu phẩm cứu trợ tại Nhà văn hóa thôn Pắc Liềng. Các hộ dân nằm trong vùng cô lập vui lòng liên hệ đội cứu hộ thôn để được hỗ trợ vận chuyển lương thực tận nhà.',
              icon: Icons.restaurant,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildNewsCard(
              title: 'Thông báo xả lũ khẩn cấp hồ Bình Liêu',
              time: '08:30 hôm nay',
              content: 'Hồ chứa nước Bình Liêu sẽ tiến hành xả lũ điều tiết từ 14:00 hôm nay. Khuyến cáo người dân dọc hai bên bờ sông Tiên Yên khẩn trương di dời tài sản và gia súc lên khu vực cao an toàn.',
              icon: Icons.warning,
              iconColor: Colors.amber.shade700,
            ),
            const SizedBox(height: 20),

            // 3. Tiêu đề: Đường dây nóng hỗ trợ khẩn cấp
            const Text(
              'ĐƯỜNG DÂY NÓNG KHẨN CẤP',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildHotlineRow(context, 'Ban chỉ huy PCTT Xã', '0243.999.888'),
                  const Divider(height: 16),
                  _buildHotlineRow(context, 'Đội cứu hộ thôn Pắc Liềng', '0912.345.678'),
                  const Divider(height: 16),
                  _buildHotlineRow(context, 'Y tế xã Bình Liêu', '0243.888.777'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String time,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineRow(BuildContext context, String name, String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('📞 Gọi cứu hộ khẩn cấp'),
                content: Text('Hệ thống sẽ thực hiện cuộc gọi khẩn cấp tới số:\n$name - $phone'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📞 Đang gọi số điện thoại cứu hộ: $phone...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('GỌI NGAY', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.phone, size: 14),
          label: const Text('GỌI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
