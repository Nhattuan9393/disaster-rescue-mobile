import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

void main() {
  group('Design Tokens & Theme Tests', () {
    test('AppColors.primary should be Color(0xFFD32F2F)', () {
      expect(AppColors.primary, const Color(0xFFD32F2F));
    });

    test('AppColors status colors should match specification', () {
      expect(AppColors.statusSafe, const Color(0xFF388E3C));
      expect(AppColors.statusRescuing, const Color(0xFF1976D2));
      expect(AppColors.statusMissing, const Color(0xFF616161));
      expect(AppColors.statusPending, const Color(0xFFF57C00));
    });

    test('AppTheme lightTheme configurations', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
    });

    test('AppSpacing values should match Design Tokens', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.base, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
    });

    test('AppRadius values should match Design Tokens', () {
      expect(AppRadius.card, BorderRadius.circular(8));
      expect(AppRadius.button, BorderRadius.circular(8));
      expect(AppRadius.chip, BorderRadius.circular(50));
      expect(AppRadius.sosButton, BorderRadius.circular(16));
    });
  });
}
