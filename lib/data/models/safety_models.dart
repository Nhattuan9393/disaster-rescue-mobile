import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_models.freezed.dart';
part 'safety_models.g.dart';

enum SafetyState {
  @JsonValue('safe') safe,
  @JsonValue('sos') sos,
  @JsonValue('missingContact') missingContact,
  @JsonValue('rescued') rescued,
  @JsonValue('evacuated') evacuated,
}

enum SafetySource {
  @JsonValue('rescueTeam') rescueTeam,
  @JsonValue('evacuationCheckin') evacuationCheckin,
  @JsonValue('selfApp') selfApp,
  @JsonValue('adminManual') adminManual,
  @JsonValue('neighborReport') neighborReport,
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

@freezed
class SafetyStatus with _$SafetyStatus {
  const factory SafetyStatus({
    required SafetyState status,
    required SafetySource source,
    required String? verifiedBy,
    required DateTime verifiedAt,
    required int confidence,
    required String? note,
  }) = _SafetyStatus;

  factory SafetyStatus.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusFromJson(json);
}

class InvalidSafetyTransitionException implements Exception {
  final String message;
  InvalidSafetyTransitionException(this.message);
  @override
  String toString() => 'InvalidSafetyTransitionException: $message';
}

/// Hàm cập nhật trạng thái an toàn dựa trên độ tin cậy của nguồn (FR-07.3)
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
