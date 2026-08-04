import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/team_models.dart';
import '../../providers/admin_team_provider.dart';
import 'team_detail_screen.dart';

class TeamListScreen extends ConsumerStatefulWidget {
  const TeamListScreen({super.key});

  @override
  ConsumerState<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends ConsumerState<TeamListScreen> {
  bool _showMockPending = true;

  Color _getStatusColor(TeamStatus status) {
    switch (status) {
      case TeamStatus.available:
        return AppColors.statusSafe;
      case TeamStatus.onMission:
        return AppColors.statusRescuing;
      case TeamStatus.resting:
        return AppColors.priorityOrange;
      case TeamStatus.offline:
      case TeamStatus.ended:
        return AppColors.statusMissing;
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

  String _getRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  void _approveTeam(String teamId) {
    if (teamId == 'mock_pending_01') {
      setState(() {
        _showMockPending = false;
      });
    } else {
      ref.read(adminTeamProvider.notifier).approveAdhocTeam(teamId);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã duyệt đội cứu hộ thành công')),
    );
  }

  void _rejectTeam(String teamId) {
    if (teamId == 'mock_pending_01') {
      setState(() {
        _showMockPending = false;
      });
    } else {
      ref.read(adminTeamProvider.notifier).removeTeam(teamId);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã từ chối đội cứu hộ')),
    );
  }

  Widget _buildTeamCard(RescueTeam team, {bool isPending = false}) {
    final suppliesSummary = team.type == TeamType.standing
        ? team.equipment.entries.map((e) => '${e.key}: ${e.value.toInt()}').join(', ')
        : team.supplies.entries.map((e) => '${e.key}: ${e.value.toInt()}').join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: isPending
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailScreen(teamId: team.id),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
                          team.name,
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: team.type == TeamType.standing
                                    ? AppColors.infoBlue.withValues(alpha: 0.1)
                                    : AppColors.statusSafe.withValues(alpha: 0.1),
                                borderRadius: AppRadius.chip,
                                border: Border.all(
                                  color: team.type == TeamType.standing
                                      ? AppColors.infoBlue
                                      : AppColors.statusSafe,
                                ),
                              ),
                              child: Text(
                                team.type == TeamType.standing
                                    ? 'Đội thường trực'
                                    : 'Đội vãng lai',
                                style: AppTypography.caption.copyWith(
                                  color: team.type == TeamType.standing
                                      ? AppColors.infoBlue
                                      : AppColors.statusSafe,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!isPending)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(team.status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: AppRadius.chip,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getRelativeTime(team.lastActive),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${team.members.length} người',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.phone_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    team.phone,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              if (suppliesSummary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        suppliesSummary,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isPending) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectTeam(team.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveTeam(team.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusSafe,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: const Text('Duyệt'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(adminTeamProvider);
    final allTeams = teamState.allTeams;

    // Đang hoạt động: available, onMission, resting, offline
    final activeTeams = allTeams.where((t) =>
        t.status == TeamStatus.available ||
        t.status == TeamStatus.onMission ||
        t.status == TeamStatus.resting ||
        t.status == TeamStatus.offline).toList();

    // Đã hoàn thành: ended
    final endedTeams =
        allTeams.where((t) => t.status == TeamStatus.ended).toList();

    // Chờ duyệt (Mock)
    final pendingTeams = <RescueTeam>[];
    if (_showMockPending) {
      pendingTeams.add(
        RescueTeam(
          id: 'mock_pending_01',
          name: 'Đoàn Thanh niên TPHCM',
          phone: '0909123456',
          type: TeamType.adhoc,
          status: TeamStatus.offline, // Dummy
          members: const ['Nguyễn Văn A', 'Lê B', 'Trần C'],
          equipment: const {},
          supplies: const {'Mì tôm (thùng)': 20, 'Nước (thùng)': 10},
          qrCode: 'DR-MTQ-HCM',
          restingReason: null,
          returnTime: null,
          lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Lực lượng Cứu hộ', style: AppTypography.h2),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              const Tab(text: 'Đang hoạt động'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('MTQ chờ duyệt'),
                    if (pendingTeams.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${pendingTeams.length}',
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Đã hoàn thành'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Đang hoạt động
            activeTeams.isEmpty
                ? const Center(child: Text('Không có lực lượng nào đang hoạt động'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: activeTeams.length,
                    itemBuilder: (context, index) =>
                        _buildTeamCard(activeTeams[index]),
                  ),

            // Tab 2: MTQ chờ duyệt
            pendingTeams.isEmpty
                ? const Center(child: Text('Không có lực lượng nào chờ duyệt'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: pendingTeams.length,
                    itemBuilder: (context, index) =>
                        _buildTeamCard(pendingTeams[index], isPending: true),
                  ),

            // Tab 3: Đã hoàn thành
            endedTeams.isEmpty
                ? const Center(child: Text('Không có lực lượng nào đã hoàn thành'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: endedTeams.length,
                    itemBuilder: (context, index) =>
                        _buildTeamCard(endedTeams[index]),
                  ),
          ],
        ),
      ),
    );
  }
}
