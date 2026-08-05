import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/notification/providers/notification_provider.dart';
import 'package:disaster_rescue/data/models/notification_model.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const NotificationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends ConsumerState<NotificationDetailScreen> {
  bool _showTayLanguage = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final notification = state.notifications.firstWhere((n) => n.id == widget.id, 
        orElse: () => NotificationModel(
          id: 'error',
          title: 'Lỗi',
          body: 'Không tìm thấy thông báo',
          type: NotificationType.info,
          priority: NotificationPriority.info,
          createdAt: DateTime.now(),
        ));

    if (notification.id == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy thông báo')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(notification),
            const SizedBox(height: AppSpacing.lg),
            _buildContentSection(notification),
            if (notification.shelterInfo != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildShelterInfoCard(notification.shelterInfo!),
            ],
            if (notification.targetLocation != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildMiniMap(),
            ],
            if (notification.requiredItems != null && notification.requiredItems!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildRequiredItems(notification.requiredItems!),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(context, notification),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(NotificationModel notification) {
    Color headerColor;
    switch (notification.priority) {
      case NotificationPriority.urgent:
        headerColor = AppColors.priorityHigh;
        break;
      case NotificationPriority.warning:
        headerColor = AppColors.priorityOrange;
        break;
      case NotificationPriority.info:
        headerColor = AppColors.infoBlue;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_rounded, color: headerColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Từ Ban Chỉ huy PCTT Xã',
                style: TextStyle(
                  fontSize: 12,
                  color: headerColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            notification.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: headerColor,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('HH:mm - dd/MM/yyyy').format(notification.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(NotificationModel notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung chi tiết',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          notification.body,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.5,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        
        // Hỗ trợ tiếng Tày (Collapse) - FR-15.2
        if (notification.bodyTay != null && notification.bodyTay!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => setState(() => _showTayLanguage = !_showTayLanguage),
            child: Row(
              children: [
                Icon(
                  _showTayLanguage ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                const Text(
                  'Xem bằng tiếng Tày (Tay language)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          if (_showTayLanguage) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                notification.bodyTay!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildShelterInfoCard(ShelterInfo shelter) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.maps_home_work_rounded, color: AppColors.infoBlue),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Điểm sơ tán: ${shelter.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sức chứa: ${shelter.currentOccupancy} / ${shelter.capacity} người',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Vật tư có sẵn:', style: TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8,
            children: shelter.availableSupplies.map((s) => Chip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.infoBlue.withValues(alpha: 0.1),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, size: 40, color: AppColors.textDisabled),
            SizedBox(height: 8),
            Text('Bản đồ định tuyến (Demo)', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredItems(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cần mang theo:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.priorityOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.priorityOrange),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.priorityOrange),
                const SizedBox(width: 4),
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.priorityOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, NotificationModel notification) {
    if (notification.type == NotificationType.evacuationOrder) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xác nhận sơ tán thành công!')),
                );
                context.pop();
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('TÔI ĐÃ ĐẾN ĐIỂM SƠ TÁN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSafe,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/home'); // Quay lại trang chủ để dùng SOS
              },
              icon: const Icon(Icons.sos_rounded, color: AppColors.priorityHigh),
              label: const Text(
                'TÔI KHÔNG THỂ SƠ TÁN (GỬI SOS)',
                style: TextStyle(color: AppColors.priorityHigh),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.priorityHigh),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
            ),
          ),
        ],
      );
    }
    
    // Nút mặc định cho các loại khác
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        child: const Text('ĐÃ HIỂU'),
      ),
    );
  }
}
