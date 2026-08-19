import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../../core/services/connectivity_service.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_model.dart';
import '../../domain/sos_status.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../../rescue_team/domain/rescue_team_model.dart';
import '../../../rescue_team/domain/rescue_team_status.dart';
import '../../../../core/widgets/qr_scanner_screen.dart';

class RescueTeamScreen extends ConsumerStatefulWidget {
  final String teamType; // 'permanent' hoặc 'volunteer'
  const RescueTeamScreen({super.key, this.teamType = 'permanent'});

  @override
  ConsumerState<RescueTeamScreen> createState() => _RescueTeamScreenState();
}

class _RescueTeamScreenState extends ConsumerState<RescueTeamScreen> with SingleTickerProviderStateMixin {
  final LatLng _binhLieuCenter = const LatLng(21.5284, 107.3986);
  late TabController _tabController;
  int _currentIndex = 0;



  // Form đăng ký MTQ nhanh nếu chưa được duyệt
  final _volunteerNameCtrl = TextEditingController(text: 'Tổ tình nguyện MTQ Hạ Long');
  final _leaderCtrl = TextEditingController(text: 'Nguyễn Văn Hải');
  final _phoneCtrl = TextEditingController(text: '0988 555 666');
  final _membersCtrl = TextEditingController(text: '6');
  final _boatsCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _volunteerNameCtrl.dispose();
    _leaderCtrl.dispose();
    _phoneCtrl.dispose();
    _membersCtrl.dispose();
    _boatsCtrl.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final teamId = 'team_${user.uid}';
      final newTeam = RescueTeamModel(
        id: teamId,
        name: _volunteerNameCtrl.text,
        leaderName: _leaderCtrl.text,
        contactPhone: _phoneCtrl.text,
        status: RescueTeamStatus.available,
        currentLatitude: 21.5284,
        currentLongitude: 107.3986,
        ownerUid: user.uid,
        isApproved: false,
        teamType: RescueTeamKind.volunteer,
        memberCount: int.tryParse(_membersCtrl.text) ?? 5,
        boatCount: int.tryParse(_boatsCtrl.text) ?? 1,
        broughtSupplies: const {
          'Mì tôm (thùng)': 50,
          'Nước uống (thùng)': 30,
          'Áo phao (chiếc)': 15,
          'Lương khô (hộp)': 10,
        },
      );
      ref.read(rescueTeamRepositoryProvider).saveRescueTeam(newTeam);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Đã gửi đơn đăng ký', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Đơn đăng ký của đội cứu hộ đã được gửi tới Ban Chỉ Huy xã. Vui lòng liên hệ Admin xã để duyệt đơn này tại mục "Chờ duyệt" của Quản lý lực lượng.',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _showQrScanner() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(
          title: 'Quét QR cư dân',
          subtitle:
              'Đưa mã QR trên căn cước / thẻ hộ vào khung xanh để điểm danh tại điểm sơ tán.',
        ),
      ),
    );
    if (code == null || !mounted) return;

    // Parse payload dạng "HH#<householdId>#<name>#<members>" hoặc chỉ mã hộ.
    String name = 'Hộ chưa xác định';
    int members = 1;
    final parts = code.split('#');
    if (parts.length >= 3) {
      name = parts[2];
      members = int.tryParse(parts.length > 3 ? parts[3] : '1') ?? 1;
    } else {
      // Fallback: mã raw → show raw
      name = code.length > 32 ? '${code.substring(0, 30)}…' : code;
    }
    _checkInResident(name, members);
  }

  void _checkInResident(String name, int members) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✓ Điểm danh thành công', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
        content: Text(
          'Đã điểm danh check-in thành công hộ ông $name ($members nhân khẩu) vào điểm sơ tán Trường TH Bình Liêu.',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final sosRequestsAsync = ref.watch(allSosRequestsStreamProvider);
    final markersAsync = ref.watch(sosMarkersProvider);
    final myTeamAsync = ref.watch(myRescueTeamStreamProvider);

    return myTeamAsync.when(
      data: (team) {
        final isApproved = team?.isApproved ?? (widget.teamType == 'permanent');
        final teamTitle = team?.name ?? (widget.teamType == 'permanent'
            ? 'Đội Dân quân Pắc Liềng (tt1 · Thường trực)'
            : 'Tổ tình nguyện MTQ (vl1 · Vãng lai)');

        // A. NẾU CHƯA ĐƯỢC PHÊ DUYỆT (Chỉ áp dụng với đội vãng lai)
        if (!isApproved) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.go('/login'),
              ),
              title: const Text('Đăng ký Đội tình nguyện', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            team == null
                                ? 'Đội cứu hộ vãng lai cần khai báo thông tin với Mặt trận Tổ quốc xã để được phân phối nhiệm vụ tác chiến.'
                                : 'Đơn đăng ký của đội đang chờ Ban Chỉ Huy xã phê duyệt. Hãy đăng nhập tài khoản admin để phê duyệt đội này.',
                            style: TextStyle(color: Colors.orange.shade900, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (team == null) ...[
                    TextField(
                      controller: _volunteerNameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên tổ/đội cứu hộ *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _leaderCtrl,
                      decoration: const InputDecoration(labelText: 'Họ tên trưởng đội *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _membersCtrl,
                            decoration: const InputDecoration(labelText: 'Số người *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _boatsCtrl,
                            decoration: const InputDecoration(labelText: 'Số xuồng/thuyền *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: _submitRegistration,
                        child: const Text('GỬI ĐĂNG KÝ CHO MTQ XÃ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang đợi Ban Chỉ Huy xã phê duyệt...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // B. ĐÃ ĐƯỢC DUYỆT -> VÀO BẢN TÁC CHIẾN CHÍNH (Chọn hiển thị theo _currentIndex)
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (_currentIndex != 0) {
              setState(() => _currentIndex = 0);
              return;
            }
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Thoát ứng dụng?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                content: const Text('Bạn có chắc chắn muốn đóng và thoát khỏi ứng dụng cứu hộ?', style: TextStyle(fontSize: 12)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('HỦY BỎ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('THOÁT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF9F9FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text(
              _currentIndex == 0 ? 'Bản Tác Chiến Cứu Hộ' : 'Thông Tin Đội Cứu Hộ',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            actions: [
              if (_currentIndex == 0)
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  onPressed: _showQrScanner,
                ),
            ],
          ),
          body: _currentIndex == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cảnh báo mất kết nối nếu có
                    if (!isOnline)
                      Container(
                        color: const Color(0xFFFFF9C4),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Chế độ ngoại tuyến — Dữ liệu cache lúc 09:12',
                              style: TextStyle(color: Color(0xFF5D4037), fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                    // 2. Nửa trên: Bản đồ định vị GPS các điểm SOS
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

                    // 3. Nửa dưới: Danh sách các nhiệm vụ cứu trợ phân chia 2 Tab
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.blue.shade900,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue.shade900,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        onTap: (_) => setState(() {}),
                        tabs: const [
                          Tab(text: 'Nhiệm vụ của tôi'),
                          Tab(text: 'SOS lân cận'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      flex: 5,
                      child: Container(
                        color: const Color(0xFFEEEEEE),
                        child: sosRequestsAsync.when(
                          data: (requests) {
                            // Nhiệm vụ của đội hiện tại = SOS đã gán cho team này,
                            // gồm cả 'assigned' (chưa lên đường) và 'inProgress'
                            // (đang xử lý). Ưu tiên assigned trước.
                            final myTeamId = team?.id;
                            final myTasks = myTeamId == null
                                ? <SosRequestEntity>[]
                                : (requests
                                    .where((r) =>
                                        r.assignedTeamId == myTeamId &&
                                        (r.status == SosStatus.assigned ||
                                            r.status == SosStatus.inProgress))
                                    .toList())
                                  ..sort((a, b) {
                                    // assigned trước inProgress; cùng status → priority cao hơn trước
                                    final aOrder = a.status == SosStatus.assigned ? 0 : 1;
                                    final bOrder = b.status == SosStatus.assigned ? 0 : 1;
                                    if (aOrder != bOrder) return aOrder - bOrder;
                                    return b.priorityScore.compareTo(a.priorityScore);
                                  });
                            // SOS lân cận chưa có đội = pending, ưu tiên đỏ trước
                            final nearbySos = requests
                                .where((r) => r.status == SosStatus.pending)
                                .toList()
                              ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

                            final displayList = _tabController.index == 0 ? myTasks : nearbySos;

                            if (displayList.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Không có nhiệm vụ nào trong danh sách.',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final sos = displayList[index];
                                final isRed = sos.priorityScore >= 50;
                                final isMyTask = _tabController.index == 0;
                                final statusLabel = sos.status == SosStatus.assigned
                                    ? 'MỚI GÁN — chưa lên đường'
                                    : sos.status == SosStatus.inProgress
                                        ? 'ĐANG TÁC CHIẾN'
                                        : 'CHỜ ĐIỀU PHỐI';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isRed ? const Color(0xFFC62828) : Colors.orange, width: 1.2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isRed ? const Color(0xFFC62828) : Colors.orange,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isRed ? 'ĐỎ — KHẨN CẤP' : 'CAM — NGUY HIỂM',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5),
                                            ),
                                          ),
                                          Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: sos.status == SosStatus.assigned
                                                  ? Colors.orange.shade800
                                                  : Colors.blue.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.grey, size: 15),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _tabController.index == 0 ? 'Thôn Pắc Liềng (~500m)' : 'Thôn Pắc Liềng (~1.2km)',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                            ),
                                          ),
                                          const Text('Số người: 4', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11.5)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _tabController.index == 0
                                            ? 'Chủ hộ: Nguyễn Văn Tuấn · SĐT: 0987 654 321'
                                            : 'Hộ Nguyễn Văn *** · Chưa nhận nhiệm vụ',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isMyTask ? Colors.green.shade800 : Colors.blue.shade900,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                                elevation: 0,
                                              ),
                                              onPressed: () => context.push('/rescue-sos-detail?sosId=${sos.id}'),
                                              child: Text(
                                                isMyTask
                                                    ? (sos.status == SosStatus.assigned
                                                        ? 'Nhận & tác chiến →'
                                                        : 'Tác chiến →')
                                                    : 'Xem chi tiết',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Banner tên đội và Loại đội
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.blue.shade900.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                team?.teamType == RescueTeamKind.permanent ? 'THƯỜNG TRỰC' : 'TÌNH NGUYỆN VÃNG LAI',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              teamTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Trưởng đội: ${team?.leaderName ?? (widget.teamType == 'permanent' ? "Trạm trưởng" : "Nguyễn Văn Hải")} · SĐT: ${team?.contactPhone ?? (widget.teamType == 'permanent' ? "0912 345 678" : "0988 555 666")}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Trạng thái trực chiến
                      _sectionLabel('TRẠNG THÁI TRỰC CHIẾN'),
                      const SizedBox(height: 8),
                      _buildProminentStatusCard(team?.status ?? RescueTeamStatus.available),
                      const SizedBox(height: 20),

                      // 3. Lực lượng & Phương tiện
                      _sectionLabel('LỰC LƯỢNG & PHƯƠNG TIỆN'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(Icons.people_alt, size: 28, color: Colors.blueGrey),
                                  const SizedBox(height: 6),
                                  Text('${team?.memberCount ?? (widget.teamType == 'permanent' ? 8 : 5)} thành viên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  const Text('Quân số trực', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 50, color: Colors.grey.shade300),
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(Icons.directions_boat_filled, size: 28, color: Colors.blue),
                                  const SizedBox(height: 6),
                                  Text('${team?.boatCount ?? (widget.teamType == 'permanent' ? 2 : 1)} phương tiện', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  const Text('Thuyền/Xuồng/Xe', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Kho lương & Vật tư mang theo
                      _sectionLabel('KHO LƯƠNG & VẬT TƯ MANG THEO'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (team != null && team.broughtSupplies.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: team.broughtSupplies.entries.map((entry) {
                                  return Chip(
                                    label: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                                    backgroundColor: Colors.orange.shade50,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.orange.shade100)),
                                  );
                                }).toList(),
                              )
                            else if (widget.teamType == 'permanent')
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [
                                  Chip(label: Text('Áo phao: 25 chiếc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)), backgroundColor: Color(0xFFE3F2FD)),
                                  Chip(label: Text('Phao tròn: 10 chiếc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)), backgroundColor: Color(0xFFE3F2FD)),
                                  Chip(label: Text('Túi y tế: 2 bộ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)), backgroundColor: Color(0xFFE3F2FD)),
                                ],
                              )
                            else
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'Chưa khai báo vật tư/nhu yếu phẩm mang theo.',
                                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 5. Nút đăng xuất an toàn dưới cùng
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade800,
                            side: BorderSide(color: Colors.red.shade300, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('ĐĂNG XUẤT KHỎI HỆ THỐNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận đăng xuất', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản đội cứu hộ?', style: TextStyle(fontSize: 12)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('HUỶ BỎ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(authControllerProvider.notifier).signOut();
                              if (context.mounted) context.go('/login');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (idx) => setState(() => _currentIndex = idx),
            selectedItemColor: Colors.blue.shade900,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Tác chiến',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Đội của tôi',
              ),
            ],
          ),
        ),
      );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Lỗi: $err'))),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }


  Widget _buildProminentStatusCard(RescueTeamStatus status) {
    MaterialColor mainColor;
    IconData icon;
    String title;
    String desc;

    switch (status) {
      case RescueTeamStatus.onMission:
        mainColor = Colors.blue;
        icon = Icons.navigation;
        title = 'Đang làm nhiệm vụ';
        desc = 'Đội đang di chuyển hỗ trợ cứu hộ khẩn cấp';
        break;
      case RescueTeamStatus.onBreak:
        mainColor = Colors.orange;
        icon = Icons.coffee;
        title = 'Tạm nghỉ hồi sức';
        desc = 'Đang nghỉ ăn uống/sửa chữa phương tiện';
        break;
      case RescueTeamStatus.offline:
        mainColor = Colors.grey;
        icon = Icons.cloud_off;
        title = 'Mất kết nối';
        desc = 'Thiết bị ngoại tuyến, đang lưu cache cục bộ';
        break;
      case RescueTeamStatus.endShift:
        mainColor = Colors.blueGrey;
        icon = Icons.exit_to_app;
        title = 'Đã rút quân';
        desc = 'Kết thúc đợt trực chiến chống thiên tai';
        break;
      case RescueTeamStatus.available:
        mainColor = Colors.green;
        icon = Icons.check_circle;
        title = 'SẴN SÀNG TÁC CHIẾN';
        desc = 'Đang nhận thông tin SOS thời gian thực';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mainColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: mainColor.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(color: mainColor.shade800, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade900,
              side: BorderSide(color: Colors.blue.shade900, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.tune, size: 12),
            label: const Text('Đổi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => context.push('/rescue-team-status'),
          ),
        ],
      ),
    );
  }
}
