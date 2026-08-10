import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../../core/widgets/role_switcher.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/sos_sync_service.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../../rescue_team/domain/rescue_team_model.dart';
import '../../../rescue_team/domain/rescue_team_status.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_status.dart';

class RescueTeamScreen extends ConsumerStatefulWidget {
  const RescueTeamScreen({super.key});

  @override
  ConsumerState<RescueTeamScreen> createState() => _RescueTeamScreenState();
}

class _RescueTeamScreenState extends ConsumerState<RescueTeamScreen> {
  // Giả lập ID đội hiện tại đăng nhập trên máy
  final String _currentTeamId = 'team_binh_lieu_001';
  final LatLng _binhLieuCenter = const LatLng(21.5284, 107.3986);

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final allTeamsAsync = ref.watch(allRescueTeamsStreamProvider);
    final sosRequestsAsync = ref.watch(allSosRequestsStreamProvider);
    final markersAsync = ref.watch(sosMarkersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Đội Cứu Hộ — Bản Tác Chiến',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      drawer: const TestRoleSwitcherDrawer(),
      body: allTeamsAsync.when(
        data: (teams) {
          // Tìm document của đội cứu hộ hiện tại
          RescueTeamModel? currentTeam;
          try {
            currentTeam = teams.firstWhere((t) => t.id == _currentTeamId);
          } catch (_) {
            currentTeam = null;
          }

          // 1. Trường hợp Đội cứu nạn chưa được khởi tạo trên DB
          if (currentTeam == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_outlined, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Không tìm thấy Đội cứu hộ trên DB!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng bấm nút dưới đây để đăng ký đội cứu hộ mẫu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        final repo = ref.read(rescueTeamRepositoryProvider);
                        await repo.saveRescueTeam(
                          RescueTeamModel(
                            id: _currentTeamId,
                            name: 'Đội Cứu Hộ Bình Liêu 01',
                            leaderName: 'Trịnh Văn Mạnh',
                            contactPhone: '0912345678',
                            status: RescueTeamStatus.available,
                            currentLatitude: 21.5284,
                            currentLongitude: 107.3986,
                          ),
                        );
                      },
                      child: const Text('KHỞI TẠO ĐỘI CỨU HỘ MẪU'),
                    )
                  ],
                ),
              ),
            );
          }

          // 2. Có đội cứu hộ, hiển thị giao diện tác chiến chia 2 nửa (Screenshot 3)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A. Cảnh báo mất kết nối màu vàng (nếu offline)
              if (!isOnline)
                Container(
                  color: const Color(0xFFFFF9C4),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mất mạng — Dữ liệu cache 09:12',
                          style: TextStyle(color: Color(0xFF5D4037), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // B. Phần Header tên khu vực
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nhiệm vụ — Thôn Pắc Liềng',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                    ),
                    sosRequestsAsync.when(
                      data: (requests) {
                        final count = requests.where((r) => r.status != SosStatus.completed).length;
                        return Text(
                          '$count SOS',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    )
                  ],
                ),
              ),

              // C. Nửa trên: Bản đồ khu vực
              Expanded(
                flex: 4,
                child: markersAsync.when(
                  data: (markers) => CoreMapWidget(
                    center: _binhLieuCenter,
                    zoom: 13.0,
                    markers: markers,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Lỗi bản đồ: $err')),
                ),
              ),

              // D. Nửa dưới: Danh sách các nhiệm vụ cứu nạn dạng cuộn
              Expanded(
                flex: 6,
                child: Container(
                  color: const Color(0xFFEEEEEE),
                  child: sosRequestsAsync.when(
                    data: (requests) {
                      final activeRequests = requests
                          .where((req) => req.status != SosStatus.completed && req.status != SosStatus.cancelled)
                          .toList();

                      if (activeRequests.isEmpty) {
                        return const Center(
                          child: Text(
                            'Không có nhiệm vụ cứu trợ nào xung quanh.',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: activeRequests.length,
                        itemBuilder: (context, index) {
                          final sos = activeRequests[index];
                          final isAssignedToUs = currentTeam?.assignedSosId == sos.id;
                          final isAssignedToOther = sos.assignedTeamId != null && sos.assignedTeamId != _currentTeamId;
                          final isPending = sos.status == SosStatus.pending;
                          final isWater = (sos.priorityScore % 2 == 0);

                          // Xác định độ khẩn cấp theo priorityScore
                          final isRedPriority = sos.priorityScore >= 50;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRedPriority ? const Color(0xFFC62828) : Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Hàng 1: Badge mức độ khẩn cấp + Loại sự cố
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isRedPriority ? const Color(0xFFC62828) : Colors.orange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isRedPriority ? 'ĐỎ — KHẤN CẤP' : 'CAM — NGUY HIỂM',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          isWater ? Icons.tsunami : Icons.landscape,
                                          color: isWater ? Colors.blue : Colors.brown,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isWater ? 'Lũ lụt' : 'Sạt lở',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Hàng 2: Vị trí + Khoảng cách + Số người
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Thôn Pắc Liềng (~500m)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      'Số người: 4',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // CỬA SỔ 21: Mở khóa thông tin chi tiết NẾU ĐÃ NHẬN NHIỆM VỤ
                                if (isAssignedToUs && sos.status == SosStatus.inProgress)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.lock_open, color: Colors.blue, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'THÔNG TIN LIÊN LẠC ĐÃ MỞ KHÓA:',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 10),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        const Text('Chủ hộ: Nguyễn Văn Tuấn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const Text('SĐT: 0987654321', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const Text('Vị trí cụ thể: Cạnh nhà văn hóa thôn Pắc Liềng', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  )
                                else if (!isAssignedToUs)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.lock, color: Colors.grey, size: 14),
                                        SizedBox(width: 6),
                                        Text(
                                          'Chưa nhận nhiệm vụ — không hiện tên, SĐT, địa chỉ',
                                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),

                                // Hàng 3: Nút hành động tác chiến
                                if (isAssignedToUs) ...[
                                  if (sos.status == SosStatus.assigned)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRedPriority ? const Color(0xFFC62828) : Colors.orange,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        final repo = ref.read(rescueTeamRepositoryProvider);
                                        await repo.acceptMission(_currentTeamId, sos.id);
                                      },
                                      child: const Text(
                                        'TÔI ĐI ➔',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                      ),
                                    ),
                                  if (sos.status == SosStatus.inProgress)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        final repo = ref.read(rescueTeamRepositoryProvider);
                                        await repo.completeMission(_currentTeamId, sos.id);
                                      },
                                      child: const Text(
                                        'BÁO CÁO HOÀN THÀNH',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                      ),
                                    ),
                                ] else if (isAssignedToOther)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '👮 Đội khác đang đến',
                                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  )
                                else if (isPending)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      // Cho phép đội tự ứng cứu gán thẳng việc khi khẩn cấp
                                      final repo = ref.read(sosRepositoryProvider);
                                      await repo.assignRescueTeam(sos.id, _currentTeamId);
                                      final teamRepo = ref.read(rescueTeamRepositoryProvider);
                                      await teamRepo.acceptMission(_currentTeamId, sos.id);
                                    },
                                    child: const Text(
                                      'TỰ NHẬN NHIỆM VỤ ➔',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Lỗi: $err')),
                  ),
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
