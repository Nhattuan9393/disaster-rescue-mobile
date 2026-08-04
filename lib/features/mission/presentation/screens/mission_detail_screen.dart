import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/mission_provider.dart';
import 'mission_complete_screen.dart';

class MissionDetailScreen extends ConsumerStatefulWidget {
  final String sosId;

  const MissionDetailScreen({
    Key? key,
    required this.sosId,
  }) : super(key: key);

  @override
  ConsumerState<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final activeMission = ref.watch(missionProvider).activeMission;

    final householdName = activeMission?.householdName ?? 'Nguyễn Văn A';
    final phone = activeMission?.phone ?? '0901234567';
    final address = activeMission?.address ?? '123 Đường ABC, Xã XYZ';
    final memberCount = activeMission?.memberCount ?? 4;
    final vulnerabilities = activeMission?.vulnerabilities ?? ['👴 Người già', '👶 Trẻ em', '🏚️ Cấp 4', '♿ Khuyết tật'];
    final disasterType = activeMission?.disasterType ?? 'Lũ lụt';
    final waterLevel = activeMission?.waterLevel ?? 'Cao (1.5m)';
    final emergencyChips = activeMission?.emergencyChips ?? ['Cần sơ tán gấp', 'Mất điện', 'Hết thực phẩm'];
    final photos = activeMission?.photos ?? ['photo1', 'photo2'];
    final householdId = activeMission?.householdId ?? 'HH_001';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chi tiết SOS #${widget.sosId}', style: AppTypography.h2.copyWith(color: AppColors.surface)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MOCK MAP
            Container(
              height: 200,
              color: AppColors.textPrimary,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: AppColors.surface),
                  SizedBox(height: AppSpacing.sm),
                  Text('Lộ trình dẫn đường', style: TextStyle(color: AppColors.surface, fontSize: 16)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD 'Thông tin hộ dân'
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card,
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thông tin hộ dân', style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(householdName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(phone, style: AppTypography.bodyMedium),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đang gọi...')),
                                  );
                                },
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text('Gọi'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(address, style: AppTypography.bodyMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.people, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Text('$memberCount người', style: AppTypography.bodyMedium),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: vulnerabilities.map((v) => Chip(
                                    label: Text(v, style: AppTypography.caption),
                                    backgroundColor: AppColors.background,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.chip,
                                      side: const BorderSide(color: AppColors.textDisabled),
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // CARD 'Tình trạng sự cố'
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card,
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tình trạng sự cố', style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Text('Loại: ', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text(disasterType, style: AppTypography.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Text('Mực nước: ', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text(waterLevel, style: AppTypography.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: emergencyChips.map((chip) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.priorityRed.withValues(alpha: 0.1),
                                borderRadius: AppRadius.chip,
                                border: Border.all(color: AppColors.priorityRed),
                              ),
                              child: Text(
                                chip,
                                style: AppTypography.caption.copyWith(color: AppColors.priorityRed),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Photos
                  if (photos.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppRadius.card,
                              border: Border.all(color: AppColors.textDisabled),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, color: AppColors.textDisabled),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // THREE ACTION BUTTONS
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mở ứng dụng dẫn đường...')),
                      );
                    },
                    icon: const Icon(Icons.navigation, color: AppColors.surface),
                    label: Text('Dẫn đường', style: AppTypography.label.copyWith(color: AppColors.surface)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.infoBlue,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MissionCompleteScreen(
                            sosId: widget.sosId,
                            householdId: householdId,
                            suggestedCount: memberCount,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle, color: AppColors.surface),
                    label: Text('Hoàn thành cứu hộ', style: AppTypography.label.copyWith(color: AppColors.surface)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusSafe,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.warning_amber, color: AppColors.textSecondary),
                    label: Text('Báo chướng ngại', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
