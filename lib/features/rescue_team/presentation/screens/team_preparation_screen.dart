import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/team_models.dart';
import '../../providers/admin_team_provider.dart';
import 'team_form_screen.dart';

class TeamPreparationScreen extends ConsumerWidget {
  const TeamPreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminTeamProvider);
    final standingTeams = adminState.standingTeams;

    final totalMembers = standingTeams.fold<int>(
      0,
      (sum, team) => sum + team.members.length,
    );
    final totalEquipment = standingTeams.fold<double>(
      0,
      (sum, team) =>
          sum +
          team.equipment.values.fold<double>(0, (s, e) => s + e),
    ).toInt();

    final Map<String, double> aggregatedEquipment = {};
    for (var team in standingTeams) {
      team.equipment.forEach((key, value) {
        aggregatedEquipment[key] = (aggregatedEquipment[key] ?? 0) + value;
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lực lượng Thường trực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Kích hoạt toàn bộ',
            onPressed: () => _showActivateAllDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBox(),
            const SizedBox(height: AppSpacing.md),
            _buildKpiRow(standingTeams.length, totalMembers, totalEquipment),
            const SizedBox(height: AppSpacing.lg),
            _buildEquipmentSummary(aggregatedEquipment),
            const SizedBox(height: AppSpacing.lg),
            _buildTeamList(context, standingTeams),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeamFormScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text(
                '+ Thêm đội thường trực mới',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showActivateAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          title: const Text('Kích hoạt tất cả?'),
          content: const Text(
            'Kích hoạt tất cả đội thường trực? Các đội sẽ sẵn sàng nhận nhiệm vụ SOS ngay lập tức.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(adminTeamProvider.notifier).activateAllStandingTeams();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã kích hoạt toàn bộ lực lượng thường trực!'),
                    backgroundColor: AppColors.statusSafe,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              child: const Text('Kích hoạt', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.infoBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.infoBlue,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'CÔNG TÁC CHUẨN BỊ — làm trước mùa thiên tai. Đội biên chế xã khai báo sẵn 1 lần. Khi có thiên tai chỉ cần kích hoạt 1 chạm.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(int teamsCount, int membersCount, int equipmentCount) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard('Số đội', teamsCount.toString(), Icons.group_work),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard('Nhân lực', membersCount.toString(), Icons.people),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard('Phương tiện', equipmentCount.toString(), Icons.build),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSummary(Map<String, double> equipment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng vật tư biên chế',
          style: AppTypography.h3,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              if (equipment.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('Chưa có vật tư', style: AppTypography.bodyMedium),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: equipment.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = equipment.keys.elementAt(index);
                    final value = equipment[key]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(key, style: AppTypography.bodyMedium),
                          Text(
                            value.toInt().toString(),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Cộng vào Tổng vật tư khả dụng của xã',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamList(BuildContext context, List<RescueTeam> teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách đội thường trực',
          style: AppTypography.h3,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (teams.isEmpty)
          const Text(
            'Chưa có đội thường trực nào.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teams.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final team = teams[index];
              final isActivated = team.status != TeamStatus.ended;
              final leadName = team.members.isNotEmpty ? team.members.first : 'Chưa có thành viên';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamFormScreen(teamId: team.id),
                    ),
                  );
                },
                borderRadius: AppRadius.card,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.card,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
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
                              team.name,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActivated
                                  ? AppColors.statusSafe.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              isActivated ? 'Đã kích hoạt' : 'Đã khai báo',
                              style: AppTypography.caption.copyWith(
                                color: isActivated
                                    ? AppColors.statusSafe
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$leadName • ${team.phone}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppRadius.chip,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '👥 ${team.members.length} người',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          ...team.equipment.entries.take(3).map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppRadius.chip,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                '${e.key}: ${e.value.toInt()}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          if (team.equipment.length > 3)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppRadius.chip,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                '+${team.equipment.length - 3}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
