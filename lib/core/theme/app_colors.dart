import 'package:flutter/material.dart';

/// Lớp định nghĩa bảng màu (Design Tokens) cho toàn bộ ứng dụng DisasterRescue.
/// Được cấu hình dựa trên các đặc tả màu sắc khẩn cấp và trạng thái trong CLAUDE.md.
class AppColors {
  AppColors._();

  static const primary = Color(0xFFD32F2F); // Emergency red — nút SOS
  static const primaryLight = Color(0xFFFF6659);
  static const primaryDark = Color(0xFF9A0007);

  // Điểm ưu tiên (SOS score)
  static const priorityRed = Color(0xFFD32F2F); // score >= 70 (Nguy cấp)
  static const priorityOrange = Color(0xFFF57C00); // score 40-69 (Nguy hiểm)
  static const priorityYellow = Color(0xFFF9A825); // score < 40 (Cần hỗ trợ)

  // Trạng thái an toàn & cứu hộ
  static const statusSafe = Color(0xFF388E3C);
  static const statusRescuing = Color(0xFF1976D2);
  static const statusMissing = Color(0xFF616161);
  static const statusPending = Color(0xFFF57C00);

  // Màu nền & Surface
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const infoBlue = Color(0xFF1976D2);
  static const warningBanner = Color(0xFFFFF8E1);

  // Màu văn bản (Typography colors)
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);
}
