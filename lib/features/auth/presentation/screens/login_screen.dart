import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _residentPhoneCtrl = TextEditingController(text: '0912.345.678');
  final _teamIdCtrl = TextEditingController(text: 'DQ01');
  final _teamPhoneCtrl = TextEditingController(text: '0912.111.222');
  final _adminUserCtrl = TextEditingController(text: 'admin');
  final _adminPassCtrl = TextEditingController(text: '123456');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _residentPhoneCtrl.dispose();
    _teamIdCtrl.dispose();
    _teamPhoneCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  void _loginResident() {
    context.go('/resident');
  }

  void _loginRescueTeam() {
    context.go('/rescue');
  }

  void _loginAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🏛️ Đăng nhập thành công với vai trò Admin Ban chỉ huy Xã!'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
    context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'CỨU HỘ THIÊN TAI XÃ BÌNH LIÊU',
                          style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                        Text(
                          'Đăng nhập Hệ thống',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFD32F2F),
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                indicatorColor: const Color(0xFFD32F2F),
                tabs: const [
                  Tab(text: '🏠 Hộ Dân'),
                  Tab(text: '⛑️ Đội Tác Chiến'),
                  Tab(text: '🏛️ Admin Xã'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildResidentTab(),
                  _buildRescueTeamTab(),
                  _buildAdminTab(),
                ],
              ),
            ),

            // Bottom Action for Public Situation Board
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange.shade800, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/situation-board'),
                  icon: Icon(Icons.bar_chart, color: Colors.orange.shade900),
                  label: Text(
                    '📊 XEM BẢNG TÌNH HÌNH CÔNG KHAI (KHÔNG CẦN ĐĂNG NHẬP)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 11.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Số điện thoại hoặc Mã hộ dân *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: _residentPhoneCtrl,
            decoration: InputDecoration(
              hintText: 'Nhập SĐT (0912...) hoặc Mã hộ (HH100)',
              prefixIcon: const Icon(Icons.phone_android, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loginResident,
              child: const Text('ĐĂNG NHẬP VAI TRÒ HỘ DÂN ➔', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng liên hệ Trưởng thôn hoặc Cán bộ Xã để khai báo hộ dân mới.')),
                );
              },
              child: const Text('Chưa có mã hộ? Đăng ký thông tin Hộ dân mới', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescueTeamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mã Đội Cứu Hộ Thường Trực *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: _teamIdCtrl,
            decoration: InputDecoration(
              hintText: 'VD: DQ01 (Dân quân 1)',
              prefixIcon: const Icon(Icons.badge, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          const Text('Số điện thoại Đội trưởng *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: _teamPhoneCtrl,
            decoration: InputDecoration(
              hintText: 'Nhập SĐT Đội trưởng',
              prefixIcon: const Icon(Icons.phone, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loginRescueTeam,
              child: const Text('ĐĂNG NHẬP ĐỘI CỨU HỘ THƯỜNG TRỰC ➔', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 16),

          // Link đăng ký đội vãng lai
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🚚 Bạn là Đoàn Cứu Hộ Tình Nguyện / Vãng Lai?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 11.5)),
                const SizedBox(height: 4),
                const Text('Vui lòng nộp đơn đăng ký phương tiện và vật tư mang theo để Ban chỉ huy Xã duyệt phân vùng.', style: TextStyle(fontSize: 10.5, color: Colors.black87)),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => context.push('/volunteer-register'),
                  child: Text('➔ Đăng ký Đội Cứu Hộ Vãng Lai Khẩn Cấp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 11.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade900, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tài khoản mặc định Ban Chỉ Huy Xã: admin / 123456',
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Tài khoản Admin *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: _adminUserCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          const Text('Mật khẩu *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: _adminPassCtrl,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loginAdmin,
              child: const Text('🔑 ĐĂNG NHẬP BAN CHỈ HUY XÃ ➔', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
