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
