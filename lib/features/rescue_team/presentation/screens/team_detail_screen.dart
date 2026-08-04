import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/team_models.dart';
import '../../providers/admin_team_provider.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
  });

  Color _getStatusColor(TeamStatus status) {
    switch (status) {
      case TeamStatus.available:
        return AppColors.statusSafe;
      case TeamStatus.onMission:
        return AppColors.statusRescuing;
      case TeamStatus.resting:
        return AppColors.statusPending;
      case TeamStatus.offline:
        return AppColors.statusMissing;
      case TeamStatus.ended:
        return AppColors.textDisabled;
    }
  }

  String _getStatusText(TeamStatus status) {
    switch (status) {
      case TeamStatus.available:
        return 'Sẵn sàng';
      case TeamStatus.onMission:
        return 'Đang nhiệm vụ';
      case TeamStatus.resting:
        return 'Tạm nghỉ';
      case TeamStatus.offline:
        return 'Mất kết nối';
      case TeamStatus.ended:
        return 'Kết thúc ca';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminTeamState = ref.watch(adminTeamProvider);
    final team = adminTeamState.allTeams.firstWhere(
      (t) => t.id == teamId,
      orElse: () => adminTeamState.allTeams.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(context, team),
            const SizedBox(height: AppSpacing.md),
            if (team.status == TeamStatus.onMission) ...[
              _buildMissionCard(),
              const SizedBox(height: AppSpacing.md),
            ],
            if (team.status == TeamStatus.resting) ...[
              _buildRestingCard(team),
              const SizedBox(height: AppSpacing.md),
            ],
            _buildMockMap(),
            const SizedBox(height: AppSpacing.md),
            _buildKpis(team),
            const SizedBox(height: AppSpacing.lg),
            _buildMembersSection(team),
            const SizedBox(height: AppSpacing.lg),
            _buildEquipmentAndSupplies(team),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, RescueTeam team) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(team.name, style: AppTypography.h2),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(team.status).withValues(alpha: 0.15),
                    borderRadius: AppRadius.chip,
                    border: Border.all(color: _getStatusColor(team.status)),
                  ),
                  child: Text(
                    _getStatusText(team.status),
                    style: AppTypography.caption.copyWith(
                      color: _getStatusColor(team.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: team.type == TeamType.standing
                    ? AppColors.infoBlue.withValues(alpha: 0.1)
                    : AppColors.statusSafe.withValues(alpha: 0.1),
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                team.type == TeamType.standing ? 'Đội thường trực' : 'Đội vãng lai',
                style: AppTypography.caption.copyWith(
                  color: team.type == TeamType.standing
                      ? AppColors.infoBlue
                      : AppColors.statusSafe,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(team.phone, style: AppTypography.bodyLarge),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.infoBlue,
                    foregroundColor: AppColors.surface,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang gọi trưởng đội...')),
                    );
                  },
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Gọi trưởng đội'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.warningBanner,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.assignment_late, color: AppColors.statusPending),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhiệm vụ hiện tại',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'SOS-0042 (Đang cứu hộ — Thôn Pắc Liềng)',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestingCard(RescueTeam team) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.background,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.hotel, color: AppColors.statusPending),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng thái tạm nghỉ',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    team.restingReason ?? 'Đang nghỉ ngơi',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (team.returnTime != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Dự kiến trở lại: ${team.returnTime!.hour}:${team.returnTime!.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.caption.copyWith(color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockMap() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: AppRadius.card,
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, size: 32, color: Colors.white54),
            SizedBox(height: AppSpacing.xs),
            Text('Bản đồ vị trí đội', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(RescueTeam team) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Đội viên', '${team.members.length}')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildKpiCard('Hộ đã cứu', '3')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildKpiCard('Phản hồi TB', '12 phút')),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.h3.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(RescueTeam team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thành viên', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: team.members.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final memberName = team.members[index];
              final isLeader = index == 0;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(
                    isLeader ? Icons.star : Icons.person,
                    color: isLeader ? AppColors.statusPending : AppColors.textSecondary,
                  ),
                ),
                title: Text(memberName, style: AppTypography.bodyMedium),
                trailing: isLeader
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          'Đội trưởng',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentAndSupplies(RescueTeam team) {
    final hasEquipment = team.equipment.isNotEmpty;
    final hasSupplies = team.supplies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phương tiện & Vật tư', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        if (!hasEquipment && !hasSupplies)
          Text(
            'Đội chưa được phân bổ phương tiện và vật tư.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasEquipment) ...[
                    Text('Phương tiện biên chế:',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: team.equipment.entries.map((entry) {
                        return Chip(
                          avatar: const Icon(Icons.build, size: 16),
                          label: Text('${entry.key}: ${entry.value.toInt()}'),
                          backgroundColor: AppColors.background,
                          side: const BorderSide(color: AppColors.textDisabled),
                        );
                      }).toList(),
                    ),
                    if (hasSupplies) const SizedBox(height: AppSpacing.md),
                  ],
                  if (hasSupplies) ...[
                    Row(
                      children: [
                        Text('Vật tư mang theo:',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusSafe.withValues(alpha: 0.15),
                            borderRadius: AppRadius.chip,
                          ),
                          child: Text(
                            '🤝 Đội mang',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.statusSafe,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: team.supplies.entries.map((entry) {
                        return Chip(
                          label: Text('${entry.key}: ${entry.value.toInt()}'),
                          backgroundColor: AppColors.statusSafe.withValues(alpha: 0.08),
                          side: const BorderSide(color: AppColors.statusSafe),
                        );
                      }).toList(),
                    ),
                  ],
                  const Divider(height: AppSpacing.lg),
                  Text(
                    '* Vật tư nguồn Kho xã sẽ trừ tồn kho khi phát cho dân. Vật tư đội tự mang không trừ tồn kho xã.',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Gán khu vực đang phát triển')),
            );
          },
          icon: const Icon(Icons.map_outlined),
          label: const Text('Gán khu vực'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.infoBlue,
            side: const BorderSide(color: AppColors.infoBlue),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Xuất vật tư đang phát triển')),
            );
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Xuất vật tư cho đội'),
        ),
        const SizedBox(height: AppSpacing.sm),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Gán SOS đang phát triển')),
            );
          },
          icon: const Icon(Icons.sos),
          label: const Text('Gán SOS cho đội'),
        ),
      ],
    );
  }
}
