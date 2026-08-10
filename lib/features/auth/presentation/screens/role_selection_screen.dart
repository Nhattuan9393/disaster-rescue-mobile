import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thẻ ghi chú màu xanh dương (Chuẩn Ảnh 1 Prototype s03)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'ℹ️ Màn này CHỈ hiện khi user có ≥2 vai trò. Có 1 vai trò ➔ vào thẳng màn tương ứng.',
                  style: TextStyle(color: Colors.blue.shade900, fontSize: 11, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Tiêu đề chào tên User
              const Text(
                'Xin chào, Nguyễn Văn A!',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bạn có 3 vai trò — chọn vai trò muốn dùng',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // 3. DANH SÁCH THẺ VAI TRÒ (3 VAI TRÒ CHUẨN)
              _buildPrototypeRoleCard(
                context,
                icon: '🏠',
                iconBg: const Color(0xFFD32F2F),
                title: 'Hộ dân',
                subtitle: 'Gửi SOS, xác nhận an toàn cho gia đình',
                route: '/resident',
              ),
              const SizedBox(height: 12),

              _buildPrototypeRoleCard(
                context,
                icon: '🏛️',
                iconBg: Colors.blue.shade900,
                title: 'Admin phụ — Trưởng thôn',
                subtitle: 'Điều phối cứu hộ trong thôn Pắc Liềng',
                route: '/admin',
              ),
              const SizedBox(height: 12),

              _buildPrototypeRoleCard(
                context,
                icon: '⛑️',
                iconBg: Colors.green.shade800,
                title: 'Đội Cứu hộ',
                subtitle: 'Dân quân thôn — nhận nhiệm vụ',
                route: '/rescue',
              ),
              const SizedBox(height: 24),

              // 4. Thẻ ghi chú màu cam (Situation Board KHÔNG phải vai trò)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Situation Board KHÔNG phải vai trò',
                      style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Đó là trang công khai không cần đăng nhập — điểm vào ở màn Đăng nhập và mục Hồ sơ.',
                      style: TextStyle(color: Colors.black87, fontSize: 10.5, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrototypeRoleCard(
    BuildContext context, {
    required String icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
