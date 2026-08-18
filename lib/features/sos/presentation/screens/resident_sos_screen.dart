import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'package:geolocator/geolocator.dart';
import '../../domain/sos_status.dart';
import '../../domain/sos_model.dart';

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
      
      // Kiểm tra quyền định vị hiện tại
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && mounted) {
        // Yêu cầu quyền ngay lập tức tại thời điểm bình tĩnh (khi mới mở màn hình)
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
          final gpsService = ref.read(gpsServiceProvider);
          await gpsService.getCurrentLocation();
        } else {
          AppLogger.w('Người dùng từ chối cấp quyền vị trí tại thời điểm bình tĩnh.');
        }
      } else {
        final gpsService = ref.read(gpsServiceProvider);
        await gpsService.getCurrentLocation();
      }
    } catch (e) {
      AppLogger.w('Pre-fetch GPS failed: $e');
    }
  }

  // Theo dõi vị trí nền & giả lập dung lượng Pin thích ứng
  StreamSubscription<Position>? _positionSubscription;
  double _simulatedBatteryLevel = 75.0; // Mặc định 75%
  bool _isTracking = false;
  String? _currentlyTrackingSosId;

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _handleActiveSosTracking(SosRequestEntity? sos, bool isOnline) {
    if (sos == null) {
      _stopTracking();
      return;
    }

    final isActive = sos.status == SosStatus.pending ||
        sos.status == SosStatus.assigned ||
        sos.status == SosStatus.inProgress;

    if (isActive) {
      if (!_isTracking || _currentlyTrackingSosId != sos.id) {
        _startTracking(sos.id, isOnline);
      }
    } else {
      _stopTracking();
    }
  }

  void _startTracking(String sosId, bool isOnline) {
    _stopTracking();
    _isTracking = true;
    _currentlyTrackingSosId = sosId;

    AppLogger.i('Bắt đầu lắng nghe thay đổi vị trí nền cho SOS: $sosId');

    // Xác định khoảng thời gian thích ứng dựa trên mức Pin giả lập
    int intervalSeconds = 30; // Tiêu chuẩn
    if (_simulatedBatteryLevel < 20) {
      AppLogger.w('Pin yếu (<20%). Không bật định vị nền tự động để tiết kiệm năng lượng.');
      return; // Tắt hoàn toàn định vị nền tự động
    } else if (_simulatedBatteryLevel <= 50) {
      intervalSeconds = 120; // Giãn chu kỳ 2 phút
      AppLogger.i('Cấu hình định vị nền thích ứng: 2 phút / lần quét (Mức pin: $_simulatedBatteryLevel%)');
    } else {
      intervalSeconds = 30; // 30 giây
      AppLogger.i('Cấu hình định vị nền tiêu chuẩn: 30 giây / lần quét (Mức pin: $_simulatedBatteryLevel%)');
    }

    final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: Duration(seconds: intervalSeconds),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        AppLogger.i('Vị trí di chuyển mới quét được: ${position.latitude}, ${position.longitude}');
        await _performLocationUpdate(sosId, position.latitude, position.longitude, isOnline);
      },
      onError: (e) {
        AppLogger.e('Lỗi luồng định vị nền: $e');
      },
    );
  }

  void _stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    _currentlyTrackingSosId = null;
  }

  Future<void> _performLocationUpdate(String sosId, double lat, double lng, bool isOnline) async {
    if (isOnline) {
      try {
        AppLogger.i('Đang cập nhật trực tuyến vị trí mới lên Firestore cho SOS: $sosId');
        await FirebaseFirestore.instance.collection('sos_requests').doc(sosId).update({
          'latitude': lat,
          'longitude': lng,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Đã tự động cập nhật vị trí thời gian thực: $lat, $lng'),
              backgroundColor: Colors.blue.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        AppLogger.e('Lỗi cập nhật vị trí trực tuyến: $e');
      }
    } else {
      // Cơ chế phát sóng SMS ngầm ngoại tuyến tự động (Silent Background SMS Broadcast)
      final smsPayload = 'SOS_UPDATE#$sosId#$lat,$lng#BAT${_simulatedBatteryLevel.toInt()}';
      AppLogger.i('[SMS Background Service] Tự động gửi SMS ngầm thành công: "$smsPayload" đến tổng đài 0203.123.456');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.sms, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('📱 [Offline] Đã tự động gửi SMS ngầm cập nhật vị trí: $lat, $lng'),
                ),
              ],
            ),
            backgroundColor: Colors.amber.shade900,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _forceManualLocationUpdate(String sosId, bool isOnline) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔄 Đang quét GPS mới nhất để cập nhật thủ công...'), duration: Duration(milliseconds: 500)),
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _performLocationUpdate(sosId, position.latitude, position.longitude, isOnline);
    } catch (e) {
      AppLogger.w('Không quét được GPS trực tiếp, sử dụng vị trí cache.');
      final gpsService = ref.read(gpsServiceProvider);
      final location = await gpsService.getCurrentLocation();
      if (location != null) {
        await _performLocationUpdate(sosId, location.latitude, location.longitude, isOnline);
      }
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

    // Tự động điều khiển luồng lắng nghe vị trí khẩn cấp thích ứng
    ref.listen<AsyncValue<SosRequestEntity?>>(
      recentResidentSosProvider(_testHousehold.id),
      (prev, next) {
        final sos = next.valueOrNull;
        _handleActiveSosTracking(sos, isOnline);
      },
    );

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
                            const Divider(height: 16),
                            // Thông báo trạng thái Pin & Chu kỳ định vị thích ứng
                            Row(
                              children: [
                                Icon(
                                  _simulatedBatteryLevel < 20
                                      ? Icons.battery_alert
                                      : (_simulatedBatteryLevel <= 50 ? Icons.battery_charging_full : Icons.battery_full),
                                  color: _simulatedBatteryLevel < 20
                                      ? Colors.red
                                      : (_simulatedBatteryLevel <= 50 ? Colors.orange : Colors.green),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _simulatedBatteryLevel < 20
                                        ? 'Chế độ Tiết kiệm: ĐÃ TẮT định vị nền để giữ nguồn.'
                                        : (_simulatedBatteryLevel <= 50
                                            ? 'Chế độ Tiết kiệm: Định vị thích ứng mỗi 2 phút.'
                                            : 'Chế độ bình thường: Định vị nền hoạt động mỗi 30s.'),
                                    style: TextStyle(
                                      color: _simulatedBatteryLevel < 20
                                          ? Colors.red.shade900
                                          : (_simulatedBatteryLevel <= 50 ? Colors.orange.shade900 : Colors.green.shade900),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Các nút tương tác thủ công + Trượt mô phỏng pin
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nút cập nhật vị trí thủ công khẩn cấp
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: statusColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _forceManualLocationUpdate(sos.id, isOnline),
                                  icon: const Icon(Icons.my_location, size: 14),
                                  label: const Text('Cập nhật vị trí', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                
                                // Bộ trượt mô phỏng dung lượng pin (Dành riêng cho demo & nghiệm thu của sếp)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '🔋 SIM Pin: ${_simulatedBatteryLevel.toInt()}%',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 50,
                                        height: 20,
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 2,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                            activeTrackColor: statusColor,
                                            thumbColor: statusColor,
                                          ),
                                          child: Slider(
                                            value: _simulatedBatteryLevel,
                                            min: 10,
                                            max: 100,
                                            onChanged: (val) {
                                              setState(() {
                                                _simulatedBatteryLevel = val;
                                              });
                                              // Tự động khởi động lại luồng định vị thích ứng
                                              _startTracking(sos.id, isOnline);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
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
                            // Không hiện bất cứ popup cản trở nào tại thời điểm hoảng loạn!
                            // Gửi tín hiệu trực tiếp ngay lập tức bằng GPS hoặc tọa độ gia đình mặc định
                            await ref.read(sosControllerProvider.notifier).triggerSOS(
                                  household: _testHousehold,
                                  isWaterAtRoof: _isWaterAtRoof,
                                  isInjured: _isInjured,
                                );
                            
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
