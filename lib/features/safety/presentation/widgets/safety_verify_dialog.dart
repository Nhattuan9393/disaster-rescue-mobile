import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SafetyVerifyDialog extends StatelessWidget {
  const SafetyVerifyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '❓ Bạn có an toàn không?',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Đây là lần hỏi thứ 1/3',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusSafe,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('✓ TÔI AN TOÀN', style: AppTypography.label),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.priorityRed,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('🆘 TÔI CẦN GIÚP', style: AppTypography.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
