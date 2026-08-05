import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/household/providers/safety_status_provider.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';

class SafetyReminderDialog extends ConsumerWidget {
  const SafetyReminderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.priorityOrange, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Xác nhận an toàn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
        ],
      ),
      content: const Text(
        'Đã quá 2 giờ kể từ lần cuối bạn cập nhật trạng thái an toàn. Vui lòng phản hồi tình hình hiện tại của bạn.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton(
          onPressed: () {
            ref.read(sosProvider.notifier).sendSos();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã kích hoạt luồng SOS khẩn cấp!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          child: const Text('TÔI CẦN GIÚP (SOS)'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(safetyStatusProvider.notifier).markAsSafe();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật trạng thái an toàn.'),
                backgroundColor: AppColors.statusSafe,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusSafe,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          child: const Text('TÔI AN TOÀN'),
        ),
      ],
    );
  }
}
