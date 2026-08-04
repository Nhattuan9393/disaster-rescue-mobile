import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_models.freezed.dart';
part 'team_models.g.dart';

enum TeamType {
  @JsonValue('standing') standing, // Đội thường trực
  @JsonValue('adhoc') adhoc,       // Đội vãng lai (MTQ, thiện nguyện)
}

enum TeamStatus {
  @JsonValue('available') available,   // Sẵn sàng
  @JsonValue('onMission') onMission,   // Đang làm nhiệm vụ
  @JsonValue('resting') resting,       // Tạm nghỉ (bắt buộc lý do + giờ quay lại)
  @JsonValue('offline') offline,       // Mất kết nối (>30 phút im lặng)
  @JsonValue('ended') ended,           // Kết thúc ca
}

@freezed
class RescueTeam with _$RescueTeam {
  const factory RescueTeam({
    required String id,
    required String name,
    required String phone,
    required TeamType type,
    required TeamStatus status,
    required List<String> members,
    required Map<String, double> equipment, // Vật tư biên chế (đội thường trực)
    required Map<String, double> supplies,  // Vật tư mang theo (đội vãng lai)
    required String qrCode,
    required String? restingReason,
    required DateTime? returnTime,
    required DateTime lastActive,
  }) = _RescueTeam;

  factory RescueTeam.fromJson(Map<String, dynamic> json) =>
      _$RescueTeamFromJson(json);
}
