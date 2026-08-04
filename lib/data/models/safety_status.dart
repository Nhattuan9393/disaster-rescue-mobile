import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_status.freezed.dart';
part 'safety_status.g.dart';

enum SafetyState {
  safe,
  sos,
  missingContact,
  rescued,
  evacuated,
}

enum SafetySource {
  rescueTeam,          // 100 — đội xác nhận tại hiện trường (ảnh + GPS)
  evacuationCheckin,   //  95 — check-in tại điểm sơ tán
  selfApp,             //  90 — hộ dân tự báo qua app
  adminManual,         //  70 — trưởng thôn xác nhận thủ công
  neighborReport,      //  40 — hàng xóm báo hộ (qua luồng B, cần duyệt)
}

@freezed
class SafetyStatus with _$SafetyStatus {
  const factory SafetyStatus({
    required SafetyState status,
    required SafetySource source,
    String? verifiedBy,
    required DateTime verifiedAt,
    required int confidence,
    String? note,
  }) = _SafetyStatus;

  const SafetyStatus._();

  factory SafetyStatus.fromJson(Map<String, dynamic> json) => _$SafetyStatusFromJson(json);

  bool get requiresFieldCheck => status == SafetyState.missingContact;
}

extension SafetySourceExtension on SafetySource {
  int get confidence {
    switch (this) {
      case SafetySource.rescueTeam:
        return 100;
      case SafetySource.evacuationCheckin:
        return 95;
      case SafetySource.selfApp:
        return 90;
      case SafetySource.adminManual:
        return 70;
      case SafetySource.neighborReport:
        return 40;
    }
  }
}

class InvalidSafetyTransitionException implements Exception {
  final String message;
  InvalidSafetyTransitionException(this.message);
  @override
  String toString() => 'InvalidSafetyTransitionException: $message';
}

SafetyStatus updateSafetyStatus(SafetyStatus current, SafetyStatus update) {
  if (update.confidence >= current.confidence) {
    return update;
  } else {
    throw InvalidSafetyTransitionException(
      'Không thể cập nhật trạng thái từ nguồn có độ tin cậy thấp hơn (${update.source.name}: ${update.confidence}) '
      'lên nguồn có độ tin cậy cao hơn (${current.source.name}: ${current.confidence})'
    );
  }
}
