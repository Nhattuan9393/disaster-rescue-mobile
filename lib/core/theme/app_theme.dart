import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFD32F2F);
  static const Color redLight = Color(0xFFFF6659);
  static const Color orange = Color(0xFFF57C00);
  static const Color yellow = Color(0xFFF9A825);
  static const Color green = Color(0xFF388E3C);
  static const Color blue = Color(0xFF1976D2);
  static const Color gray = Color(0xFF616161);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color warning = Color(0xFFFFF8E1);
  static const Color text1 = Color(0xFF212121);
  static const Color text2 = Color(0xFF757575);
  static const Color text3 = Color(0xFFBDBDBD);
  static const Color border = Color(0xFFE0E0E0);
  static const Color mapBg = Color(0xFFDDE6E2);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.red,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        secondary: AppColors.blue,
        error: AppColors.redLight,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text1,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
