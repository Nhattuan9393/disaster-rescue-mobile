import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../providers/report_provider.dart';
import '../../domain/assistance_request_model.dart';
import '../../../../core/widgets/map_widget.dart';

class ReportDetailScreen extends ConsumerWidget {
  final AssistanceRequestModel report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  // Tọa độ người báo giả lập (cách 320m)
  LatLng get _reporterLocation => LatLng(report.latitude + 0.002, report.longitude + 0.002);
  LatLng get _victimLocation => LatLng(report.latitude, report.longitude);

  int get _calculatedDistanceMeters {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, _reporterLocation, _victimLocation).toInt();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(reportControllerProvider.notifier);
    const hasPhotos = true; // Mặc định ảnh được giả lập xác minh

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
          'Xác minh báo cáo',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khung ảnh đính kèm (nếu có hoặc ảnh mẫu)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🖼️', style: TextStyle(fontSize: 28)),
                          SizedBox(height: 4),
                          Text('Ảnh 1 · GPS Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🖼️', style: TextStyle(fontSize: 28)),
                          SizedBox(height: 4),
                          Text('Ảnh 2 · GPS Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Tiêu đề & Nội dung mô tả
            Text(
              '🌊 Lũ lụt — ${report.address.isNotEmpty ? report.address : 'Thôn Nà Lầu'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '"${report.description}"',
                style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Bản đồ khoảng cách thực địa giữa Người báo (📱) và Nạn nhân (🆘)
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CoreMapWidget(
                      center: _victimLocation,
                      zoom: 14,
                      markers: [
                        Marker(
                          point: _reporterLocation,
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Center(child: Text('📱', style: TextStyle(fontSize: 14))),
                          ),
                        ),
                        Marker(
                          point: _victimLocation,
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Center(child: Text('🆘', style: TextStyle(fontSize: 16))),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                        child: const Text('📱 Người báo', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                        child: const Text('🆘 Nạn nhân', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange.shade800, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'Khoảng cách: ${_calculatedDistanceMeters}m',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Bảng phân tích chi tiết độ tin cậy
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade600, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ĐỘ TIN CẬY KHÁCH QUAN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10)),
                      Text(
                        '${report.confidenceScore}/100',
                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: report.confidenceScore / 100.0,
                      minHeight: 7,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                    ),
                  ),
                  const Divider(height: 20),
                  _buildScoreRow('Có ảnh hiện trường đính kèm', '+20 ✅', hasPhotos),
                  _buildScoreRow('GPS người báo cách nạn nhân < 500m', '+15 ✅', _calculatedDistanceMeters < 500),
                  _buildScoreRow('Nhiều người báo cùng khu vực (Cross-ref)', '+25 ✅', true),
                  _buildScoreRow('Tài khoản đã xác thực thông tin', '+10 ✅', true),
                  _buildScoreRow('Báo vị trí từ xa > 5km', '−15 —', false),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Thẻ tin báo trùng khu vực (Cross-reference)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔗 2 báo cáo trùng khu vực (200m / 30 phút)',
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  const Text('· 14:25 — "Nước ngập ngang hông ở xóm dưới"', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                  const Text('· 14:31 — "Cả dãy nhà ven sông bị ngập"', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. Thẻ thông tin người báo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    radius: 18,
                    child: const Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Người báo: Trần Thị Mai · 0912 777 888',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đã báo 6 lần · 5 lần được duyệt (83% chính xác)',
                          style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 7. Bộ nút hành động chính
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () async {
                  await controller.approveRequest(report);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Đã duyệt báo cáo và tạo ca SOS thành công!'), backgroundColor: Colors.green),
                    );
                    context.pop();
                  }
                },
                child: const Text(
                  '✓ DUYỆT → TẠO SOS',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade800,
                      side: BorderSide(color: Colors.blue.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💬 Đã gửi yêu cầu bổ sung thông tin tới người báo')),
                      );
                    },
                    child: const Text('💬 Hỏi thêm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      await controller.rejectRequest(report.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Đã từ chối báo cáo này'), backgroundColor: Colors.red),
                        );
                        context.pop();
                      }
                    },
                    child: const Text('✕ Từ chối', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade700 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
