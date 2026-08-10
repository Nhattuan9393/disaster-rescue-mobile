import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: '0987 654 321');
  final _passwordCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final input = _usernameCtrl.text.trim().toLowerCase();

    // Logic Phân Quyền Vai Trò Theo Prototype s02/s03:
    if (input == 'admin' || input == '0912111222') {
      // 1 vai trò: Admin Xã -> Vào thẳng Dashboard Admin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('🏛️ Đăng nhập thành công Admin Ban Chỉ Huy Xã!'), backgroundColor: Colors.blue.shade900),
      );
      context.go('/admin');
    } else if (input == 'truongthon' || input == '0987654321' || input.contains('nha')) {
      // >= 2 vai trò: Trưởng thôn (Hộ dân + Admin phụ + Dân quân) -> Mở màn 03 Chọn vai trò
      context.push('/select-role');
    } else if (input == 'dq01' || input.contains('cuuho')) {
      // 1 vai trò: Đội Cứu Hộ Thường Trực -> Vào thẳng màn Đội cứu hộ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('⛑️ Đăng nhập thành công Đội Cứu Hộ Thường Trực!'), backgroundColor: Colors.green.shade800),
      );
      context.go('/rescue');
    } else {
      // 1 vai trò: Hộ Dân -> Vào thẳng Trang chủ Hộ Dân
      context.go('/resident');
    }
  }

  void _showMtqQrPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_2, color: Color(0xFFD32F2F), size: 26),
                      SizedBox(width: 8),
                      Text('Đăng ký MTQ Tại Chỗ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '📍 Trạm Tiếp Nhận: UBND Xã Bình Liêu — Cổng Trợ Cứu Số 1',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ),
              const SizedBox(height: 16),

              // Khung Mã QR mẫu sắc nét có Logo ở trung tâm
              Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Giả lập mã QR với các nét ô đốm chuẩn
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemCount: 49,
                      itemBuilder: (context, index) {
                        final isCorner = index == 0 || index == 1 || index == 7 || index == 8 ||
                            index == 5 || index == 6 || index == 12 || index == 13 ||
                            index == 35 || index == 36 || index == 42 || index == 43;
                        final isCenter = index >= 20 && index <= 28;
                        if (isCenter) return const SizedBox.shrink();
                        return Container(
                          decoration: BoxDecoration(
                            color: isCorner ? const Color(0xFFD32F2F) : ((index * 7) % 3 == 0 ? Colors.black87 : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                    // Logo trung tâm QR
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Mã QR dán sẵn tại điểm tiếp nhận xã.\nBấm nút bên dưới để mở ngay form khai báo MTQ / Đội cứu hộ vãng lai.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/volunteer-register');
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                  label: const Text(
                    '📱 QUÉT / MỞ FORM ĐĂNG KÝ MTQ NGAY',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Cụm Logo SOS vuông đỏ căn giữa (Chuẩn Ảnh 3 Prototype s02)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 2.5),
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tên ứng dụng
                const Text(
                  'DisasterRescue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề & Subtitle căn giữa
                const Text(
                  'Đăng nhập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đăng nhập để gửi SOS và nhận cảnh báo sớm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. FORM ĐĂNG NHẬP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SỐ ĐIỆN THOẠI HOẶC EMAIL',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(
                        hintText: '0987 654 321',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'MẬT KHẨU',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey, size: 20),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. NÚT ĐĂNG NHẬP CHÍNH (ĐỎ)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _submitLogin,
                    child: const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 4. NÚT VIỀN XANH: Xem tình hình thiên tai (không cần đăng nhập)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/situation-board'),
                    icon: Icon(Icons.visibility, color: Colors.blue.shade800, size: 18),
                    label: Text(
                      '👁️ Xem tình hình thiên tai (không cần đăng nhập)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. CÁC LINK ĐĂNG KÝ MÀU ĐỎ
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/register-household'),
                      child: const Text(
                        'Đăng ký hộ dân',
                        style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('·', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: _showMtqQrPopup,
                      child: const Text(
                        'Đăng ký đội cứu hộ / MTQ (Mã QR)',
                        style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
