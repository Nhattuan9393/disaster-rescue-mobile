import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../../core/services/gps_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../providers/report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String initialType; // 'B' (Báo giúp người khác) hoặc 'C' (Báo tình hình)

  const ReportScreen({
    super.key,
    required this.initialType,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _currentStep = 1; // 1: Loại tin, 2: Chi tiết
  late String _reportType; // 'B' hoặc 'C'
  
  // Form fields
  LatLng? _selectedLocation;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedPhotos = []; // Danh sách ảnh giả lập
  
  // GPS của thiết bị dùng tính toán khoảng cách
  LatLng? _userLocation;

  // Điểm Bính Liêu làm mặc định
  final LatLng _defaultCenter = const LatLng(21.5412, 107.3985);

  @override
  void initState() {
    super.initState();
    _reportType = widget.initialType;
    _loadUserGps();
  }

  Future<void> _loadUserGps() async {
    final gps = ref.read(gpsServiceProvider);
    final loc = await gps.getCurrentLocation();
    if (loc != null && mounted) {
      setState(() {
        _userLocation = LatLng(loc.latitude, loc.longitude);
        _selectedLocation ??= _userLocation; // Mặc định marker ở vị trí hiện tại
      });
    } else {
      setState(() {
        _selectedLocation ??= _defaultCenter;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Tính toán mức tin cậy tự động (chỉ cho Flow B)
  int _calculateConfidenceScore() {
    int score = 0;
    // Tự động có 15 điểm nếu có vị trí GPS
    if (_selectedLocation != null) {
      score += 15;
    }
    // Có ảnh hiện trường + 20 điểm
    if (_selectedPhotos.isNotEmpty) {
      score += 20;
    }
    // Mô tả chi tiết dài hơn 15 kí tự + 15 điểm
    if (_descriptionController.text.trim().length > 15) {
      score += 15;
    }
    // Nhập địa chỉ rõ ràng + 10 điểm
    if (_addressController.text.trim().isNotEmpty) {
      score += 10;
    }
    return score;
  }

  void _submitReport() async {
    final isOnline = ref.read(isOnlineProvider);
    final controller = ref.read(reportControllerProvider.notifier);

    final lat = _selectedLocation?.latitude ?? _defaultCenter.latitude;
    final lng = _selectedLocation?.longitude ?? _defaultCenter.longitude;

    if (_reportType == 'B') {
      await controller.submitAssistanceRequest(
        householdId: 'household_other_${DateTime.now().millisecondsSinceEpoch}', // Nạn nhân khác
        reporterId: 'current_user',
        latitude: lat,
        longitude: lng,
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        neededSupports: ['evacuation_assistance'], // Nhu cầu mặc định của Flow B
        urgencyWindow: '3h',
        confidenceScore: _calculateConfidenceScore(),
      );
    } else {
      await controller.submitSituationReport(
        reporterId: 'current_user',
        latitude: lat,
        longitude: lng,
        address: _addressController.text.trim(),
        incidentType: 'landslide', // Mặc định sạt lở hoặc chướng ngại vật
        description: _descriptionController.text.trim(),
        photoUrls: _selectedPhotos,
      );
    }

    // Lắng nghe kết quả gửi
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
                ? 'Đã gửi báo tin thành công!' 
                : 'Đã lưu offline thành công. Sẽ đồng bộ khi có mạng!'),
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
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Báo tin cho xã',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // A. Stepper indicator (1. Loại tin -> 2. Chi tiết)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepBubble(1, 'Loại tin', _currentStep >= 1),
                Container(
                  width: 40,
                  height: 2,
                  color: _currentStep >= 2 ? Colors.blue.shade700 : Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildStepBubble(2, 'Chi tiết', _currentStep >= 2),
              ],
            ),
          ),

          // B. Mất kết nối cảnh báo
          if (!isOnline)
            Container(
              color: const Color(0xFFFFF9C4),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Không có mạng — Báo cáo sẽ được lưu offline và tự đồng bộ',
                    style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // C. Phần nội dung cuộn bên dưới
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),

          // D. Nút hành động chính
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _reportType == 'B' ? Colors.orange.shade800 : Colors.blue.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: state.isLoading 
                    ? null 
                    : () {
                        if (_currentStep == 1) {
                          setState(() => _currentStep = 2);
                        } else {
                          _submitReport();
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentStep == 1 ? 'TIẾP TỤC ➔' : 'GỬI BÁO TIN',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBubble(int stepNum, String title, bool isActive) {
    final color = isActive ? Colors.blue.shade800 : Colors.grey.shade400;
    return Row(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: color,
          child: Text(
            '$stepNum',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12),
        ),
      ],
    );
  }

  // Giao diện Bước 1: Chọn loại tin báo
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card giải thích soft blue
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
                'ℹ️ Màn này dành cho việc của NGƯỜI KHÁC / NƠI KHÁC',
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nhà bạn gặp nguy → dùng nút SOS. Cần xe sơ tán → dùng Cần hỗ trợ sơ tán.',
                style: TextStyle(color: Colors.black87, fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'BƯỚC 1 — CHỌN LOẠI TIN',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),

        // Thẻ Báo giúp người khác (Flow B)
        GestureDetector(
          onTap: () => setState(() => _reportType = 'B'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _reportType == 'B' ? Colors.orange.shade600 : Colors.grey.shade300,
                width: _reportType == 'B' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  radius: 22,
                  child: const Text('👥', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Báo giúp người khác',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hàng xóm, người thân đang gặp nạn → admin xác minh rồi tạo SOS',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _reportType == 'B' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: _reportType == 'B' ? Colors.orange.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Thẻ Báo tình hình khu vực (Flow C)
        GestureDetector(
          onTap: () => setState(() => _reportType = 'C'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _reportType == 'C' ? Colors.blue.shade600 : Colors.grey.shade300,
                width: _reportType == 'C' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 22,
                  child: const Text('📷', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Báo tình hình khu vực',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đường sập, cây đổ, nước dâng, cầu hỏng → KHÔNG tạo SOS',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _reportType == 'C' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: _reportType == 'C' ? Colors.blue.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện Bước 2: Điền thông tin chi tiết
  Widget _buildStep2() {
    final confidenceScore = _calculateConfidenceScore();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BƯỚC 2 — CHI TIẾT (LUỒNG $_reportType)',
          style: TextStyle(
            color: _reportType == 'B' ? Colors.orange.shade800 : Colors.blue.shade800,
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        // 1. Bản đồ chọn vị trí
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                CoreMapWidget(
                  center: _selectedLocation ?? _defaultCenter,
                  zoom: 13,
                  markers: [
                    if (_selectedLocation != null)
                      Marker(
                        point: _selectedLocation!,
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.location_on,
                          color: _reportType == 'B' ? Colors.orange : Colors.blue,
                          size: 32,
                        ),
                      ),
                  ],
                  onTap: (point) {
                    setState(() => _selectedLocation = point);
                  },
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    color: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      _reportType == 'B' 
                          ? '📍 Chạm bản đồ để chọn vị trí NẠN NHÂN' 
                          : '📍 Chạm bản đồ để chọn vị trí SỰ CỐ',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Ô nhập địa chỉ thủ công
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: _addressController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Hoặc nhập địa chỉ: nhà bác Tư, cạnh cây gạo',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Ô mô tả tình huống
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MÔ TẢ TÌNH HUỐNG',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 9),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Mô tả chi tiết để đội cứu hộ nắm rõ tình hình...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Chọn ảnh đính kèm (không bắt buộc)
        const Text(
          'ẢNH ĐÍNH KÈM (KHÔNG BẮT BUỘC)',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 9),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ..._selectedPhotos.map((p) => Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/flood_mock.jpg'), // placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
            GestureDetector(
              onTap: _showPhotoSourceDialog,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 5. Thẻ tính toán độ tin cậy (Chỉ dành cho Flow B)
        if (_reportType == 'B')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mức tin cậy tự tính: $confidenceScore/100',
                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidenceScore / 100.0,
                    minHeight: 7,
                    backgroundColor: Colors.orange.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '+ vị trí GPS (+15) · + mô tả chi tiết (+15) · + ảnh (+20) · + địa chỉ rõ ràng (+10)',
                  style: TextStyle(color: Colors.black54, fontSize: 9.5),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFD32F2F)),
                title: const Text('Ghi hình trực tiếp (Máy ảnh)', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _requestPermissionAndCapture('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Chọn ảnh từ thư viện (Gallery)', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _requestPermissionAndCapture('gallery');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestPermissionAndCapture(String source) {
    final title = source == 'camera'
        ? 'Cho phép DisasterRescue chụp ảnh và ghi video?'
        : 'Cho phép DisasterRescue truy cập vào ảnh và phương tiện?';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Text(
            source == 'camera'
                ? 'Ứng dụng cần quyền sử dụng camera để chụp ảnh thực tế tại hiện trường thiên tai.'
                : 'Ứng dụng cần quyền truy cập album để bạn chọn ảnh đính kèm báo cáo thiên tai.',
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Quyền truy cập bị từ chối. Vui lòng cấp quyền trong Cài đặt.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('TỪ CHỐI', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPhotos.add('photo_${_selectedPhotos.length + 1}');
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(source == 'camera' ? '📷 Đã chụp ảnh thành công!' : '🖼️ Đã chọn ảnh thành công!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('CHO PHÉP', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
