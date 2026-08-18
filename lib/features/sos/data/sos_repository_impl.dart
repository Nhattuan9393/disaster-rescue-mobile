import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../domain/i_sos_repository.dart';
import '../domain/sos_model.dart';
import '../../../core/services/api_sync_service.dart';
import '../../rescue_team/domain/rescue_team_model.dart';
import '../../rescue_team/domain/rescue_team_status.dart';
import '../domain/sos_status.dart';

class SosRepositoryImpl implements ISosRepository {
  final FirebaseFirestore _firestore;
  final Box _queueBox;

  SosRepositoryImpl({
    FirebaseFirestore? firestore,
    Box? queueBox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _queueBox = queueBox ?? HiveService.getSosQueueBox();

  @override
  Stream<List<SosRequestEntity>> watchSosRequests() {
    final controller = StreamController<List<SosRequestEntity>>();
    controller.add(ApiSyncService.currentSosList);
    final subscription = ApiSyncService.sosStream.listen((data) {
      if (!controller.isClosed) {
        controller.add(data);
      }
    });
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    return controller.stream;
  }


  @override
  Future<void> sendSosRequest(SosRequestEntity request) async {
    // Lưu offline cache trong Hive
    final rawJson = jsonEncode(request.toJson());
    await _queueBox.put(request.id, rawJson);
    
    // Đồng bộ lên Cloud thông qua ApiSyncService
    ApiSyncService.addOrUpdateLocalSos(request);
  }

  @override
  Future<void> updateSosStatus(String id, SosStatus status) async {
    AppLogger.i('Cập nhật trạng thái SOS $id thành ${status.name}');
    final list = List<SosRequestEntity>.from(ApiSyncService.currentSosList);
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final updated = list[idx].copyWith(status: status);
      ApiSyncService.addOrUpdateLocalSos(updated);
    }
  }

  @override
  Future<void> assignRescueTeam(String sosId, String teamId) async {
    AppLogger.i('Phân công Đội $teamId cho SOS $sosId');
    
    // 1. Cập nhật SOS status sang assigned và assignedTeamId
    final list = List<SosRequestEntity>.from(ApiSyncService.currentSosList);
    final idx = list.indexWhere((e) => e.id == sosId);
    if (idx >= 0) {
      final updated = list[idx].copyWith(
        status: SosStatus.assigned,
        assignedTeamId: teamId,
      );
      ApiSyncService.addOrUpdateLocalSos(updated);
    }

    // 2. Cập nhật trạng thái Đội cứu hộ tương ứng
    final teams = List<RescueTeamModel>.from(ApiSyncService.currentTeams);
    final tIdx = teams.indexWhere((t) => t.id == teamId);
    if (tIdx >= 0) {
      final updatedTeam = teams[tIdx].copyWith(
        status: RescueTeamStatus.onMission,
        assignedSosId: sosId,
      );
      ApiSyncService.addOrUpdateLocalTeam(updatedTeam);
    }
  }

  @override
  Future<List<SosRequestEntity>> getOfflineQueue() async {
    final list = <SosRequestEntity>[];
    for (var key in _queueBox.keys) {
      final rawJson = _queueBox.get(key) as String?;
      if (rawJson != null) {
        list.add(SosRequestEntity.fromJson(jsonDecode(rawJson)));
      }
    }
    return list;
  }

  @override
  Future<void> removeFromFileQueue(String id) async {
    await _queueBox.delete(id);
    AppLogger.i('Đã xóa SOS $id khỏi local queue');
  }
}
