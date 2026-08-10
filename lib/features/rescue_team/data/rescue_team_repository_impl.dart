import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/i_rescue_team_repository.dart';
import '../domain/rescue_team_model.dart';
import '../domain/rescue_team_status.dart';
import '../../../../core/utils/logger.dart';

class RescueTeamRepositoryImpl implements IRescueTeamRepository {
  final FirebaseFirestore _firestore;

  RescueTeamRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teamCollection =>
      _firestore.collection('rescue_teams');

  @override
  Stream<List<RescueTeamModel>> watchAllTeams() {
    return _teamCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RescueTeamModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> saveRescueTeam(RescueTeamModel team) async {
    AppLogger.i('Lưu thông tin đội cứu hộ: ${team.name}');
    await _teamCollection.doc(team.id).set(team.toJson());
  }

  @override
  Future<void> updateTeamLocation(String id, double latitude, double longitude) async {
    AppLogger.d('Cập nhật GPS Đội cứu hộ $id: ($latitude, $longitude)');
    await _teamCollection.doc(id).update({
      'currentLatitude': latitude,
      'currentLongitude': longitude,
    });
  }

  @override
  Future<void> updateTeamStatus(String id, RescueTeamStatus status) async {
    AppLogger.i('Cập nhật trạng thái Đội $id thành: ${status.name}');
    await _teamCollection.doc(id).update({
      'status': status.name,
    });
  }

  @override
  Future<void> acceptMission(String teamId, String sosId) async {
    final teamDocRef = _teamCollection.doc(teamId);
    final sosDocRef = _firestore.collection('sos_requests').doc(sosId);
    final logDocRef = _firestore.collection('event_logs').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Cập nhật trạng thái Đội Cứu Hộ sang onMission
        transaction.update(teamDocRef, {
          'status': RescueTeamStatus.onMission.name,
        });

        // 2. Cập nhật trạng thái SOS sang inProgress (Đang xử lý)
        transaction.update(sosDocRef, {
          'status': 'inProgress', // SosStatus.inProgress
        });

        // 3. Ghi nhận Event Log
        transaction.set(logDocRef, {
          'id': logDocRef.id,
          'sosId': sosId,
          'action': 'accept',
          'message': 'Đội cứu hộ đã chấp nhận nhiệm vụ và đang di chuyển.',
          'actorId': teamId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      AppLogger.w('acceptMission transaction thất bại, thử update trực tiếp...');
      await teamDocRef.update({
        'status': RescueTeamStatus.onMission.name,
      });
      await sosDocRef.update({
        'status': 'inProgress',
      });
      await logDocRef.set({
        'id': logDocRef.id,
        'sosId': sosId,
        'action': 'accept',
        'message': 'Đội cứu hộ đã chấp nhận nhiệm vụ (Cập nhật Ngoại Tuyến).',
        'actorId': teamId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    AppLogger.i('Đội $teamId đã chấp nhận nhiệm vụ SOS $sosId');
  }

  @override
  Future<void> completeMission(String teamId, String sosId) async {
    final teamDocRef = _teamCollection.doc(teamId);
    final sosDocRef = _firestore.collection('sos_requests').doc(sosId);
    final logDocRef = _firestore.collection('event_logs').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Giải phóng Đội cứu hộ về available và xóa assignedSosId
        transaction.update(teamDocRef, {
          'status': RescueTeamStatus.available.name,
          'assignedSosId': FieldValue.delete(),
        });

        // 2. Chuyển trạng thái SOS sang completed (Đã xong)
        transaction.update(sosDocRef, {
          'status': 'completed', // SosStatus.completed
        });

        // 3. Ghi nhận Event Log
        transaction.set(logDocRef, {
          'id': logDocRef.id,
          'sosId': sosId,
          'action': 'complete',
          'message': 'Đội cứu hộ báo cáo đã hoàn thành cứu hộ.',
          'actorId': teamId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      AppLogger.w('completeMission transaction thất bại, thử update trực tiếp...');
      await teamDocRef.update({
        'status': RescueTeamStatus.available.name,
        'assignedSosId': FieldValue.delete(),
      });
      await sosDocRef.update({
        'status': 'completed',
      });
      await logDocRef.set({
        'id': logDocRef.id,
        'sosId': sosId,
        'action': 'complete',
        'message': 'Đội cứu hộ đã hoàn thành nhiệm vụ (Cập nhật Ngoại Tuyến).',
        'actorId': teamId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    AppLogger.i('Đội $teamId đã hoàn thành nhiệm vụ SOS $sosId');
  }
}
