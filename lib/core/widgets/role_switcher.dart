import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TestRoleSwitcherDrawer extends StatelessWidget {
  const TestRoleSwitcherDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFD32F2F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'BỘ CHUYỂN VAI TRÒ',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Môi trường kiểm thử đa thiết bị',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Hộ Dân (Resident SOS)'),
            onTap: () {
              Navigator.pop(context);
              context.go('/resident');
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('Admin Xã (Realtime Dashboard)'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.green),
            title: const Text('Đội Cứu Hộ (Rescue Team)'),
            onTap: () {
              Navigator.pop(context);
              context.go('/rescue');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.orange),
            title: const Text('Bảng Tình Hình (Công Khai)'),
            onTap: () {
              Navigator.pop(context);
              context.go('/situation-board');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.grey),
            title: const Text('Đổi Vai Trò / Đăng Nhập'),
            onTap: () {
              Navigator.pop(context);
              context.go('/select-role');
            },
          ),
        ],
      ),
    );
  }
}
