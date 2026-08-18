import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/map_widget.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

class HouseholdDetailAdminScreen extends StatefulWidget {
  const HouseholdDetailAdminScreen({super.key});

  @override
  State<HouseholdDetailAdminScreen> createState() => _HouseholdDetailAdminScreenState();
}

class _HouseholdDetailAdminScreenState extends State<HouseholdDetailAdminScreen> {
  bool _isSafe = false;

  void _markAsSafe() {
    setState(() {
      _isSafe = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã đánh dấu Hộ Nguyễn Văn A: An toàn!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createSos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🆘 Đã gửi tín hiệu cứu nạn khẩn cấp SOS thay cho hộ dân!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _sendCheckTeam() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Đã cử đội cứu hộ gần nhất đi kiểm tra thực địa hộ dân!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tọa độ ngôi nhà
    final houseLocation = const LatLng(21.5412, 107.3985);

    // Marker nhà trong vòng ảnh hưởng
    final markers = [
      Marker(
        point: houseLocation,
        width: 32,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade800,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Center(child: Text('🏠', style: TextStyle(fontSize: 14))),
        ),
      ),
    ];

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
          'Hộ Nguyễn Văn A',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✏️ Mở form chỉnh sửa thông tin hộ dân')),
              );
            },
            child: const Text(
              'Sửa',
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
                  // 1. Thẻ thông tin Hộ mất liên lạc bo góc lớn viền đậm
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isSafe ? 'Đã xác nhận an toàn' : 'Mất liên lạc — thiết bị im lặng 4h',
                                style: TextStyle(
                                  color: _isSafe ? Colors.green.shade800 : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone_in_talk, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('📞 Đang gọi số điện thoại chủ hộ: 0987 654 321')),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Nguyễn Văn A - 0987 654 321',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thôn Pắc Liềng · 5 người · nhà cấp 4',
                          style: TextStyle(color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        
                        // Hộp cảnh báo màu xám nhạt
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Tín hiệu cuối: 10:30 hôm qua (app)',
                                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'source: self_app · confidence 90 · đã hết hạn',
                                    style: TextStyle(color: Colors.grey, fontSize: 9.5),
                                  ),
                                ],
                              ),
                              Icon(Icons.warning, color: Colors.yellow.shade800, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Hàng Badges màu cam
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildOrangeBadge('👶 2 trẻ em'),
                        _buildOrangeBadge('👵 1 người già'),
                        _buildOrangeBadge('🏠 Nhà cấp 4'),
                        _buildOrangeBadge('📍 Vùng ảnh hưởng'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Bản đồ định vị nhỏ ngôi nhà (150px)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        CoreMapWidget(
                          center: houseLocation,
                          zoom: 15,
                          markers: markers,
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Text(
                              '21.5412°N 107.3985°E',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. LỊCH SỬ TRẠNG THÁI
                  const Text(
                    'LỊCH SỬ TRẠNG THÁI',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildStatusHistoryItem(
                          title: 'Tự đánh dấu Mất liên lạc',
                          subtitle: 'hệ thống - im lặng > 4 giờ',
                          time: '09:52',
                          color: Colors.red.shade800,
                        ),
                        const Divider(height: 16),
                        _buildStatusHistoryItem(
                          title: 'Không phản hồi xác nhận lần 3',
                          subtitle: 'đã hỏi 06:30, 07:30, 08:30',
                          time: '08:30',
                          color: Colors.orange.shade800,
                        ),
                        const Divider(height: 16),
                        _buildStatusHistoryItem(
                          title: 'Xác nhận An toàn',
                          subtitle: 'source: self_app - confidence 90',
                          time: 'Hôm qua',
                          color: Colors.green.shade800,
                        ),
                        const Divider(height: 16),
                        _buildStatusHistoryItem(
                          title: 'Nhận cứu trợ',
                          subtitle: '2 chai nước, 1 chăn',
                          time: 'Hôm qua',
                          color: Colors.blue.shade800,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. SỐ CỨU TRỢ CỦA HỘ
                  const Text(
                    'SỐ CỨU TRỢ CỦA HỘ',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'BN-2025-0198',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '2 chai nước · 1 chăn',
                              style: TextStyle(color: Colors.black87, fontSize: 11.5),
                            ),
                          ],
                        ),
                        Text(
                          'Hôm qua 09:15',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. 4 Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            side: BorderSide(color: Colors.blue.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Gọi hộ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('📞 Đang kết nối cuộc gọi đến hộ dân...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            side: BorderSide(color: Colors.blue.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('Xem trên bản đồ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🗺️ Đã hiển thị vị trí hộ dân trên bản đồ chỉ huy!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade900,
                            side: BorderSide(color: Colors.orange.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.home_outlined, size: 16),
                          label: const Text('Đánh dấu an toàn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _markAsSafe,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade900,
                            side: BorderSide(color: Colors.red.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.sos_outlined, size: 16),
                          label: const Text('Tạo SOS thay hộ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _createSos,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 7. Nút GỬI ĐỘI ĐI KIỂM TRA ở dưới cùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F), // Màu xám đậm
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.engineering, size: 18),
                label: const Text(
                  '🚨 GỬI ĐỘI ĐI KIỂM TRA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
                onPressed: _sendCheckTeam,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangeBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
      ),
    );
  }

  Widget _buildStatusHistoryItem({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
