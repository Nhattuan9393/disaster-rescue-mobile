import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/map_widget.dart';

class SituationBoardScreen extends StatelessWidget {
  const SituationBoardScreen({super.key});

  final LatLng _defaultCenter = const LatLng(21.5430, 107.3990);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: const Text(
          '📊 Tình hình Thiên tai',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Không cần đăng nhập',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin thiên tai đang diễn ra
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌊 LŨ LỤT — Xã Bình Liêu, Quảng Ninh',
                    style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đang diễn ra · Cập nhật 09:52 hôm nay',
                    style: TextStyle(color: Colors.black54, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Khung bản đồ tình hình rủi ro khẩn cấp
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CoreMapWidget(
                  center: _defaultCenter,
                  zoom: 13,
                  markers: [
                    Marker(
                      point: const LatLng(21.5430, 107.3990),
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Center(child: Text('🏫', style: TextStyle(fontSize: 14))),
                      ),
                    ),
                    Marker(
                      point: const LatLng(21.5450, 107.4020),
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Center(child: Text('🏫', style: TextStyle(fontSize: 14))),
                      ),
                    ),
                    Marker(
                      point: const LatLng(21.5410, 107.3950),
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 14))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. SỐ LIỆU TỔNG HỢP (SỐ TUYỆT ĐỐI)
            const Text(
              'SỐ LIỆU TỔNG HỢP (SỐ TUYỆT ĐỐI)',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatCard('480', 'Tổng hộ dân', Colors.grey.shade800),
                _buildStatCard('280', 'Đã an toàn', Colors.green.shade700),
                _buildStatCard('12', 'SOS đang chờ', Colors.red.shade700),
                _buildStatCard('5', 'Đội đang cứu', Colors.orange.shade800),
                _buildStatCard('8', 'Mất liên lạc', Colors.grey.shade700),
                _buildStatCard('155', 'Chỗ sơ tán trống', Colors.blue.shade800),
              ],
            ),
            const SizedBox(height: 16),

            // 4. NHU CẦU CỨU TRỢ ĐANG CẦN
            const Text(
              'NHU CẦU CỨU TRỢ ĐANG CẦN',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSupplyNeedRow('🦺 Áo phao', 'Cần 35 cái'),
                  const SizedBox(height: 4),
                  _buildSupplyNeedRow('🛏️ Chăn', 'Cần 120 cái'),
                  const SizedBox(height: 4),
                  _buildSupplyNeedRow('💧 Nước uống', 'Cần 160 chai'),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        'Liên hệ ủng hộ: UBND xã Bình Liêu — 0203.123.456',
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. HÌNH ẢNH HIỆN TRƯỜNG
            const Text(
              'HÌNH ẢNH HIỆN TRƯỜNG',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: _buildPhotoBox('🌊 Nước ngập xóm dưới')),
                const SizedBox(width: 8),
                Expanded(child: _buildPhotoBox('🏚️ Sạt lở đèo Khe Tiền')),
                const SizedBox(width: 8),
                Expanded(child: _buildPhotoBox('🛶 Đội cứu hộ tác chiến')),
              ],
            ),
            const SizedBox(height: 20),

            // Nút bấm cứu hộ khẩn cấp
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => context.push('/resident'),
                child: const Text(
                  '🆘 Tôi cần cứu hộ — Đăng nhập / Đăng ký',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSupplyNeedRow(String title, String needText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        Text(needText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
      ],
    );
  }

  Widget _buildPhotoBox(String title) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
