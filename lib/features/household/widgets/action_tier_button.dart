import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

class ActionTierButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color contentColor;
  final VoidCallback onTap;
  final double height;
  final bool isOutline;

  const ActionTierButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.contentColor,
    required this.onTap,
    required this.height,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutline ? Colors.transparent : backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: isOutline ? BorderSide(color: backgroundColor, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: contentColor, size: 28),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTypography.fontFamily,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
