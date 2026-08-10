import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/map_widget.dart';
import '../providers/evacuation_provider.dart';
import '../../domain/evacuation_order_model.dart';

class EvacuationAlertDetailScreen extends ConsumerWidget {
  final EvacuationOrderModel? order;

  const EvacuationAlertDetailScreen({
    super.key,
    this.order,
  });

  final LatLng _homeLocation = const LatLng(21.5412, 107.3985);
  final LatLng _evacLocation = const LatLng(21.5430, 107.3990);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestOrderAsync = ref.watch(latestEvacuationOrderProvider);
    final repo = ref.read(evacuationRepositoryProvider);

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
          'Chi tiết thông báo',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: latestOrderAsync.when(
        data: (activeOrder) {
          final displayOrder = order ?? activeOrder;

          final viContent = displayOrder?.contentVi ??
              'KHẨN: Lệnh sơ tán thôn Pắc Liềng. Toàn bộ hộ dân di chuyển ngay đến Trường TH Bình Liêu. Mang theo giấy tờ, thuốc men. Liên hệ 0203.123.456 nếu cần hỗ trợ di chuyển.';
          final tayContent = displayOrder?.contentTay ??
              "Khẩn: Slống bản Pắc Liềng pây d'ú Trường TH Bình Liêu. Au giấy tờ, dà slử pây nèm.";
          final targetPointName = displayOrder?.targetPointName ?? 'Trường TH Bình Liêu';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thẻ cảnh báo sơ tán khẩn màu cam
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade600, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade800,
                            radius: 18,
                            child: const Text('🏫', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LỆNH SƠ TÁN KHẨN CẤP',
                                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                                const Text(
                                  'Thôn Pắc Liềng · 09:30 hôm nay · UBND xã Bình Liêu',
                                  style: TextStyle(color: Colors.black54, fontSize: 9.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(6)),
                            child: const Text(
                              'KHẨN',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        viContent,
                        style: const TextStyle(fontSize: 12.5, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Thẻ hiển thị bản Tiếng Tày
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('🗣 Bản Tiếng Tày', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tayContent,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 11.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Bản đồ dẫn đường tới điểm sơ tán
                const Text(
                  'ĐIỂM SƠ TÁN ĐÍCH',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),

                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CoreMapWidget(
                          center: _evacLocation,
                          zoom: 14,
                          markers: [
                            Marker(
                              point: _homeLocation,
                              width: 32,
                              height: 32,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Center(child: Text('🏠', style: TextStyle(fontSize: 14))),
                              ),
                            ),
                            Marker(
                              point: _evacLocation,
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.green.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 16))),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                            child: const Text('🧭 1.2km · ~18 phút đi bộ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Thẻ trường học sơ tán
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text('🏫', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(targetPointName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            const Text('Còn 155/200 chỗ · Có chăn, nước, lương khô', style: TextStyle(color: Colors.black54, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Danh mục đồ cần mang theo
                const Text(
                  'CẦN MANG THEO',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildSupplyChip('📄 Giấy tờ tuỳ thân'),
                    _buildSupplyChip('💊 Thuốc đang dùng'),
                    _buildSupplyChip('🔦 Đèn pin'),
                    _buildSupplyChip('🔌 Sạc dự phòng'),
                    _buildSupplyChip('👕 Quần áo khô'),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Nút Check-in đã đến nơi
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await repo.checkInHousehold('evac_01', 'household_my_family');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ XÁC NHẬN SƠ TÁN THÀNH CÔNG! Trạng thái an toàn đạt 95% tin cậy.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.pop();
                      }
                    },
                    child: const Text(
                      '✓ TÔI ĐÃ ĐẾN ĐIỂM SƠ TÁN',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải thông báo: $err')),
      ),
    );
  }

  Widget _buildSupplyChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}
