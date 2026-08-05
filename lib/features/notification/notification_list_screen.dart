import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/notification/providers/notification_provider.dart';
import 'package:disaster_rescue/data/models/notification_model.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (notifier.unreadCount > 0)
            TextButton(
              onPressed: () {
                notifier.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
                );
              },
              child: const Text('Đánh dấu tất cả đã đọc'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Bạn không có thông báo nào.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _buildNotificationCard(context, notification, ref);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification, WidgetRef ref) {
    final bool isUnread = !notification.isRead;
    
    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.weatherAlert:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.priorityOrange;
        break;
      case NotificationType.evacuationOrder:
        icon = Icons.directions_run_rounded;
        iconColor = AppColors.priorityRed; // Red
        break;
      case NotificationType.mySosStatus:
        icon = Icons.local_hospital_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.reliefDistribution:
        icon = Icons.inventory_2_rounded;
        iconColor = AppColors.infoBlue;
        break;
    }

    return GestureDetector(
      onTap: () {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
        context.push('/notifications/${notification.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            fontFamily: AppTypography.fontFamily,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
