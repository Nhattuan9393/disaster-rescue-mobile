import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class VolunteerRegistrationScreen extends ConsumerStatefulWidget {
  const VolunteerRegistrationScreen({super.key});

  @override
  ConsumerState<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends ConsumerState<VolunteerRegistrationScreen> with SingleTickerProviderStateMixin {
  // Wizard steps: 0 = Select Type, 1 = QR Scanning, 2 = Registration Form
  int _currentStep = 0;
  String? _registrationType; // 'local' or 'remote'
  bool _isScanning = false;
  double _laserPosition = 0.0;
  Timer? _laserTimer;
  Timer? _scanTimer;

  final _orgCtrl = TextEditingController(text: 'Hội Chữ thập đỏ Hạ Long');
  final _leaderCtrl = TextEditingController(text: 'Nguyễn Văn Hùng');
  final _phoneCtrl = TextEditingController(text: '0912888777');
  final _passwordCtrl = TextEditingController(text: '12345');
  final _membersCtrl = TextEditingController(text: '15');
  final _arrivalTimeCtrl = TextEditingController(text: '11:30 hôm nay');

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _laserTimer?.cancel();
    _scanTimer?.cancel();
    _orgCtrl.dispose();
    _leaderCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _membersCtrl.dispose();
    _arrivalTimeCtrl.dispose();
    super.dispose();
  }

  void _startQRScan() {
    setState(() {
      _currentStep = 1;
      _isScanning = true;
      _laserPosition = 0.0;
    });

    // Animate scanning laser line
    _laserTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        _laserPosition += 0.05;
        if (_laserPosition > 1.0) _laserPosition = 0.0;
      });
    });

    // Auto-success after 2 seconds
    _scanTimer = Timer(const Duration(seconds: 2), () {
      _onScanSuccess();
    });
  }

  void _onScanSuccess() {
    _laserTimer?.cancel();
    _scanTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _currentStep = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_registrationType == 'local'
            ? '📍 Kết nối thành công với Trạm Cứu Hộ Xã Pắc Liềng!'
            : '🌐 Liên kết thành công với Mã Điều Phối Từ Xa!'),
        backgroundColor: Colors.blue.shade900,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    final org = _orgCtrl.text.trim();
    final leader = _leaderCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (org.isEmpty || leader.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vui lòng nhập đầy đủ các thông tin bắt buộc.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    final user = await ref.read(authControllerProvider.notifier).registerVolunteerTeam(
          phoneOrUsername: phone,
          password: password,
          leaderName: leader,
          teamName: org,
        );

    if (!mounted) return;
    Navigator.pop(context); // Pop loading dialog

    if (user != null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Đăng Ký Cứu Hộ Thành Công', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tài khoản Đội Cứu Hộ vãng lai đã được đăng ký và phê duyệt thành công trên hệ thống.\n\nBấm nút dưới đây để về màn hình Đăng nhập.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/login');
              },
              child: const Text('QÚA TRANG ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).error ?? 'Đăng ký cứu hộ thất bại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_currentStep > 0) {
              _laserTimer?.cancel();
              _scanTimer?.cancel();
              setState(() {
                _currentStep--;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _currentStep == 0
              ? 'Đăng Ký Đội Cứu Hộ'
              : _currentStep == 1
                  ? 'Quét Mã QR Đội Cứu Hộ'
                  : 'Khai Báo Đội Cứu Hộ',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSelectionStep();
      case 1:
        return _buildScanningStep();
      case 2:
        return _buildFormStep();
      default:
        return _buildSelectionStep();
    }
  }

  // --- STEP 1: Type Selection ---
  Widget _buildSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chọn hình thức Đăng ký cứu hộ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          const Text(
            'Để phối hợp nhịp nhàng với Ban chỉ huy Xã, vui lòng chọn đúng trạng thái hiện tại của đội.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Option A: Tại Chỗ
          _buildSelectionCard(
            title: 'ĐĂNG KÝ TẠI CHỖ',
            subtitle: 'Đội đã di chuyển đến hiện trường và đang có mặt tại Trạm cứu nạn Pắc Liềng.',
            icon: Icons.qr_code_scanner,
            color: Colors.blue.shade900,
            onTap: () {
              setState(() {
                _registrationType = 'local';
              });
              _startQRScan();
            },
          ),
          const SizedBox(height: 16),

          // Option B: Từ Xa
          _buildSelectionCard(
            title: 'ĐĂNG KÝ TỪ XA',
            subtitle: 'Đội đang chuẩn bị lực lượng, lập danh sách vật tư cứu trợ từ tỉnh/thành phố khác.',
            icon: Icons.sensors,
            color: Colors.green.shade800,
            onTap: () {
              setState(() {
                _registrationType = 'remote';
              });
              _startQRScan();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: color)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.3)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- STEP 2: Scanning Page ---
  Widget _buildScanningStep() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'QUÉT MÃ QR LIÊN KẾT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            _registrationType == 'local'
                ? 'Hãy hướng camera về phía mã QR dán tại Trạm Pắc Liềng'
                : 'Hãy quét mã điều phối để kết nối với trung tâm từ xa',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 40),

          // Scanning Viewport
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Scan Laser
                Positioned(
                  top: 250 * _laserPosition,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: _registrationType == 'local' ? Colors.red : Colors.greenAccent,
                      boxShadow: [
                        BoxShadow(
                          color: (_registrationType == 'local' ? Colors.red : Colors.greenAccent).withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Corner Indicators
                Positioned(
                  top: 20,
                  left: 20,
                  child: Icon(Icons.qr_code, color: Colors.white.withOpacity(0.2), size: 210),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Simulation Tip
          const CircularProgressIndicator(color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            'Hệ thống đang tự động nhận diện mã...',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),

          const SizedBox(height: 20),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _onScanSuccess,
            icon: const Icon(Icons.skip_next),
            label: const Text('Bỏ qua quét nhanh (Test)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: Form Step ---
  Widget _buildFormStep() {
    final isLocal = _registrationType == 'local';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scan Indicator Tag
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocal ? Colors.blue.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isLocal ? Colors.blue.shade200 : Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(isLocal ? Icons.location_on : Icons.wifi_tethering,
                    color: isLocal ? Colors.blue.shade900 : Colors.green.shade900),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isLocal
                        ? '📍 LIÊN KẾT: TRẠM-PẮC-LIỀNG (Đăng ký tại chỗ)'
                        : '🌐 LIÊN KẾT: DP-TỪ-XA-01 (Đăng ký từ xa)',
                    style: TextStyle(
                      color: isLocal ? Colors.blue.shade900 : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('THÔNG TIN ĐỘI CỨU HỘ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),

          _buildInputField('Tên đơn vị / tổ chức *', _orgCtrl, 'VD: Hội Chữ thập đỏ Hạ Long'),
          Row(
            children: [
              Expanded(child: _buildInputField('Trưởng đoàn *', _leaderCtrl, 'VD: Nguyễn Văn Hùng')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField('Số điện thoại *', _phoneCtrl, 'VD: 0912888777')),
            ],
          ),
          _buildPasswordField('Mật khẩu đăng nhập *', _passwordCtrl, '••••••••'),

          Row(
            children: [
              Expanded(child: _buildInputField('Số nhân sự (người) *', _membersCtrl, 'VD: 15')),
              const SizedBox(width: 8),
              Expanded(
                child: isLocal
                    ? const SizedBox()
                    : _buildInputField('Giờ đến dự kiến *', _arrivalTimeCtrl, 'VD: 11:30 hôm nay'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text('Phương tiện cứu hộ sẵn có', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('🚚 Xe tải'), backgroundColor: Color(0xFFE8F5E9)),
              Chip(label: Text('🚤 Thuyền phao')),
              Chip(label: Text('🚑 Xe cấp cứu'), backgroundColor: Color(0xFFE8F5E9)),
              Chip(label: Text('🏍️ Xe máy')),
            ],
          ),

          if (!isLocal) ...[
            const SizedBox(height: 16),
            // Vật tư mang theo (chỉ hiện khi Đăng ký Từ xa)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📦 VẬT TƯ MANG THEO DỰ KIẾN',
                          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(4)),
                        child: const Text('TỰ TÚC', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSupplyHeader(),
                        _buildSupplyRow('Mì tôm', '50', 'thùng'),
                        _buildSupplyRow('Nước suối', '200', 'chai'),
                        _buildSupplyRow('Áo phao cứu trợ', '20', 'cái'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text('Khu vực đăng ký cứu trợ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('Thôn Pắc Liềng'), backgroundColor: Color(0xFFE3F2FD)),
              Chip(label: Text('Thôn Nà Lầu')),
              Chip(label: Text('Bất kỳ đâu cần cứu hộ'), backgroundColor: Color(0xFFE3F2FD)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLocal ? Colors.blue.shade900 : Colors.green.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submit,
              child: Text(
                isLocal ? 'GỬI ĐĂNG KÝ (TẠI CHỖ)' : 'GỬI ĐĂNG KÝ (TỪ XA)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.green.shade100,
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Loại hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
          Expanded(flex: 1, child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
          Expanded(flex: 1, child: Text('Đơn vị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _buildSupplyRow(String name, String qty, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ],
      ),
    );
  }
}
