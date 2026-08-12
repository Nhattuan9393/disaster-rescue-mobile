import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/hive_service.dart';
import '../services/api_sync_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showHiveInspector(BuildContext context) {
    // Đọc dữ liệu thực tế từ các hộp Hive
    final sosBox = HiveService.getSosQueueBox();
    final gpsBox = HiveService.getGpsCacheBox();
    final reportBox = HiveService.getReportQueueBox();

    final List<MapEntry<dynamic, dynamic>> sosEntries = sosBox.toMap().entries.toList();
    final List<MapEntry<dynamic, dynamic>> gpsEntries = gpsBox.toMap().entries.toList();
    final List<MapEntry<dynamic, dynamic>> reportEntries = reportBox.toMap().entries.toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.storage, color: Color(0xFFD32F2F), size: 24),
            SizedBox(width: 8),
            Text('Nhật Ký Bộ Nhớ Hive (Local)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dưới đây là dữ liệu thô hiện đang được lưu trữ cục bộ trong bộ nhớ ẩn (Hive Box) của thiết bị này:',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // 1. SOS QUEUE BOX
                _buildHiveBoxSection(
                  title: '📦 Hàng đợi SOS (sos_queue)',
                  count: sosEntries.length,
                  entries: sosEntries,
                ),
                const Divider(),

                // 2. GPS CACHE BOX
                _buildHiveBoxSection(
                  title: '📍 Bộ nhớ vị trí GPS (gps_cache)',
                  count: gpsEntries.length,
                  entries: gpsEntries,
                ),
                const Divider(),

                // 3. REPORT QUEUE BOX
                _buildHiveBoxSection(
                  title: '📝 Báo cáo thiên tai (report_queue)',
                  count: reportEntries.length,
                  entries: reportEntries,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await sosBox.clear();
              await gpsBox.clear();
              await reportBox.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧹 Đã xóa toàn bộ bộ nhớ Cache Hive thành công!')),
              );
            },
            child: const Text('XÓA HIVE CACHE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildHiveBoxSection({
    required String title,
    required int count,
    required List<MapEntry<dynamic, dynamic>> entries,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
              child: Text('$count bản ghi', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('(Trống — Chưa có dữ liệu lưu trữ)', style: TextStyle(fontSize: 10.5, color: Colors.grey, fontStyle: FontStyle.italic)),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: SingleChildScrollView(
              child: Text(
                entries.map((e) => 'Key: ${e.key}\nVal: ${e.value}').join('\n---\n'),
                style: const TextStyle(fontFamily: 'Courier', fontSize: 9.5, color: Colors.black87),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

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
                  'Hệ thống Điều phối Cứu hộ',
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
            leading: const Icon(Icons.storage, color: Colors.orange),
            title: const Text('Kiểm tra Bộ nhớ Hive (Local)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () {
              Navigator.pop(context);
              _showHiveInspector(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: Colors.blue),
            title: const Text('Buộc Đồng bộ Cloud ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onTap: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔄 Đang đồng bộ hóa dữ liệu lên Cloud...')),
              );
              await ApiSyncService.uploadSosToCloud();
              await ApiSyncService.uploadTeamsToCloud();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Đã hoàn thành đồng bộ đám mây!')),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất khỏi hệ thống', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
