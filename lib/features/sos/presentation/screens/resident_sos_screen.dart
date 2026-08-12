import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../household/domain/household_model.dart';
import '../providers/sos_controller.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_status.dart';

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
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final sosState = ref.watch(sosControllerProvider);
    final recentSosAsync = ref.watch(recentResidentSosProvider(_testHousehold.id));

    // Xử lý thông báo
    ref.listen<SosState>(sosControllerProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
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
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF5350),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.campaign, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CẢNH BÁO & LỆNH SƠ TÁN — Thôn Pắc Liềng',
                                  style: TextStyle(
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Chạm để xem chi tiết lệnh sơ tán & chỉ đường ➔',
                                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Bản đồ nhỏ dạng thẻ
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/evacuation-points'),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Nhà tôi 📍 - Điểm sơ tán 🏫 - Đội cứu hộ 👮',
                              style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  // NÚT BẤM SOS KHỔNG LỒ KIỂU MOCKUP
                  GestureDetector(
                    onTap: sosState.isLoading
                        ? null
                        : () {
                            ref.read(sosControllerProvider.notifier).triggerSOS(
                                  household: _testHousehold,
                                  isWaterAtRoof: _isWaterAtRoof,
                                  isInjured: _isInjured,
                                );
                          },
                    child: Container(
                      height: 220,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'S O S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'BẤM ĐỂ GỬI NGAY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
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

                  // Realtime SOS status tracker
                  recentSosAsync.when(
                    data: (sos) {
                      if (sos == null) return const SizedBox.shrink();

                      Color statusColor;
                      switch (sos.status) {
                        case SosStatus.pending:
                          statusColor = Colors.red;
                          break;
                        case SosStatus.assigned:
                          statusColor = Colors.orange;
                          break;
                        case SosStatus.inProgress:
                          statusColor = Colors.blue;
                          break;
                        case SosStatus.completed:
                          statusColor = Colors.green;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
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
                                Icon(Icons.circle, color: statusColor, size: 12),
                                const SizedBox(width: 8),
                                Text(
                                  'Trạng thái: ${sos.status.name.toUpperCase()}',
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Mã SOS: ${sos.id.substring(0, 8)} | Điểm khẩn cấp: ${sos.priorityScore}'),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

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
                          onTap: () async {
                            try {
                              // Hiển thị thông báo phản hồi tức thì
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Đã báo cho xã: Hộ gia đình của bạn vẫn an toàn!'),
                                    backgroundColor: Colors.green,
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
