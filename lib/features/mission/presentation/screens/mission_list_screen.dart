import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/priority_badge.dart';
import '../../providers/mission_provider.dart';
import 'mission_detail_screen.dart';

class MissionListScreen extends ConsumerStatefulWidget {
  const MissionListScreen({super.key});

  @override
  ConsumerState<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends ConsumerState<MissionListScreen> {
  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(missionProvider);
    final sosList = List<SosRequest>.from(missionState.sosList)
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhiệm vụ — Khu vực Bình Liêu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // TOP: Mock Map Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              color: const Color(0xFF1E1E1E), // Dark background for map
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bản đồ khu vực',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BOTTOM: DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.bottomSheet,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: sosList.length,
                        itemBuilder: (context, index) {
                          final sos = sosList[index];
                          return _buildSosCard(context, ref, sos);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Báo chướng ngại
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Báo chướng ngại',
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildSosCard(BuildContext context, WidgetRef ref, SosRequest sos) {
    final bool isAssigned = sos.status == SosStatus.assigned;
    final bool canAccept = sos.status == SosStatus.verified || sos.status == SosStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sos.disasterType} - ${sos.village}',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Số người: ${sos.memberCount} | Khoảng cách: ${sos.distanceKm?.toStringAsFixed(1) ?? 'N/A'} km',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PriorityBadge(score: sos.priorityScore),
              ],
            ),
            if (sos.vulnerabilities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: sos.vulnerabilities.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBanner.withValues(alpha: 0.2),
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                        color: AppColors.warningBanner,
                      ),
                    ),
                    child: Text(
                      v,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warningBanner,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isAssigned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      '[${sos.assignedTeamName ?? 'Đội khác'} đang đến]',
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (canAccept)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(missionProvider.notifier).acceptMission(
                        sos.id,
                        'TEAM-CURRENT',
                        'Đội của tôi',
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MissionDetailScreen(sosId: sos.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.chip,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TÔI ĐI'),
                        SizedBox(width: AppSpacing.xs),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
