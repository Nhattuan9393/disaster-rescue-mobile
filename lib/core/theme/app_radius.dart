import 'package:flutter/material.dart';

/// Lớp định nghĩa bo góc (BorderRadius) cho các thành phần UI.
class AppRadius {
  AppRadius._();

  static final card = BorderRadius.circular(8);
  static final button = BorderRadius.circular(8);
  static final chip = BorderRadius.circular(50);
  static final sosButton = BorderRadius.circular(16);
  static const bottomSheet = BorderRadius.vertical(top: Radius.circular(16));
}
