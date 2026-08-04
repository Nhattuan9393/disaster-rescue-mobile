import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/shared/widgets/status_chip.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';

/// Màn hình chính của Hộ dân: Chứa nút SOS lớn ở trung tâm.
class HouseholdHomeScreen extends ConsumerStatefulWidget {
  const HouseholdHomeScreen({super.key});

  @override
  ConsumerState<HouseholdHomeScreen> createState() => _HouseholdHomeScreenState();
}

class _HouseholdHomeScreenState extends ConsumerState<HouseholdHomeScreen> {
  SosButtonState _sosState = SosButtonState.idle;

  void _triggerSos() async {
    setState(() {
      _sosState = SosButtonState.sending;
    });

    // Mô phỏng quá trình gửi tin khẩn cấp cứu nạn trong 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _sosState = SosButtonState.sent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Trạng thái an toàn hiện tại của hộ dân
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái an toàn của tôi:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const StatusChip(
                        status: SafetyState.safe,
                        source: SafetySource.selfApp,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Bạn nên cập nhật trạng thái an toàn định kỳ hoặc khi có lệnh sơ tán.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xác nhận an toàn lên hệ thống.')),
                          );
                        },
                        child: const Text('Báo cáo: Tôi vẫn an toàn'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Nút SOS khẩn cấp trung tâm
              Center(
                child: Column(
                  children: [
                    SosButton(
                      state: _sosState,
                      onTap: _triggerSos,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    const Text(
                      'BẤM 1 CHẠM ĐỂ GỬI SOS KHẨN CẤP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTypography.fontFamily,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Hệ thống sẽ lấy tọa độ tự động và gửi đội cứu hộ lập tức.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Các thao tác phụ trợ khác
              const Text(
                'Thao tác khác',
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
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.airport_shuttle_rounded, color: AppColors.primary),
                      title: const Text(
                        'Yêu cầu hỗ trợ sơ tán chủ động',
                        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: AppTypography.fontFamily),
                      ),
                      subtitle: const Text('Dành cho hộ cần di chuyển người già, trẻ em, khuyết tật trước nguy hiểm'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/evacuation-request'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_rounded, color: AppColors.primary),
                      title: const Text(
                        'Báo tin giúp người khác (Luồng B)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: AppTypography.fontFamily),
                      ),
                      subtitle: const Text('Khai báo thông tin hộ dân khác bị nạn lân cận (cần duyệt)'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo: Mở form báo tin cứu hộ hộ dân khác.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
