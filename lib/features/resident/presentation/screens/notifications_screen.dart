import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../notification/data/notification_inbox_service.dart';
import '../../../notification/domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(myNotificationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thông Báo & Chỉ Thị',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      body: notifsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có thông báo nào.\nMọi cảnh báo, lệnh sơ tán, cập nhật SOS sẽ hiển thị tại đây.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) => _NotificationCard(item: list[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Không tải được thông báo: $e',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  const _NotificationCard({required this.item});

  ({IconData icon, Color color, Color bg}) _visualFor(AppNotificationKind k) {
    switch (k) {
      case AppNotificationKind.evacuationOrder:
        return (
          icon: Icons.campaign,
          color: const Color(0xFFD32F2F),
          bg: const Color(0xFFFFEBEE),
        );
      case AppNotificationKind.sosCreated:
      case AppNotificationKind.sosAssigned:
        return (
          icon: Icons.healing,
          color: Colors.orange.shade800,
          bg: Colors.orange.shade50,
        );
      case AppNotificationKind.sosInProgress:
        return (
          icon: Icons.directions_run,
          color: Colors.blue.shade800,
          bg: Colors.blue.shade50,
        );
      case AppNotificationKind.sosCompleted:
        return (
          icon: Icons.check_circle,
          color: Colors.green.shade700,
          bg: Colors.green.shade50,
        );
      case AppNotificationKind.reliefIncoming:
        return (
          icon: Icons.local_shipping,
          color: Colors.blue.shade800,
          bg: Colors.blue.shade50,
        );
      case AppNotificationKind.safetyRequest:
        return (
          icon: Icons.verified_user,
          color: Colors.teal.shade700,
          bg: Colors.teal.shade50,
        );
      case AppNotificationKind.other:
        return (
          icon: Icons.notifications,
          color: Colors.grey.shade700,
          bg: Colors.grey.shade100,
        );
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final v = _visualFor(item.kind);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.actionRoute == null
            ? null
            : () => context.push(item.actionRoute!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: v.bg, shape: BoxShape.circle),
                child: Icon(v.icon, color: v.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          _timeAgo(item.createdAt),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87, height: 1.4),
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
}
