import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/team_provider.dart';
import '../../../../data/models/team_models.dart';
import 'qr_scanner_screen.dart';

class TeamStatusScreen extends ConsumerStatefulWidget {
  const TeamStatusScreen({super.key});

  @override
  ConsumerState<TeamStatusScreen> createState() => _TeamStatusScreenState();
}

class _TeamStatusScreenState extends ConsumerState<TeamStatusScreen> {
  final _reasonController = TextEditingController();
  int _selectedRestMinutes = 30; // Mặc định nghỉ 30 phút
  String _selectedReason = 'Ăn uống / Hồi sức';

  final List<String> _commonReasons = [
    'Ăn uống / Hồi sức',
    'Sửa chữa phương tiện',
    'Bổ sung vật tư cứu hộ',
    'Lý do khác...',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showRestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Cấu hình Tạm nghỉ', style: AppTypography.h3),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lý do tạm nghỉ:', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReason,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      ),
                      items: _commonReasons.map((reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason, style: AppTypography.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            _selectedReason = val;
                          });
                        }
                      },
                    ),
                    if (_selectedReason == 'Lý do khác...') ...[
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do cụ thể...',
                          border: OutlineInputBorder(),
                        ),
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Thời gian quay lại dự kiến:', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      children: [15, 30, 45, 60, 120].map((mins) {
                        final isSelected = _selectedRestMinutes == mins;
                        return ChoiceChip(
                          label: Text('$mins phút'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                _selectedRestMinutes = mins;
                              });
                            }
                          },
                          selectedColor: AppColors.priorityOrange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('HỦY'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final finalReason = _selectedReason == 'Lý do khác...'
                        ? _reasonController.text.trim()
                        : _selectedReason;
                    
                    if (finalReason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập lý do tạm nghỉ')),
                      );
                      return;
                    }

                    final returnTime = DateTime.now().add(Duration(minutes: _selectedRestMinutes));

                    // Cập nhật trạng thái nghỉ lên provider
                    ref.read(activeTeamProvider.notifier).updateStatus(
                          TeamStatus.resting,
                          reason: finalReason,
                          returnTime: returnTime,
                        );
                    
                    Navigator.of(context).pop();
                  },
                  child: const Text('XÁC NHẬN NGHỈ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEndShiftDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận kết thúc ca?', style: AppTypography.h3),
          content: const Text(
            'Hành động này sẽ rút đội cứu hộ của bạn khỏi danh sách khả dụng trên hệ thống xã. Bạn sẽ cần quét lại mã QR tại chốt để kích hoạt cho ca trực sau.',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                ref.read(activeTeamProvider.notifier).updateStatus(TeamStatus.ended);
                ref.read(activeTeamProvider.notifier).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                  (route) => false,
                );
              },
              child: const Text('KẾT THÚC CA'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(activeTeamProvider);
    final team = teamState.currentTeam;

    if (team == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tìm thấy thông tin Đội cứu hộ hoạt động.'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                  );
                },
                child: const Text('Quét mã QR'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text('CHI TIẾT CA TRỰC', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Đăng xuất / Rút ca',
            onPressed: _showEndShiftDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ trạng thái lớn
            _buildStatusHeaderCard(team),
            const SizedBox(height: AppSpacing.base),

            // Nút bấm thay đổi trạng thái
            const Text('THAY ĐỔI TRẠNG THÁI CA TRỰC', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            
            // Nút Sẵn sàng
            _buildStatusSelectButton(
              title: 'SẴN SÀNG NHẬN NHIỆM VỤ (AVAILABLE)',
              subtitle: 'Đội đang trực tuyến, sẵn sàng nhận SOS cứu nạn khẩn cấp.',
              icon: Icons.check_circle,
              color: AppColors.statusSafe,
              isSelected: team.status == TeamStatus.available,
              onTap: () {
                ref.read(activeTeamProvider.notifier).updateStatus(TeamStatus.available);
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // Nút Tạm nghỉ
            _buildStatusSelectButton(
              title: 'TẠM NGHỈ LUÂN PHIÊN (RESTING)',
              subtitle: 'Nghỉ hồi sức, ăn uống, nạp nhiên liệu. Hệ thống sẽ KHÔNG đẩy SOS khẩn cấp.',
              icon: Icons.pause_circle_filled,
              color: AppColors.priorityOrange,
              isSelected: team.status == TeamStatus.resting,
              onTap: _showRestDialog,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Nút Kết thúc ca
            _buildStatusSelectButton(
              title: 'KẾT THÚC CA TRỰC (ENDED)',
              subtitle: 'Hoàn thành ca trực lụt bão, rút đội ra khỏi địa bàn.',
              icon: Icons.cancel,
              color: Colors.red.shade800,
              isSelected: team.status == TeamStatus.ended,
              onTap: _showEndShiftDialog,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Thông tin đội
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('THÀNH VIÊN ĐỘI', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.sm),
                    ...team.members.map((member) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(member, style: AppTypography.bodyMedium),
                            ],
                          ),
                        )),
                    const Divider(height: AppSpacing.lg),
                    const Text('VẬT TƯ CỨU TRỢ / BIÊN CHẾ ĐANG MANG', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.sm),
                    if (team.type == TeamType.standing && team.equipment.isEmpty)
                      const Text('Không mang thiết bị biên chế.', style: TextStyle(fontStyle: FontStyle.italic))
                    else if (team.type == TeamType.adhoc && team.supplies.isEmpty)
                      const Text('Không mang vật tư cứu trợ.', style: TextStyle(fontStyle: FontStyle.italic))
                    else
                      ...(team.type == TeamType.standing ? team.equipment : team.supplies).entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: AppTypography.bodyMedium),
                              Text(
                                '${entry.value.toInt()}',
                                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard(RescueTeam team) {
    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (team.status) {
      case TeamStatus.available:
        statusColor = AppColors.statusSafe;
        statusTitle = 'ĐANG SẴN SÀNG';
        statusIcon = Icons.check_circle_outline;
        break;
      case TeamStatus.resting:
        statusColor = AppColors.priorityOrange;
        statusTitle = 'ĐANG TẠM NGHỈ';
        statusIcon = Icons.error_outline;
        break;
      case TeamStatus.onMission:
        statusColor = AppColors.statusRescuing;
        statusTitle = 'ĐANG LÀM NHIỆM VỤ';
        statusIcon = Icons.directions_run;
        break;
      case TeamStatus.offline:
        statusColor = AppColors.statusMissing;
        statusTitle = 'MẤT KẾT NỐI';
        statusIcon = Icons.signal_wifi_off;
        break;
      case TeamStatus.ended:
        statusColor = Colors.red.shade900;
        statusTitle = 'ĐÃ KẾT THÚC CA';
        statusIcon = Icons.highlight_off;
        break;
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: statusColor, width: 6)),
          borderRadius: AppRadius.card,
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team.name,
                  style: AppTypography.h3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: team.type == TeamType.standing ? Colors.blue.shade50 : Colors.purple.shade50,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    team.type == TeamType.standing ? 'THƯỜNG TRỰC' : 'VÃNG LAI',
                    style: TextStyle(
                      color: team.type == TeamType.standing ? Colors.blue.shade800 : Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  statusTitle,
                  style: AppTypography.h2.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (team.status == TeamStatus.resting) ...[
              const Divider(height: AppSpacing.lg),
              Text(
                'Lý do nghỉ: ${team.restingReason ?? "Không rõ"}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Thời gian dự kiến quay lại: ${team.returnTime != null ? "${team.returnTime!.hour.toString().padLeft(2, '0')}:${team.returnTime!.minute.toString().padLeft(2, '0')}" : "Chưa xác định"}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelectButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isSelected ? color.withOpacity(0.08) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        onTap: isSelected ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: isSelected ? color : AppColors.background,
          foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: AppTypography.label.copyWith(
            color: isSelected ? color : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.3),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
