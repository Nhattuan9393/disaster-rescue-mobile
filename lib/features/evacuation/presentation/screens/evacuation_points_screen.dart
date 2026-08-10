import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/map_widget.dart';
import '../providers/evacuation_provider.dart';
import '../../domain/evacuation_point_model.dart';

class EvacuationPointsScreen extends ConsumerWidget {
  final bool isAdmin;

  const EvacuationPointsScreen({
    super.key,
    this.isAdmin = false,
  });

  final LatLng _defaultCenter = const LatLng(21.5412, 107.3985);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green.shade700;
      case 'nearly_full':
        return Colors.orange.shade800;
      case 'full':
        return Colors.red.shade700;
      case 'closed':
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Còn chỗ';
      case 'nearly_full':
        return 'Sắp đầy';
      case 'full':
        return 'Đã đầy';
      case 'closed':
      default:
        return 'Hỏng — ngập';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(allEvacuationPointsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isAdmin ? 'Quản lý Điểm Sơ Tán' : 'Điểm Sơ Tán An Toàn',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: isAdmin
            ? [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📍 Chức năng thêm điểm sơ tán động đã sẵn sàng')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.blue),
                  label: const Text(
                    'Thêm',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ]
            : null,
      ),
      body: pointsAsync.when(
        data: (points) {
          final markers = points.map((p) {
            final color = _getStatusColor(p.status);
            return Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 34,
              height: 34,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 15))),
              ),
            );
          }).toList();

          return Column(
            children: [
              // A. Khung bản đồ cắm mốc điểm sơ tán phía trên (170px)
              SizedBox(
                height: 170,
                child: CoreMapWidget(
                  center: _defaultCenter,
                  zoom: 13,
                  markers: markers,
                ),
              ),

              // B. Danh sách các thẻ Điểm sơ tán cuộn phía dưới
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: points.length,
                  itemBuilder: (context, index) {
                    final point = points[index];
                    final statusColor = _getStatusColor(point.status);
                    final percent = (point.currentCount / (point.capacity > 0 ? point.capacity : 1)).clamp(0.0, 1.0);

                    return GestureDetector(
                      onTap: () {
                        if (isAdmin) {
                          context.push('/evacuation-point-detail', extra: point);
                        } else {
                          context.push('/evacuation-alert');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: point.status == 'closed' ? Colors.grey.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🏠 ${point.name}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: point.status == 'closed' ? Colors.grey.shade700 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),

                            if (point.status != 'closed') ...[
                              Text(
                                'Sức chứa: ${point.currentCount}/${point.capacity} người',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: statusColor),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 7,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (point.supplies.isNotEmpty)
                                Text(
                                  'Vật tư tại chỗ: ${point.supplies.join(", ")}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5),
                                ),
                            ],

                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getStatusText(point.status),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10.5),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      isAdmin ? 'Cập nhật tình trạng' : 'Xem đường đi & chỉ dẫn',
                                      style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.blue.shade800),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
      ),
    );
  }
}
