import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/map_widget.dart';
import '../providers/evacuation_provider.dart';
import '../../domain/evacuation_order_model.dart';

class BroadcastEvacuationScreen extends ConsumerStatefulWidget {
  const BroadcastEvacuationScreen({super.key});

  @override
  ConsumerState<BroadcastEvacuationScreen> createState() => _BroadcastEvacuationScreenState();
}

class _BroadcastEvacuationScreenState extends ConsumerState<BroadcastEvacuationScreen> {
  final List<String> _selectedVillages = ['Thôn Pắc Liềng', 'Thôn Nà Lầu'];
  String? _selectedTargetPointId;
  String _targetPointName = 'Trường TH Bình Liêu';

  bool _includeTayLanguage = true;
  final TextEditingController _contentViController = TextEditingController(
    text: 'KHẨN: Lệnh sơ tán thôn Pắc Liềng, Nà Lầu. Toàn bộ hộ dân di chuyển ngay đến Trường TH Bình Liêu. Mang theo giấy tờ, thuốc men. Liên hệ 0203.123.456 nếu cần hỗ trợ di chuyển.',
  );

  final TextEditingController _contentTayController = TextEditingController(
    text: "Khẩn: Slống bản Pắc Liềng, Nà Lầu pây d'ú Trường TH Bình Liêu. Au giấy tờ, dà slử pây nèm.",
  );

  final LatLng _defaultCenter = const LatLng(21.5430, 107.3990);

  @override
  void dispose() {
    _contentViController.dispose();
    _contentTayController.dispose();
    super.dispose();
  }

  void _broadcastOrder() async {
    final repo = ref.read(evacuationRepositoryProvider);
    final order = EvacuationOrderModel(
      id: const Uuid().v4(),
      targetVillages: _selectedVillages,
      targetPointId: _selectedTargetPointId ?? 'evac_01',
      targetPointName: _targetPointName,
      contentVi: _contentViController.text.trim(),
      contentTay: _includeTayLanguage ? _contentTayController.text.trim() : '',
      senderId: 'admin_commune',
      timestamp: DateTime.now(),
    );

    await repo.broadcastEvacuationOrder(order);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📣 ĐÃ PHÁT LỆNH SƠ TÁN KHẨN CẤP THÀNH CÔNG!'),
          backgroundColor: Colors.red,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Phát Lệnh Sơ Tán Khẩn Cấp',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BƯỚC 1: CHỌN KHU VỰC
            const Text(
              'BƯỚC 1 — CHỌN KHU VỰC ẢNH HƯỞNG',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CoreMapWidget(
                      center: _defaultCenter,
                      zoom: 14,
                      markers: [
                        Marker(
                          point: _defaultCenter,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Center(child: Icon(Icons.warning, color: Colors.red, size: 22)),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                        child: const Text('✎ Vẽ vùng ngập khẩn cấp trên bản đồ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                _buildVillageChip('Thôn Pắc Liềng'),
                _buildVillageChip('Thôn Nà Lầu'),
                _buildVillageChip('Thôn Khe Tiền'),
              ],
            ),
            const SizedBox(height: 16),

            // BƯỚC 2: ĐIỂM SƠ TÁN ĐÍCH
            const Text(
              'BƯỚC 2 — ĐIỂM SƠ TÁN ĐÍCH',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            pointsAsync.when(
              data: (points) {
                final openPoints = points.where((p) => p.status != 'closed').toList();
                if (_selectedTargetPointId == null && openPoints.isNotEmpty) {
                  _selectedTargetPointId = openPoints.first.id;
                  _targetPointName = openPoints.first.name;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTargetPointId,
                      isExpanded: true,
                      items: openPoints.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                            '🏫 ${p.name} — còn ${p.capacity - p.currentCount} chỗ',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final selected = openPoints.firstWhere((element) => element.id == val);
                          setState(() {
                            _selectedTargetPointId = val;
                            _targetPointName = selected.name;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Lỗi danh sách điểm sơ tán'),
            ),
            const SizedBox(height: 16),

            // BƯỚC 3: NỘI DUNG TIN NHẮN
            const Text(
              'BƯỚC 3 — NỘI DUNG TIN NHẮN',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            // Tiếng Việt
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TIẾNG VIỆT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 9)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contentViController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Toggle Tiếng Tày
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gửi thêm bản Tiếng Tày (Tày language)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Switch(
                  value: _includeTayLanguage,
                  activeThumbColor: Colors.green.shade700,
                  onChanged: (val) => setState(() => _includeTayLanguage = val),
                ),
              ],
            ),

            if (_includeTayLanguage)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TIẾNG TÀY (DỊCH TỰ ĐỘNG)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 9)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _contentTayController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Thẻ tổng quan người nhận
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '📣 Sẽ phát đến 150 hộ dân (487 nhân khẩu) thuộc ${_selectedVillages.join(", ")}.',
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Nút phát lệnh ngay
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _broadcastOrder,
                child: const Text(
                  'PHÁT LỆNH NGAY 📣',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVillageChip(String village) {
    final isSelected = _selectedVillages.contains(village);
    return FilterChip(
      selected: isSelected,
      label: Text(village),
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.red.shade900 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedVillages.add(village);
          } else {
            _selectedVillages.remove(village);
          }
        });
      },
    );
  }
}
