import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/household_card.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';

/// Màn hình danh sách Nhiệm vụ dành cho Đội cứu hộ.
class TeamMissionsScreen extends ConsumerStatefulWidget {
  const TeamMissionsScreen({super.key});

  @override
  ConsumerState<TeamMissionsScreen> createState() => _TeamMissionsScreenState();
}

class _TeamMissionsScreenState extends ConsumerState<TeamMissionsScreen> {
  // Trạng thái gán nhiệm vụ giả lập
  bool _isMissionAccepted = false;

  void _toggleMission() {
    setState(() {
      _isMissionAccepted = !_isMissionAccepted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMissionAccepted
              ? 'Đã nhận nhiệm vụ! Chi tiết liên hệ hộ dân đã được hiển thị công khai.'
              : 'Đã hủy nhận nhiệm vụ. Thông tin liên hệ hộ dân bị ẩn để bảo mật.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhiệm vụ Cứu hộ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SOS cần xử lý gần bạn',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hộ dân bị nạn (Che giấu nếu chưa nhận nhiệm vụ cứu trợ)
                    HouseholdCard(
                      name: 'Hoàng Văn Cường',
                      village: 'Thôn Pắc Liềng',
                      peopleCount: 4,
                      status: SafetyState.sos,
                      phone: '0988776655',
                      isMasked: !_isMissionAccepted, // Nghiệp vụ bảo mật thông tin CLAUDE.md mục 1.5/45
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _toggleMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMissionAccepted ? AppColors.priorityOrange : AppColors.statusSafe,
                        foregroundColor: AppColors.surface,
                      ),
                      child: Text(
                        _isMissionAccepted ? 'Hủy nhận nhiệm vụ' : 'Chấp nhận nhiệm vụ này',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
