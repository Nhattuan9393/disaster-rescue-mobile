/// Cấu hình khẩn cấp của xã — số tổng đài SMS + cờ demo.
///
/// Firestore doc: `config/emergency`.
class EmergencyConfig {
  /// Số điện thoại tổng đài nhận SMS SOS (bấm gọi hoặc gửi SMS đến số này).
  final String hotlinePhone;

  /// Nếu true, [`SosDeliveryService`] không gửi SMS thật — thay vào đó ghi
  /// payload trực tiếp vào Firestore collection `sms_inbox` để mô phỏng
  /// tổng đài SMS gateway nhận tin. Dùng cho demo end-to-end mà không cần
  /// 2 SIM. Production đặt `false`.
  final bool demoMode;

  /// Nhãn hiển thị của tổng đài — VD "Ban Chỉ huy Cứu hộ Xã Bình Liêu".
  final String hotlineLabel;

  const EmergencyConfig({
    required this.hotlinePhone,
    this.demoMode = true,
    this.hotlineLabel = 'Ban Chỉ huy Cứu hộ Xã Bình Liêu',
  });

  static const EmergencyConfig fallback = EmergencyConfig(
    hotlinePhone: '02033123456',
    demoMode: true,
    hotlineLabel: 'Ban Chỉ huy Cứu hộ Xã Bình Liêu',
  );

  EmergencyConfig copyWith({
    String? hotlinePhone,
    bool? demoMode,
    String? hotlineLabel,
  }) {
    return EmergencyConfig(
      hotlinePhone: hotlinePhone ?? this.hotlinePhone,
      demoMode: demoMode ?? this.demoMode,
      hotlineLabel: hotlineLabel ?? this.hotlineLabel,
    );
  }

  Map<String, dynamic> toJson() => {
        'hotlinePhone': hotlinePhone,
        'demoMode': demoMode,
        'hotlineLabel': hotlineLabel,
      };

  factory EmergencyConfig.fromJson(Map<String, dynamic> json) {
    return EmergencyConfig(
      hotlinePhone: json['hotlinePhone'] as String? ?? fallback.hotlinePhone,
      demoMode: json['demoMode'] as bool? ?? fallback.demoMode,
      hotlineLabel:
          json['hotlineLabel'] as String? ?? fallback.hotlineLabel,
    );
  }
}
