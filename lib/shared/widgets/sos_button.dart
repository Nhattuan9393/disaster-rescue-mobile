import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

enum SosButtonState {
  idle,
  sending,
  sent,
}

/// Nút bấm SOS khẩn cấp (1 chạm).
/// Có đường kính 200px (trong khoảng 180-250px quy định) và hiệu ứng chuyển đổi trạng thái.
class SosButton extends StatelessWidget {
  final SosButtonState state;
  final VoidCallback? onTap;

  const SosButton({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Widget child;

    switch (state) {
      case SosButtonState.idle:
        buttonColor = AppColors.primary;
        child = const Text(
          'SOS',
          style: TextStyle(
            color: AppColors.surface,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontFamily: AppTypography.fontFamily,
          ),
        );
        break;
      case SosButtonState.sending:
        buttonColor = AppColors.primaryDark;
        child = const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
            strokeWidth: 4.0,
          ),
        );
        break;
      case SosButtonState.sent:
        buttonColor = AppColors.statusSafe;
        child = const Icon(
          Icons.check,
          color: AppColors.surface,
          size: 56,
        );
        break;
    }

    return GestureDetector(
      onTap: state == SosButtonState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
