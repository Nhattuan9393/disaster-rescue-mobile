import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../providers/report_provider.dart';
import '../../domain/assistance_request_model.dart';
import '../../domain/situation_report_model.dart';

class VerifyReportsScreen extends ConsumerStatefulWidget {
  const VerifyReportsScreen({super.key});

  @override
  ConsumerState<VerifyReportsScreen> createState() =>
      _VerifyReportsScreenState();
}

class _VerifyReportsScreenState extends ConsumerState<VerifyReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Điểm Bính Liêu làm vị trí tham chiếu mặc định (Xã Bình Liêu)
  final LatLng _referenceLocation = const LatLng(21.5412, 107.3985);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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

  // Thuật toán Gộp tin báo trùng (DR-038)
  int _countCrossReferencedReports(
      AssistanceRequestModel target, List<AssistanceRequestModel> all) {
    const Distance distance = Distance();
    final targetPos = LatLng(target.latitude, target.longitude);

    int count = 0;
    for (final req in all) {
      final pos = LatLng(req.latitude, req.longitude);
      final dist = distance.as(LengthUnit.Meter, targetPos, pos);
      final diffMinutes =
          target.timestamp.difference(req.timestamp).inMinutes.abs();

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
  Widget build(BuildContext context) {
    final assistanceAsync = ref.watch(allAssistanceRequestsStreamProvider);
    final situationAsync = ref.watch(allSituationReportsStreamProvider);

    final pendingAssistance = assistanceAsync.value
            ?.where((r) => r.status == 'pending')
            .toList() ??
        [];
    final situationList = situationAsync.value ?? [];

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
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.red.shade800,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade800,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: 'Báo giúp người khác (${pendingAssistance.length})'),
            Tab(text: 'Báo tình hình khu vực (${situationList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildAssistanceTab(assistanceAsync),
          _buildSituationTab(situationAsync),
        ],
      ),
    );
  }

  // ---------- Tab 1: Assistance Requests (Flow B) ----------
  Widget _buildAssistanceTab(
      AsyncValue<List<AssistanceRequestModel>> reportsAsync) {
    final reportController = ref.read(reportControllerProvider.notifier);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi tải danh sách: $err')),
      data: (allReports) {
        final pendingReports =
            allReports.where((r) => r.status == 'pending').toList();

        if (pendingReports.isEmpty) {
          return const _EmptyState(
            emoji: '🎉',
            message: 'Không có báo cứu trợ nào cần xác minh!',
          );
        }

        final hasCrossReference = pendingReports
            .any((r) => _countCrossReferencedReports(r, pendingReports) >= 2);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'Phát hiện tin báo trùng khu vực (200m / 30 phút) — Tự động ưu tiên độ tin cậy.',
                          style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ...pendingReports.map((report) {
                final distMeters =
                    _calculateDistanceInMeters(report.latitude, report.longitude);
                final crossCount =
                    _countCrossReferencedReports(report, pendingReports);
                final effectiveScore = (report.confidenceScore +
                        (crossCount >= 2 ? 25 : 0))
                    .clamp(0, 100);
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _photoThumb(report.photoUrls),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.address.isNotEmpty
                                        ? report.address
                                        : 'Báo cứu trợ — Thôn Nà Lầu',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${report.description}"',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📍 ${distMeters}m từ hiện trường · ⏱ ${_formatTime(report.timestamp)}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 9.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Độ tin cậy: $effectiveScore/100',
                              style: TextStyle(
                                  color: scoreColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                            if (crossCount >= 2)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🔗 $crossCount báo trùng',
                                  style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade300),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () =>
                                    reportController.rejectRequest(report.id),
                                child: const Text('Từ chối',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    reportController.approveRequest(report),
                                child: const Text(
                                  'Duyệt → tạo SOS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
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
    );
  }

  // ---------- Tab 2: Situation Reports (Flow C) ----------
  Widget _buildSituationTab(
      AsyncValue<List<SituationReportModel>> situationAsync) {
    return situationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi tải danh sách: $err')),
      data: (list) {
        if (list.isEmpty) {
          return const _EmptyState(
            emoji: '📭',
            message: 'Chưa có tin báo tình hình khu vực nào.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (ctx, i) {
            final r = list[i];
            final distMeters =
                _calculateDistanceInMeters(r.latitude, r.longitude);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _photoThumb(r.photoUrls),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _incidentColor(r.incidentType),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _incidentLabel(r.incidentType),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${r.photoUrls.length} ảnh',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.address.isNotEmpty
                                  ? r.address
                                  : 'Vị trí không rõ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            Text(
                              '"${r.description}"',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${distMeters}m · ⏱ ${_formatTime(r.timestamp)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (r.photoUrls.length > 1) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: r.photoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (ctx, idx) => GestureDetector(
                          onTap: () =>
                              _showFullscreen(context, r.photoUrls[idx], idx + 1, r.photoUrls.length),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              r.photoUrls[idx],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image,
                                    size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _photoThumb(List<String> photoUrls) {
    if (photoUrls.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () => _showFullscreen(context, photoUrls.first, 1, photoUrls.length),
          child: Image.network(
            photoUrls.first,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, p) => p == null
                ? child
                : Container(
                    width: 50, height: 50,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
            errorBuilder: (_, __, ___) => Container(
              width: 50, height: 50,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 22, color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: Text('🌊', style: TextStyle(fontSize: 24))),
    );
  }

  void _showFullscreen(BuildContext context, String url, int idx, int total) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Expanded(
                    child: Text('Ảnh $idx / $total',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            InteractiveViewer(
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _incidentLabel(String type) {
    switch (type) {
      case 'landslide': return '🏔️ SẠT LỞ';
      case 'flood': return '🌊 NGẬP LỤT';
      case 'road_blocked': return '🚧 TẮC ĐƯỜNG';
      default: return type.toUpperCase();
    }
  }

  Color _incidentColor(String type) {
    switch (type) {
      case 'landslide': return Colors.brown.shade700;
      case 'flood': return Colors.blue.shade700;
      case 'road_blocked': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String message;
  const _EmptyState({required this.emoji, required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
