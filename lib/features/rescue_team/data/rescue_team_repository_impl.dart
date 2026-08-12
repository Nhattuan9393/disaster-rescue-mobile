import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/i_rescue_team_repository.dart';
import '../domain/rescue_team_model.dart';
import '../domain/rescue_team_status.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/api_sync_service.dart';
import '../../sos/domain/sos_model.dart';
import '../../sos/domain/sos_status.dart';

class RescueTeamRepositoryImpl implements IRescueTeamRepository {
  final FirebaseFirestore _firestore;

  RescueTeamRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<RescueTeamModel>> watchAllTeams() {
    return ApiSyncService.teamsStream;
  }

  @override
  Future<void> saveRescueTeam(RescueTeamModel team) async {
    AppLogger.i('Lưu thông tin đội cứu hộ: ${team.name}');
    ApiSyncService.addOrUpdateLocalTeam(team);
  }

  @override
  Future<void> updateTeamLocation(String id, double latitude, double longitude) async {
    AppLogger.d('Cập nhật GPS Đội cứu hộ $id: ($latitude, $longitude)');
    final teams = List<RescueTeamModel>.from(ApiSyncService.currentTeams);
    final idx = teams.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final updated = teams[idx].copyWith(
        currentLatitude: latitude,
        currentLongitude: longitude,
      );
      ApiSyncService.addOrUpdateLocalTeam(updated);
    }
  }

  @override
  Future<void> updateTeamStatus(String id, RescueTeamStatus status) async {
    AppLogger.i('Cập nhật trạng thái Đội $id thành: ${status.name}');
    final teams = List<RescueTeamModel>.from(ApiSyncService.currentTeams);
    final idx = teams.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final updated = teams[idx].copyWith(status: status);
      ApiSyncService.addOrUpdateLocalTeam(updated);
    }
  }

  @override
  Future<void> acceptMission(String teamId, String sosId) async {
    AppLogger.i('Đội $teamId chấp nhận nhiệm vụ SOS $sosId');
    
    // 1. Cập nhật Đội cứu hộ sang onMission
    final teams = List<RescueTeamModel>.from(ApiSyncService.currentTeams);
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx >= 0) {
      final updatedTeam = teams[idx].copyWith(
        status: RescueTeamStatus.onMission,
        assignedSosId: sosId,
      );
      ApiSyncService.addOrUpdateLocalTeam(updatedTeam);
    }

    // 2. Cập nhật SOS sang inProgress (Đang xử lý)
    final sosList = List<SosRequestEntity>.from(ApiSyncService.currentSosList);
    final sosIdx = sosList.indexWhere((s) => s.id == sosId);
    if (sosIdx >= 0) {
      final updatedSos = sosList[sosIdx].copyWith(
        status: SosStatus.inProgress,
      );
      ApiSyncService.addOrUpdateLocalSos(updatedSos);
    }
  }

  @override
  Future<void> completeMission(String teamId, String sosId) async {
    AppLogger.i('Đội $teamId hoàn thành nhiệm vụ SOS $sosId');
    
    // 1. Giải phóng Đội về available và xóa assignedSosId
    final teams = List<RescueTeamModel>.from(ApiSyncService.currentTeams);
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx >= 0) {
      final updatedTeam = teams[idx].copyWith(
        status: RescueTeamStatus.available,
        assignedSosId: null,
      );
      ApiSyncService.addOrUpdateLocalTeam(updatedTeam);
    }

    // 2. Cập nhật SOS sang completed (Đã hoàn thành)
    final sosList = List<SosRequestEntity>.from(ApiSyncService.currentSosList);
    final sosIdx = sosList.indexWhere((s) => s.id == sosId);
    if (sosIdx >= 0) {
      final updatedSos = sosList[sosIdx].copyWith(
        status: SosStatus.completed,
      );
      ApiSyncService.addOrUpdateLocalSos(updatedSos);
    }
  }
}
