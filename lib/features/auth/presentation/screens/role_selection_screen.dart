import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🆘', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CỨU HỘ THIÊN TAI XÃ',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'Xã Bình Liêu — Quảng Ninh',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'ĐĂNG NHẬP / CHỌN VAI TRÒ',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Vui lòng chọn vai trò thao tác trên thiết bị này:',
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Card 1: Hộ Dân
              _buildRoleCard(
                context,
                icon: '🏠',
                color: const Color(0xFFC62828),
                title: 'Hộ Dân (Resident SOS)',
                subtitle: 'Gửi tin cứu hộ SOS khẩn cấp, báo tin cứu trợ, xem vị trí điểm sơ tán & điểm danh an toàn.',
                route: '/resident',
              ),
              const SizedBox(height: 12),

              // Card 2: Admin Xã
              _buildRoleCard(
                context,
                icon: '🏛️',
                color: Colors.blue.shade900,
                title: 'Admin Xã — Ban Chỉ Huy',
                subtitle: 'Theo dõi bản đồ SOS thời gian thực, điều phối đội cứu hộ, gộp tin báo trùng & phát lệnh sơ tán Tiếng Tày.',
                route: '/admin',
              ),
              const SizedBox(height: 12),

              // Card 3: Đội Cứu Hộ
              _buildRoleCard(
                context,
                icon: '⛑️',
                color: Colors.green.shade800,
                title: 'Đội Cứu Hộ (Rescue Team)',
                subtitle: 'Dân quân thôn & Tổ xung kích, tiếp nhận nhiệm vụ, bấm "Tôi đi", định vị GPS & báo hoàn thành.',
                route: '/rescue',
              ),
              const SizedBox(height: 12),

              // Card 4: Bảng Tình Hình (Công Khai)
              _buildRoleCard(
                context,
                icon: '📊',
                color: Colors.orange.shade900,
                title: 'Bảng Tình Hình Thiên Tai (Công Khai)',
                subtitle: 'Xem 6 chỉ số tuyệt đối lũ lụt toàn xã, nhu cầu tiếp tế khẩn cấp (Không cần đăng nhập).',
                route: '/situation-board',
              ),
              const SizedBox(height: 24),

              // Informational Banner for Multi-device Testing
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.devices, color: Colors.blue, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔥 Hỗ trợ Kiểm thử Liên thông 3 Thiết bị',
                            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mở App trên 3 thiết bị khác nhau (hoặc 3 tab trình duyệt): Thiết bị 1 mở Hộ Dân, Thiết bị 2 mở Admin, Thiết bị 3 mở Đội Cứu Hộ để test đồng bộ thời gian thực qua Firebase.',
                            style: TextStyle(color: Colors.black87, fontSize: 10.5, height: 1.3),
                          ),
                        ],
                      ),
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

  Widget _buildRoleCard(
    BuildContext context, {
    required String icon,
    required Color color,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
