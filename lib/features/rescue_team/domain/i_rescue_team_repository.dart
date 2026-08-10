import '../domain/rescue_team_model.dart';
import '../domain/rescue_team_status.dart';

abstract class IRescueTeamRepository {
  /// Lấy danh sách toàn bộ đội cứu hộ realtime (Cho Admin điều phối)
  Stream<List<RescueTeamModel>> watchAllTeams();

  /// Đăng ký hoặc cập nhật hồ sơ Đội Cứu Hộ
  Future<void> saveRescueTeam(RescueTeamModel team);

  /// Cập nhật vị trí di chuyển của đội cứu hộ (Realtime tracking)
  Future<void> updateTeamLocation(String id, double latitude, double longitude);

  /// Thay đổi trạng thái sẵn sàng (available/onMission/offline)
  Future<void> updateTeamStatus(String id, RescueTeamStatus status);

  /// Chấp nhận nhiệm vụ cứu nạn (Bấm "Tôi đi")
  Future<void> acceptMission(String teamId, String sosId);

  /// Hoàn thành nhiệm vụ cứu nạn (Bấm "Hoàn thành")
  Future<void> completeMission(String teamId, String sosId);
}
