import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/services/connectivity_service.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_status.dart';

class RescueTeamScreen extends ConsumerStatefulWidget {
  final String teamType; // 'permanent' hoặc 'volunteer'
  const RescueTeamScreen({super.key, this.teamType = 'permanent'});

  @override
  ConsumerState<RescueTeamScreen> createState() => _RescueTeamScreenState();
}

class _RescueTeamScreenState extends ConsumerState<RescueTeamScreen> with SingleTickerProviderStateMixin {
  final LatLng _binhLieuCenter = const LatLng(21.5284, 107.3986);
  late TabController _tabController;

  // Trạng thái hoạt động tác chiến của đội
  String _teamStatus = 'ready'; // 'ready', 'on_mission', 'resting'
  bool _isApproved = false; // Đối với đội vãng lai (vl1), cần được duyệt

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
    if (widget.teamType == 'permanent') {
      _isApproved = true;
    }
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
    setState(() {
      _isApproved = false; // ở trạng thái chờ duyệt
    });
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
          'Đơn đăng ký của đội cứu hộ đã được gửi tới Ban Chỉ Huy xã. Vui lòng đăng nhập tài khoản Admin xã để duyệt đơn này tại tab "Chờ duyệt".',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
            onPressed: () {
              Navigator.pop(ctx);
              // Giả lập admin duyệt ngay sau 1s để test thuận tiện
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() => _isApproved = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Ban chỉ huy xã đã phê duyệt đơn đăng ký của đội! Bạn đã được kích hoạt tác chiến.'), backgroundColor: Colors.green),
                  );
                }
              });
            },
            child: const Text('OK (Giả lập phê duyệt tự động)', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showQrScanner() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.blue),
            SizedBox(width: 8),
            Text('Quét mã QR cư dân', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đang mở camera quét mã QR của cư dân tại điểm sơ tán...', style: TextStyle(fontSize: 11.5)),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Hộ Nguyễn Văn Tuấn (4 người)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: const Text('Thôn Pắc Liềng', style: TextStyle(fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _checkInResident('Nguyễn Văn Tuấn', 4);
              },
            ),
          ],
        ),
      ),
    );
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

    final teamTitle = widget.teamType == 'permanent'
        ? 'Đội Dân quân Pắc Liềng (tt1 · Thường trực)'
        : 'Tổ tình nguyện MTQ (vl1 · Vãng lai)';

    // A. NẾU CHƯA ĐƯỢC PHÊ DUYỆT (Chỉ áp dụng với đội vãng lai)
    if (!_isApproved) {
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
                        'Đội cứu hộ vãng lai cần khai báo thông tin với Mặt trận Tổ quốc xã để được phân phối nhiệm vụ tác chiến.',
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
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
            ],
          ),
        ),
      );
    }

    // B. ĐÃ ĐƯỢC DUYỆT -> VÀO BẢN TÁC CHIẾN CHÍNH
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
          'Bản Tác Chiến Cứu Hộ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
            onPressed: _showQrScanner,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header hiển thị tên đội và trạng thái trực chiến của đội (Mục 34)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Trạng thái của đội:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _buildStatusChip('Sẵn sàng', 'ready', Colors.green.shade100, Colors.green.shade900),
                    const SizedBox(width: 4),
                    _buildStatusChip('Đang nhiệm vụ', 'on_mission', Colors.blue.shade100, Colors.blue.shade900),
                    const SizedBox(width: 4),
                    _buildStatusChip('Tạm nghỉ', 'resting', Colors.orange.shade100, Colors.orange.shade900),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

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

          // 3. Nửa dưới: Danh sách các nhiệm vụ cứu trợ phân chia 2 Tab (Mục 20)
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
                  final myTasks = requests.where((r) => r.status == SosStatus.inProgress).toList();
                  final nearbySos = requests.where((r) => r.status == SosStatus.pending || r.status == SosStatus.assigned).toList();

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
                                Row(
                                  children: const [
                                    Icon(Icons.tsunami, color: Colors.blue, size: 14),
                                    SizedBox(width: 4),
                                    Text('Ngập lụt sâu', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  ],
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
                                      backgroundColor: _tabController.index == 0 ? Colors.green.shade800 : Colors.blue.shade900,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      elevation: 0,
                                    ),
                                    onPressed: () => context.push('/rescue-sos-detail?sosId=${sos.id}'),
                                    child: Text(
                                      _tabController.index == 0 ? 'Tác chiến →' : 'Xem chi tiết',
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
      ),
    );
  }

  Widget _buildStatusChip(String label, String code, Color bg, Color fg) {
    final isSelected = _teamStatus == code;
    return GestureDetector(
      onTap: () {
        setState(() => _teamStatus = code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Đã cập nhật trạng thái đội cứu hộ thành: $label'), backgroundColor: fg),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? bg : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? fg : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? fg : Colors.black54, fontWeight: FontWeight.bold, fontSize: 10.5),
        ),
      ),
    );
  }
}
