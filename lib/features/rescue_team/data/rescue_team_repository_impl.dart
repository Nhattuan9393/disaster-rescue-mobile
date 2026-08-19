import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/logger.dart';
import '../../notification/data/notification_inbox_service.dart';
import '../../notification/domain/app_notification.dart';
import '../../sos/domain/sos_status.dart';
import '../domain/i_rescue_team_repository.dart';
import '../domain/rescue_team_model.dart';
import '../domain/rescue_team_status.dart';

/// Firestore-backed rescue team repository. Realtime qua snapshots — thay
/// thế ApiSyncService (kvdb.io) đã bỏ.
class RescueTeamRepositoryImpl implements IRescueTeamRepository {
  final FirebaseFirestore _firestore;
  final NotificationInboxRepository _inbox;

  RescueTeamRepositoryImpl({
    FirebaseFirestore? firestore,
    NotificationInboxRepository? inbox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _inbox = inbox ?? NotificationInboxRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('rescue_teams');

  Future<void> _seedDefaultTeamsIfEmpty() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isEmpty) {
      AppLogger.i('Seeding default rescue teams...');
      final defaults = [
        const RescueTeamModel(
          id: 'team_01',
          name: 'Đội Dân quân Thôn Pắc Liềng',
          leaderName: 'Trưởng thôn',
          contactPhone: '0912 345 678',
          status: RescueTeamStatus.onMission,
          currentLatitude: 21.5284,
          currentLongitude: 107.3986,
          teamType: RescueTeamKind.permanent,
          isApproved: true,
          memberCount: 8,
          boatCount: 2,
        ),
        const RescueTeamModel(
          id: 'team_02',
          name: 'Tổ Xung kích Nà Lầu',
          leaderName: 'Tổ trưởng',
          contactPhone: '0912 345 679',
          status: RescueTeamStatus.onBreak,
          currentLatitude: 21.5320,
          currentLongitude: 107.3910,
          teamType: RescueTeamKind.permanent,
          isApproved: true,
          memberCount: 6,
          boatCount: 1,
        ),
        const RescueTeamModel(
          id: 'team_03',
          name: 'Đội Cứu Hộ Công An Xã',
          leaderName: 'Công an trưởng',
          contactPhone: '0912 345 680',
          status: RescueTeamStatus.available,
          currentLatitude: 21.5284,
          currentLongitude: 107.3986,
          teamType: RescueTeamKind.permanent,
          isApproved: true,
          memberCount: 10,
          boatCount: 2,
        ),
        const RescueTeamModel(
          id: 'team_04',
          name: 'Đội Y tế xã Bình Liêu',
          leaderName: 'Trạm trưởng',
          contactPhone: '0912 345 681',
          status: RescueTeamStatus.offline,
          currentLatitude: 21.5284,
          currentLongitude: 107.3986,
          teamType: RescueTeamKind.permanent,
          isApproved: true,
          memberCount: 4,
          boatCount: 0,
        ),
        const RescueTeamModel(
          id: 'team_05',
          name: 'Hội Chữ thập đỏ Hạ Long',
          leaderName: 'Chủ tịch Hội',
          contactPhone: '0912 345 682',
          status: RescueTeamStatus.available,
          currentLatitude: 21.5284,
          currentLongitude: 107.3986,
          teamType: RescueTeamKind.volunteer,
          isApproved: true,
          memberCount: 15,
          boatCount: 0,
        ),
      ];
      for (final t in defaults) {
        await _col.doc(t.id).set(t.toJson());
      }
    }
  }

  @override
  Stream<List<RescueTeamModel>> watchAllTeams() {
    _seedDefaultTeamsIfEmpty();
    return _col.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        _normaliseTimestamps(data, const ['lastHeartbeatAt']);
        return RescueTeamModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> saveRescueTeam(RescueTeamModel team) async {
    final data = team.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(team.id).set(data, SetOptions(merge: true));
    AppLogger.i('Lưu đội cứu hộ ${team.name}');
  }

  @override
  Future<void> updateTeamLocation(
      String id, double latitude, double longitude) async {
    await _col.doc(id).update({
      'currentLatitude': latitude,
      'currentLongitude': longitude,
      'lastHeartbeatAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTeamStatus(String id, RescueTeamStatus status) async {
    final update = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status != RescueTeamStatus.onBreak) {
      update['breakInfo'] = FieldValue.delete();
    }
    if (status != RescueTeamStatus.onMission) {
      update['assignedSosId'] = FieldValue.delete();
    }
    await _col.doc(id).update(update);
    await _firestore.collection('event_logs').add({
      'teamId': id,
      'action': 'team_status_change',
      'newStatus': status.name,
      'message': 'Đội $id → ${status.label}',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Bổ sung API cho màn "Trạng thái đội của tôi" — kèm lý do & giờ quay lại
  /// khi status == onBreak.
  Future<void> setBreakStatus(
    String id, {
    required String reason,
    required DateTime plannedReturnAt,
  }) async {
    await _col.doc(id).update({
      'status': RescueTeamStatus.onBreak.name,
      'breakInfo': {
        'reason': reason,
        'plannedReturnAt': plannedReturnAt.toIso8601String(),
      },
      'assignedSosId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptMission(String teamId, String sosId) async {
    // DR-028: transaction để đội C không thể chấp nhận SOS đã bị đội khác lấy.
    await _firestore.runTransaction((tx) async {
      final sosRef = _firestore.collection('sos_requests').doc(sosId);
      final teamRef = _col.doc(teamId);

      final sosSnap = await tx.get(sosRef);
      final teamSnap = await tx.get(teamRef);

      if (!sosSnap.exists) throw Exception('SOS $sosId không tồn tại');
      if (!teamSnap.exists) throw Exception('Đội $teamId không tồn tại');

      final assignedTeamId = sosSnap.data()?['assignedTeamId'] as String?;
      if (assignedTeamId != teamId) {
        throw Exception('SOS $sosId không được gán cho đội của bạn');
      }
      final status = sosSnap.data()?['status'] as String?;
      if (status != SosStatus.assigned.name) {
        throw Exception('SOS $sosId không ở trạng thái assigned (đang $status)');
      }

      tx.update(sosRef, {
        'status': SosStatus.inProgress.name,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(teamRef, {
        'status': RescueTeamStatus.onMission.name,
        'assignedSosId': sosId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _firestore.collection('event_logs').add({
      'sosId': sosId,
      'teamId': teamId,
      'action': 'sos_accepted',
      'message': 'Đội $teamId nhận nhiệm vụ SOS $sosId ("Tôi đi")',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify hộ dân: "Đội đang trên đường"
    final sosData = (await _firestore.collection('sos_requests').doc(sosId).get()).data();
    final householdId = sosData?['householdId'] as String?;
    if (householdId != null) {
      await _inbox.push(
        kind: AppNotificationKind.sosInProgress,
        title: '🚗 Đội cứu hộ đang tới',
        body: 'Đội $teamId đang di chuyển tới nhà bạn.',
        recipientTopics: ['household_$householdId'],
        actionRoute: '/resident',
        data: {'sosId': sosId, 'teamId': teamId},
      );
    }
  }

  @override
  Future<void> completeMission(String teamId, String sosId) async {
    await _firestore.runTransaction((tx) async {
      final sosRef = _firestore.collection('sos_requests').doc(sosId);
      final teamRef = _col.doc(teamId);

      final sosSnap = await tx.get(sosRef);
      if (!sosSnap.exists) throw Exception('SOS $sosId không tồn tại');

      tx.update(sosRef, {
        'status': SosStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(teamRef, {
        'status': RescueTeamStatus.available.name,
        'assignedSosId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _firestore.collection('event_logs').add({
      'sosId': sosId,
      'teamId': teamId,
      'action': 'sos_completed',
      'message': 'Đội $teamId hoàn thành SOS $sosId',
      'timestamp': FieldValue.serverTimestamp(),
    });

    final sosData =
        (await _firestore.collection('sos_requests').doc(sosId).get()).data();
    final householdId = sosData?['householdId'] as String?;
    if (householdId != null) {
      await _inbox.push(
        kind: AppNotificationKind.sosCompleted,
        title: '✅ Đã hoàn thành cứu hộ',
        body: 'Ca cứu hộ SOS $sosId đã kết thúc. Đội đã ghi báo cáo.',
        recipientTopics: ['household_$householdId'],
        actionRoute: '/resident',
        data: {'sosId': sosId},
      );
    }
    // Notify admin
    await _inbox.push(
      kind: AppNotificationKind.sosCompleted,
      title: '✅ SOS $sosId đã hoàn thành',
      body: 'Đội $teamId báo cáo hoàn tất.',
      recipientTopics: const ['role_admin_commune_binh_lieu'],
      actionRoute: '/admin',
      data: {'sosId': sosId, 'teamId': teamId},
    );
  }

  @override
  Future<void> approveVolunteerTeam(String id) async {
    await _col.doc(id).update({
      'isApproved': true,
      'status': RescueTeamStatus.available.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectVolunteerTeam(String id) async {
    await _col.doc(id).delete();
  }

  static void _normaliseTimestamps(
      Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is Timestamp) data[k] = v.toDate().toIso8601String();
    }
  }
}
