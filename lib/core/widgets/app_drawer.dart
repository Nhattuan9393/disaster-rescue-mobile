import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'DisasterRescue',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hệ thống Chỉ Huy Cứu Hộ',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(4)),
                  child: const Text(
                    '● THỜI GIAN THỰC (CLOUDSYNC)',
                    style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text('Bản đồ chiến sự / SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows, color: Colors.teal),
            title: const Text('Đối chiếu danh sách hộ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.push('/cross-check');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.indigo),
            title: const Text('Quản lý lực lượng cứu hộ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.push('/rescue-teams');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.orange),
            title: const Text('Quản lý kho hàng & hàng hóa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.push('/warehouse');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.deepOrange),
            title: const Text('Phát lệnh sơ tán khẩn cấp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.push('/broadcast-evacuation');
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.brown),
            title: const Text('Import danh sách dân cư', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              context.push('/bulk-import');
            },
          ),
          
          const Spacer(),
          const Divider(),
          Consumer(
            builder: (context, ref, _) => ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất khỏi hệ thống',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
