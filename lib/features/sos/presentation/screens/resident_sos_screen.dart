import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/gps_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../household/domain/household_model.dart';
import '../providers/sos_controller.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_status.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../../evacuation/presentation/providers/evacuation_provider.dart';

class ResidentSosScreen extends ConsumerStatefulWidget {
  const ResidentSosScreen({super.key});

  @override
  ConsumerState<ResidentSosScreen> createState() => _ResidentSosScreenState();
}

class _ResidentSosScreenState extends ConsumerState<ResidentSosScreen> {
  bool _isWaterAtRoof = false;
  bool _isInjured = false;

  // Giả lập Hộ dân đăng nhập
  final _testHousehold = const HouseholdModel(
    id: 'household_123',
    ownerUid: 'user_resident_abc',
    address: 'Thôn Pắc Liềng, Bình Liêu',
    latitude: 21.5284,
    longitude: 107.3986,
    memberCount: 4,
    childrenCount: 1,
    elderlyCount: 1,
    sickCount: 0,
    headName: 'Nguyễn Văn Tuấn',
    contactPhone: '0987654321',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preFetchLocation();
    });
  }

  Future<void> _preFetchLocation() async {
    try {
      AppLogger.i('Khởi động trước định vị GPS để tránh thời gian chết...');
      final gpsService = ref.read(gpsServiceProvider);
      await gpsService.getCurrentLocation();
    } catch (e) {
      AppLogger.w('Pre-fetch GPS failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final sosState = ref.watch(sosControllerProvider);
    final recentSosAsync = ref.watch(recentResidentSosProvider(_testHousehold.id));

    // Watch rescue teams và evacuation points để đưa lên live map
    final rescueTeamsAsync = ref.watch(allRescueTeamsStreamProvider);
    final evacuationPointsAsync = ref.watch(allEvacuationPointsProvider);

    // Xử lý thông báo khẩn cấp dạng SnackBar (dọn sạch snackbar trước đó tránh bị xếp chồng)
    ref.listen<SosState>(sosControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

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
          'DisasterRescue',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87, size: 28),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Bản tin'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        onTap: (index) {
          if (index == 1) {
            context.push('/news');
          } else if (index == 2) {
            context.push('/household-profile');
          }
        },
      ),
      body: Column(
        children: [
          // 1. Cảnh báo mất kết nối màu vàng ở trên cùng nếu offline
          if (!isOnline)
            Container(
              color: const Color(0xFFFFF9C4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không có mạng — Yêu cầu SOS sẽ lưu vào hàng đợi gửi SMS',
                      style: TextStyle(color: Color(0xFF5D4037), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Thẻ CẢNH BÁO LŨ LỤT & LỆNH SƠ TÁN
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/evacuation-alert'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF5350),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.campaign, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CẢNH BÁO & LỆNH SƠ TÁN — Thôn Pắc Liềng',
                                  style: TextStyle(
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Chạm để xem chi tiết lệnh sơ tán & chỉ đường ➔',
                                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 10.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Bản đồ tương tác trực quan hiển thị chi tiết (Nhà tôi, điểm sơ tán, đội cứu hộ)
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        CoreMapWidget(
                          center: LatLng(_testHousehold.latitude, _testHousehold.longitude),
                          zoom: 14.5,
                          markers: [
                            // Vị trí Hộ dân
                            Marker(
                              point: LatLng(_testHousehold.latitude, _testHousehold.longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Color(0xFFD32F2F), size: 36),
                            ),
                            // Các Điểm sơ tán
                            ...evacuationPointsAsync.maybeWhen(
                              data: (points) => points.map((p) => Marker(
                                point: LatLng(p.latitude, p.longitude),
                                width: 35,
                                height: 35,
                                child: const Icon(Icons.school, color: Colors.blue, size: 28),
                              )).toList(),
                              orElse: () => [],
                            ),
                            // Các Đội cứu hộ
                            ...rescueTeamsAsync.maybeWhen(
                              data: (teams) => teams.map((t) => Marker(
                                point: LatLng(t.currentLatitude, t.currentLongitude),
                                width: 35,
                                height: 35,
                                child: const Icon(Icons.directions_car, color: Colors.green, size: 28),
                              )).toList(),
                              orElse: () => [],
                            ),
                          ],
                        ),
                        // Nút phóng to bản đồ
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'expand_map_btn',
                            backgroundColor: Colors.white,
                            onPressed: () => context.push('/evacuation-points'),
                            child: const Icon(Icons.fullscreen, color: Colors.black87),
                          ),
                        ),
                        // Bảng chú giải nhỏ
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    const Text('Nhà tôi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    const Text('Điểm sơ tán', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    const Text('Đội cứu hộ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3.5. Realtime SOS status tracker (Vị trí nổi bật ngay dưới bản đồ nhỏ để dễ dàng theo dõi)
                  recentSosAsync.when(
                    data: (sos) {
                      if (sos == null) return const SizedBox.shrink();

                      Color statusColor;
                      String statusText = '';
                      IconData statusIcon;
                      String statusTip = '';

                      switch (sos.status) {
                        case SosStatus.pending:
                          statusColor = Colors.red;
                          statusText = 'Yêu cầu SOS đang chờ điều phối cứu nạn';
                          statusIcon = Icons.error_outline;
                          statusTip = 'Ban chỉ huy xã đã ghi nhận tín hiệu. Vui lòng giữ bình tĩnh, giữ điện thoại kết nối và chuẩn bị theo chỉ dẫn.';
                          break;

                        case SosStatus.assigned:
                          statusColor = Colors.orange;
                          statusText = 'Đội cứu hộ đang cơ động tiếp cận';
                          statusIcon = Icons.directions_car;
                          statusTip = 'Đội cứu hộ đã xuất phát. Sếp có thể theo dõi xe cơ động (mốc màu xanh lá) di chuyển trực tiếp trên bản đồ phía trên!';
                          break;
                        case SosStatus.inProgress:
                          statusColor = Colors.blue;
                          statusText = 'Đang tiến hành ứng cứu thực địa';
                          statusIcon = Icons.medical_services;
                          statusTip = 'Đội cứu hộ đã tiếp cận hiện trường và đang tiến hành di dời/hỗ trợ y tế khẩn cấp cho gia đình.';
                          break;
                        case SosStatus.completed:
                          statusColor = Colors.green;
                          statusText = 'Cứu hộ thành công!';
                          statusIcon = Icons.check_circle;
                          statusTip = 'Gia đình đã được di tản đến nơi an toàn. Cảm ơn sự hợp tác và kiên cường của sếp và gia đình!';
                          break;
                        default:
                          statusColor = Colors.grey;
                          statusText = 'Yêu cầu cứu nạn';
                          statusIcon = Icons.info;
                          statusTip = 'Hệ thống đang đồng bộ thông tin cứu hộ.';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                           border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    statusText,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              statusTip,
                              style: TextStyle(color: Colors.grey.shade800, fontSize: 11, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mã số SOS: ${sos.id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Độ khẩn: ${sos.priorityScore}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // 4. TIÊU ĐỀ: NGUY HIỂM TỨC THÌ
                  const Text(
                    'NGUY HIỂM TỨC THÌ — TÍNH BẰNG PHÚT',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // NÚT BẤM SOS KHỔNG LỒ
                  GestureDetector(
                    onTap: sosState.isLoading
                        ? null
                        : () async {
                            // Hiển thị Dialog cấp quyền giả lập của Android
                            final permissionGranted = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Row(
                                  children: const [
                                    Icon(Icons.location_on, color: Color(0xFFD32F2F), size: 24),
                                    SizedBox(width: 8),
                                    Text('Quyền Truy Cập Vị Trí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                content: const Text(
                                  'DisasterRescue cần truy cập vị trí của thiết bị này để gửi tọa độ cứu hộ khẩn cấp của bạn lên Ban chỉ huy.',
                                  style: TextStyle(fontSize: 13, height: 1.4),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('TỪ CHỐI', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('CHO PHÉP', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            );

                            if (permissionGranted == true) {
                              await ref.read(sosControllerProvider.notifier).triggerSOS(
                                    household: _testHousehold,
                                    isWaterAtRoof: _isWaterAtRoof,
                                    isInjured: _isInjured,
                                  );
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Quyền truy cập vị trí bị từ chối. Sử dụng tọa độ dự phòng.'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              await ref.read(sosControllerProvider.notifier).triggerSOS(
                                    household: _testHousehold,
                                    isWaterAtRoof: _isWaterAtRoof,
                                    isInjured: _isInjured,
                                  );
                            }
                            
                            // DR-026: Nếu mất mạng, sau khi lưu Hive thì chuyển sang màn SMS Fallback
                            if (!isOnline && mounted) {
                              context.push('/offline-sms');
                            }
                          },
                    child: Container(
                      height: 235,
                      decoration: BoxDecoration(
                        color: sosState.isLoading
                            ? Colors.grey
                            : (isOnline ? const Color(0xFFD32F2F) : Colors.amber.shade900),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isOnline ? const Color(0xFFD32F2F) : Colors.amber.shade900).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Các vòng tròn đồng tâm giả lập phát sóng cứu hộ khẩn cấp
                          Positioned(
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.08), width: 15),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.12), width: 10),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'S O S',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'BẤM ĐỂ GỬI CỨU HỘ NGAY',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cấu hình điểm khẩn cấp dạng checkbox ẩn/hiện chuyên nghiệp
                  ExpansionTile(
                    title: const Text(
                      'Tùy chọn khẩn cấp (Tính điểm ưu tiên)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    children: [
                      CheckboxListTile(
                        activeColor: const Color(0xFFD32F2F),
                        title: const Text('Mực nước ngập mái nhà (+20 điểm)'),
                        value: _isWaterAtRoof,
                        onChanged: (val) => setState(() => _isWaterAtRoof = val ?? false),
                      ),
                      CheckboxListTile(
                        activeColor: const Color(0xFFD32F2F),
                        title: const Text('Có người bị thương nặng (+20 điểm)'),
                        value: _isInjured,
                        onChanged: (val) => setState(() => _isInjured = val ?? false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. TIÊU ĐỀ: CÒN THỜI GIAN
                  const Text(
                    'CÒN THỜI GIAN — TÍNH BẰNG GIỜ',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push('/assistance'),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🙋', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Cần hỗ trợ sơ tán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                                Text('Xe chở, người khiêng', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                                    SizedBox(width: 8),
                                    Text('Báo Cáo An Toàn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                content: const Text(
                                  'Xác nhận bạn và gia đình vẫn an toàn? Hệ thống sẽ gửi báo cáo trạng thái an toàn lên Ban chỉ huy xã.',
                                  style: TextStyle(fontSize: 13, height: 1.4),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('HỦY BỎ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      try {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✅ Đã báo cho xã: Hộ gia đình của bạn vẫn an toàn!'),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                        await FirebaseFirestore.instance.collection('safety_confirmations').add({
                                          'householdId': 'household_my_family',
                                          'status': 'safe',
                                          'source': 'resident_proactive',
                                          'confidence': 100,
                                          'timestamp': DateTime.now().toIso8601String(),
                                        });
                                        await FirebaseFirestore.instance.collection('households').doc('household_my_family').set({
                                          'safetyStatus': 'safe',
                                          'lastConfirmed': DateTime.now().toIso8601String(),
                                        }, SetOptions(merge: true));
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Lỗi kết nối: ${e.toString()}'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.green.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('✔️', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Tôi vẫn an toàn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                Text('Báo cho xã yên tâm', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. TIÊU ĐỀ: VỀ NGƯỜI / NƠI KHÁC
                  const Text(
                    'VỀ NGƯỜI / NƠI KHÁC',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push('/report?type=B'),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🎥', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Báo giúp người khác', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push('/report?type=C'),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('📷', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Báo tình hình khu vực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
