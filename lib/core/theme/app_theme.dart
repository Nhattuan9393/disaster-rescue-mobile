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

/// Lớp định nghĩa kiểu chữ (Typography) cho toàn bộ ứng dụng.
/// Sử dụng font mặc định là Inter (fallback: Roboto).
class AppTypography {
  AppTypography._();

  static const fontFamily = 'Inter';

  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const sosButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
  );
}

/// Lớp định nghĩa khoảng cách (Spacing / Margins / Paddings) chuẩn.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Lớp định nghĩa bo góc (BorderRadius) cho các thành phần UI.
class AppRadius {
  AppRadius._();

  static final card = BorderRadius.circular(8);
  static final button = BorderRadius.circular(8);
  static final chip = BorderRadius.circular(50);
  static final sosButton = BorderRadius.circular(16);
  static const bottomSheet = BorderRadius.vertical(top: Radius.circular(16));
}
