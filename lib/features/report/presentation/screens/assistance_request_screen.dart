import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../household/data/household_repository.dart';
import '../providers/report_provider.dart';

class AssistanceRequestScreen extends ConsumerStatefulWidget {
  const AssistanceRequestScreen({super.key});

  @override
  ConsumerState<AssistanceRequestScreen> createState() => _AssistanceRequestScreenState();
}

class _AssistanceRequestScreenState extends ConsumerState<AssistanceRequestScreen> {
  // Trạng thái chọn nhu cầu hỗ trợ
  final List<String> _selectedSupports = [];
  final List<String> _supportOptions = [
    '🚗 Xe chở người',
    '💪 Người khiêng đồ',
    '💊 Thuốc men',
    '🔨 Gia cố nhà',
    '🍚 Lương thực',
  ];

  // Trạng thái chọn thời gian khẩn cấp
  String _urgencyWindow = 'Trong 3h'; // default

  // Ghi chú thêm
  final TextEditingController _noteController = TextEditingController();

  // Điểm sơ tán được chọn
  String? _selectedEvacPoint;
  final List<Map<String, dynamic>> _defaultEvacPoints = [
    {'id': 'evac_01', 'name': 'Trường TH Bình Liêu — Còn 155 chỗ'},
    {'id': 'evac_02', 'name': 'Nhà văn hóa Thôn Pắc Liềng — Còn 80 chỗ'},
    {'id': 'evac_03', 'name': 'Trung tâm Y tế huyện — Còn 30 chỗ'},
  ];
  List<Map<String, dynamic>> _evacPoints = [];

  @override
  void initState() {
    super.initState();
    _evacPoints = List.from(_defaultEvacPoints);
    _loadDynamicEvacPoints();
  }

  Future<void> _loadDynamicEvacPoints() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('evacuation_points').get();
      if (snapshot.docs.isNotEmpty) {
        final dynamicPoints = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': '${data['name']} — Còn ${data['availableSlots'] ?? 100} chỗ',
          };
        }).toList();
        
        final dynamicIds = dynamicPoints.map((e) => e['id'] as String).toSet();
        final uniqueDefault = _defaultEvacPoints.where((e) => !dynamicIds.contains(e['id'])).toList();

        setState(() {
          _evacPoints = [...uniqueDefault, ...dynamicPoints];
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitAssistance() async {
    if (_selectedSupports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một nhu cầu hỗ trợ!'), backgroundColor: Colors.red),
      );
      return;
    }

    final isOnline = ref.read(isOnlineProvider);
    final controller = ref.read(reportControllerProvider.notifier);
    final user = ref.read(currentUserProvider);
    final household = ref.read(myHouseholdStreamProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đăng nhập trước khi gửi yêu cầu.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    await controller.submitAssistanceRequest(
      householdId: household?.id ?? user.householdId ?? user.uid,
      reporterId: user.uid,
      latitude: household?.latitude ?? 21.5412,
      longitude: household?.longitude ?? 107.3985,
      address: household?.address ?? 'Thôn Pắc Liềng, xã Bình Liêu',
      description: _noteController.text.trim(),
      neededSupports: _selectedSupports,
      urgencyWindow: _urgencyWindow,
      targetEvacuationPointId: _selectedEvacPoint,
      confidenceScore: 100,
    );

    final state = ref.read(reportControllerProvider);
    if (state.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOnline 
                ? 'Đã gửi yêu cầu hỗ trợ thành công!' 
                : 'Đã lưu yêu cầu offline. Sẽ đồng bộ khi có kết nối!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportControllerProvider);
    final isOnline = ref.watch(isOnlineProvider);

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
          'Cần hỗ trợ sơ tán',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Cảnh báo mất mạng
          if (!isOnline)
            Container(
              color: const Color(0xFFFFF9C4),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Không có mạng — Sẽ lưu offline và tự động gửi sau',
                    style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thẻ cảnh báo không phải SOS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ ĐÂY KHÔNG PHẢI SOS',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Yêu cầu này dành cho tình huống còn thời gian (tính bằng giờ). Nếu nhà bạn đang nguy hiểm NGAY BÂY GIỜ → quay lại bấm nút SOS đỏ.',
                          style: TextStyle(color: Colors.black87, fontSize: 11.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Nhu cầu hỗ trợ
                  const Text(
                    'CẦN HỖ TRỢ GÌ?',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _supportOptions.map((opt) {
                      final isSel = _selectedSupports.contains(opt);
                      return FilterChip(
                        label: Text(opt, style: const TextStyle(fontSize: 12)),
                        selected: isSel,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSupports.add(opt);
                            } else {
                              _selectedSupports.remove(opt);
                            }
                          });
                        },
                        selectedColor: Colors.orange.shade100,
                        checkmarkColor: Colors.orange.shade800,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 3. Thông tin hộ (Lấy từ hồ sơ hộ dân giả lập)
                  const Text(
                    'AI CẦN HỖ TRỢ? (LẤY TỪ HỒ SƠ HỘ)',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hộ Nguyễn Văn A — Thôn Pắc Liềng',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: const [
                            Chip(label: Text('👥 5 người', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                            Chip(label: Text('👴 Cụ ông 85t liệt giường', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                            Chip(label: Text('👶 2 trẻ em', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Khi nào cần
                  const Text(
                    'KHI NÀO CẦN?',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Trong 1h', 'Trong 3h', 'Trước tối nay'].map((time) {
                      final isSel = _urgencyWindow == time;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _urgencyWindow = time),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.orange.shade700 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? Colors.orange.shade700 : Colors.grey.shade300),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 5. Điểm sơ tán muốn đến
                  const Text(
                    'ĐIỂM SƠ TÁN MUỐN ĐẾN',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedEvacPoint,
                        hint: const Text('Chọn điểm sơ tán mong muốn', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        isExpanded: true,
                        items: _evacPoints.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['id'] as String,
                            child: Text(item['name'] as String, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedEvacPoint = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 6. Ghi chú thêm
                  const Text(
                    'GHI CHÚ THÊM',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Mô tả thêm khó khăn về xe cộ, người khiêng hay nhu yếu phẩm...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 7. Soft Blue Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🕐 Xã sẽ phản hồi trong vòng 3 giờ',
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tạo AssistanceRequest — hàng đợi riêng, không lẫn vào hàng đợi SOS đỏ.',
                          style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút gửi
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: state.isLoading ? null : _submitAssistance,
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GỬI YÊU CẦU HỖ TRỢ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
