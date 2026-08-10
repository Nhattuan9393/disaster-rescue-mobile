import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../providers/report_provider.dart';
import '../../domain/assistance_request_model.dart';

class VerifyReportsScreen extends ConsumerWidget {
  const VerifyReportsScreen({super.key});

  // Điểm Bính Liêu làm vị trí tham chiếu mặc định (Xã Bình Liêu)
  final LatLng _referenceLocation = const LatLng(21.5412, 107.3985);

  // Tính khoảng cách gần đúng (mét)
  int _calculateDistanceInMeters(double lat, double lng) {
    const Distance distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      _referenceLocation,
      LatLng(lat, lng),
    );
    return meters.toInt();
  }

  // Thuật toán Gộp tin báo trùng (Cross-reference - DR-038):
  // Đếm các báo cáo trong bán kính 200m và thời gian 30 phút
  int _countCrossReferencedReports(AssistanceRequestModel target, List<AssistanceRequestModel> all) {
    const Distance distance = Distance();
    final targetPos = LatLng(target.latitude, target.longitude);

    int count = 0;
    for (final req in all) {
      final pos = LatLng(req.latitude, req.longitude);
      final dist = distance.as(LengthUnit.Meter, targetPos, pos);
      final diffMinutes = target.timestamp.difference(req.timestamp).inMinutes.abs();

      if (dist <= 200 && diffMinutes <= 30) {
        count++;
      }
    }
    return count;
  }

  Color _getConfidenceColor(int score) {
    if (score >= 70) return Colors.green.shade700;
    if (score >= 40) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allAssistanceRequestsStreamProvider);
    final reportController = ref.read(reportControllerProvider.notifier);

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
          'Báo cáo Cần Xác Minh',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          reportsAsync.when(
            data: (list) {
              final pendingCount = list.where((r) => r.status == 'pending').length;
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount chờ',
                    style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (allReports) {
          final pendingReports = allReports.where((r) => r.status == 'pending').toList();

          if (pendingReports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'Không có báo cáo nào cần xác minh!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // Kiểm tra xem có cụm báo trùng nào không
          final hasCrossReference = pendingReports.any((r) => _countCrossReferencedReports(r, pendingReports) >= 2);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner thông báo gộp tin trùng (Cross-reference alert card)
                if (hasCrossReference)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🔗', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Phát hiện tin báo trùng khu vực (trong bán kính 200m / 30 phút) — Tự động ưu tiên độ tin cậy.',
                            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Danh sách các thẻ tin báo
                ...pendingReports.map((report) {
                  final distMeters = _calculateDistanceInMeters(report.latitude, report.longitude);
                  final crossCount = _countCrossReferencedReports(report, pendingReports);
                  
                  // Tự động cộng +25 điểm độ tin cậy nếu có báo trùng
                  final effectiveScore = (report.confidenceScore + (crossCount >= 2 ? 25 : 0)).clamp(0, 100);
                  final scoreColor = _getConfidenceColor(effectiveScore);

                  return GestureDetector(
                    onTap: () => context.push('/report-detail', extra: report),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hàng header icon + tiêu đề + khoảng cách
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('🌊', style: TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.address.isNotEmpty ? report.address : 'Báo cứu trợ — Thôn Nà Lầu',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${report.description}"',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '📍 ${distMeters}m từ hiện trường · ⏱ ${_formatTime(report.timestamp)}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 9.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Thanh hiển thị độ tin cậy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Độ tin cậy: $effectiveScore/100',
                                style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              if (crossCount >= 2)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '🔗 $crossCount báo trùng',
                                    style: TextStyle(color: Colors.blue.shade900, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: effectiveScore / 100.0,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Cặp nút hành động nhanh
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(color: Colors.red.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () {
                                    reportController.rejectRequest(report.id);
                                  },
                                  child: const Text('Từ chối', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    reportController.approveRequest(report);
                                  },
                                  child: const Text(
                                    'Duyệt → tạo SOS',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải danh sách: $err')),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
