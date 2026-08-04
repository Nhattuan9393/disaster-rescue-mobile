import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/evacuation_models.dart';
import '../../providers/evacuation_provider.dart';
import 'evacuation_detail_screen.dart';

class EvacuationListScreen extends ConsumerWidget {
  const EvacuationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(evacuationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Điểm Sơ Tán'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // TOP: Mock map area
          Container(
            height: 200,
            width: double.infinity,
            color: const Color.fromRGBO(33, 33, 33, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Bản đồ Điểm Sơ Tán',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          // BOTTOM: Expanded ListView of evacuation points
          Expanded(
            child: state.points.isEmpty
                ? Center(
                    child: Text(
                      'Không có điểm sơ tán nào.',
                      style: AppTypography.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.points.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final point = state.points[index];
                      return _buildEvacuationCard(context, point);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng thêm điểm sơ tán đang phát triển'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm điểm sơ tán'),
      ),
    );
  }

  Widget _buildEvacuationCard(BuildContext context, EvacuationPoint point) {
    Color statusColor;
    String statusText;
    
    switch (point.status) {
      case EvacuationPointStatus.open:
        statusColor = AppColors.statusSafe;
        statusText = 'Đang mở';
        break;
      case EvacuationPointStatus.full:
        statusColor = AppColors.priorityRed;
        statusText = 'Đã đầy';
        break;
      case EvacuationPointStatus.damaged:
        statusColor = AppColors.priorityOrange;
        statusText = 'Hư hỏng';
        break;
      case EvacuationPointStatus.closed:
        statusColor = AppColors.textDisabled;
        statusText = 'Đã đóng';
        break;
    }

    final double ratio = point.maxCapacity > 0
        ? point.currentOccupancy / point.maxCapacity
        : 0;
    final progressColor = ratio >= 1.0 ? AppColors.priorityRed : AppColors.statusSafe;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    point.name,
                    style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    statusText,
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${point.currentOccupancy}/${point.maxCapacity} người',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: AppColors.background,
                color: progressColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    point.supplies.isEmpty
                        ? 'Không có nhu yếu phẩm'
                        : point.supplies.join(', '),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${point.managerName} - ${point.managerPhone}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvacuationDetailScreen(pointId: point.id),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                child: const Text('Cập nhật tình trạng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
