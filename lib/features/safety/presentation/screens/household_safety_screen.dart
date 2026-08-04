import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/safety_verify_dialog.dart';

class HouseholdSafetyScreen extends StatelessWidget {
  const HouseholdSafetyScreen({super.key});

  void _showSafetyDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SafetyVerifyDialog(),
    );

    if (result != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Đã xác nhận an toàn. Sync lên hệ thống...' : 'TẠO SOS KHẨN CẤP THÀNH CÔNG!',
            style: const TextStyle(color: AppColors.surface),
          ),
          backgroundColor: result ? AppColors.statusSafe : AppColors.priorityRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trang Hộ Dân', style: AppTypography.h2),
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            elevation: 2,
          ),
          onPressed: () => _showSafetyDialog(context),
          child: const Text('Giả lập hiển thị Hỏi An Toàn', style: AppTypography.label),
        ),
      ),
    );
  }
}
