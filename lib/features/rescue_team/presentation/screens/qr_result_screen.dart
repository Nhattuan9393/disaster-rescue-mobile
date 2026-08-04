import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/team_provider.dart';
import '../../../../data/models/team_models.dart';
import 'team_register_screen.dart';
import 'team_status_screen.dart';

class QrResultScreen extends ConsumerStatefulWidget {
  final String qrCode;

  const QrResultScreen({super.key, required this.qrCode});

  @override
  ConsumerState<QrResultScreen> createState() => _QrResultScreenState();
}

class _QrResultScreenState extends ConsumerState<QrResultScreen> {
  late bool _isStanding;
  int _activeMemberCount = 0;

  @override
  void initState() {
    super.initState();
    // Chạy đồng bộ lookup phân nhánh ngay khi màn hình khởi tạo
    _isStanding = ref.read(activeTeamProvider.notifier).handleQrScan(widget.qrCode);
    
    if (_isStanding) {
      final team = ref.read(activeTeamProvider).currentTeam;
      if (team != null) {
        _activeMemberCount = team.members.length;
      }
    }
  }

  void _activateStandingTeam() {
    // Kích hoạt đội thường trực ngay lập tức (không cần admin duyệt)
    ref.read(activeTeamProvider.notifier).updateStatus(TeamStatus.available);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TeamStatusScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(activeTeamProvider);
    final team = teamState.currentTeam;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text('PHÂN NHÁNH THAO TÁC', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: _isStanding && team != null
            ? _buildStandingTeamView(team)
            : _buildAdhocBranchView(),
      ),
    );
  }

  Widget _buildStandingTeamView(dynamic team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ thông tin chính
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: AppRadius.chip,
                              ),
                              child: Text(
                                'ĐỘI THƯỜNG TRỰC',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Mã: ${team.qrCode}',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(team.name, style: AppTypography.h2),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'SĐT Trưởng đội: ${team.phone}',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                // Quân số hoạt động
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ĐIỀU CHỈNH QUÂN SỐ HÔM NAY', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Số thành viên đi thực tế:',
                              style: AppTypography.bodyLarge,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 28),
                                  onPressed: _activeMemberCount > 1
                                      ? () {
                                          setState(() {
                                            _activeMemberCount--;
                                          });
                                        }
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Text(
                                    '$_activeMemberCount / ${team.members.length}',
                                    style: AppTypography.h2,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 28),
                                  onPressed: _activeMemberCount < team.members.length
                                      ? () {
                                          setState(() {
                                            _activeMemberCount++;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                // Thành viên
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DANH SÁCH THÀNH VIÊN ĐĂNG KÝ', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.sm),
                        ...team.members.map<Widget>((member) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(member, style: AppTypography.bodyMedium),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                // Vật tư biên chế
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VẬT TƯ BIÊN CHẾ CÓ SẴN (ĐÃ KHAI BÁO)', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.sm),
                        ...team.equipment.entries.map<Widget>((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: AppTypography.bodyMedium),
                                  Text(
                                    '${entry.value.toInt()} đơn vị',
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Nút kích hoạt
        const SizedBox(height: AppSpacing.base),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusSafe,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            elevation: 4,
          ),
          onPressed: _activateStandingTeam,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'KÍCH HOẠT NGAY — KHÔNG CẦN DUYỆT',
                style: AppTypography.button.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdhocBranchView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.info_outline,
          size: 72,
          color: AppColors.priorityOrange,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'ĐỘI CỨU HỘ MỚI / MTQ',
          textAlign: TextAlign.center,
          style: AppTypography.h2,
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            'Mã QR đã quét (hoặc nhập vào) không khớp với bất kỳ Đội thường trực nào đã đăng ký trước của xã.\n\nNếu bạn là đoàn chi viện vãng lai, Mặt trận Tổ quốc hoặc tổ chức thiện nguyện, vui lòng đăng ký thông tin để Admin duyệt.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TeamRegisterScreen(qrCode: widget.qrCode),
              ),
            );
          },
          child: const Text('ĐĂNG KÝ ĐỘI VÃNG LAI TẠI CHỐT', style: AppTypography.button),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            side: const BorderSide(color: AppColors.textSecondary),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'QUÉT LẠI MÃ',
            style: AppTypography.button.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
