import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../../notification/data/notification_inbox_service.dart';
import '../../notification/domain/app_notification.dart';
import '../../rescue_team/domain/rescue_team_status.dart';
import '../domain/i_sos_repository.dart';
import '../domain/sos_model.dart';
import '../domain/sos_status.dart';

/// Firestore-backed SOS repository — thay thế `ApiSyncService` (kvdb.io).
///
/// Model dữ liệu:
/// - `sos_requests/{id}` — chỉ metadata + tình huống; PII lấy từ `households/{id}`.
/// - Hive `sos_queue` — chỉ chứa SOS chưa gửi được lên cloud khi offline
///   (theo RULE-004: Hive không thay thế shared state).
class SosRepositoryImpl implements ISosRepository {
  final FirebaseFirestore _firestore;
  final Box _queueBox;
  final NotificationInboxRepository _inbox;

  SosRepositoryImpl({
    FirebaseFirestore? firestore,
    Box? queueBox,
    NotificationInboxRepository? inbox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _queueBox = queueBox ?? HiveService.getSosQueueBox(),
        _inbox = inbox ?? NotificationInboxRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('sos_requests');

  @override
  Stream<List<SosRequestEntity>> watchSosRequests() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  List<SosRequestEntity> _mapSnapshot(
      QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      _normaliseTimestamps(data, const ['createdAt']);
      return SosRequestEntity.fromJson(data);
    }).toList();
  }

  @override
  Future<void> sendSosRequest(SosRequestEntity request) async {
    // Luôn lưu bản sao vào Hive queue để bảo vệ khi network fail giữa chừng.
    await _queueBox.put(request.id, jsonEncode(request.toJson()));
    try {
      final data = request.toJson();
      // Dùng serverTimestamp để đảm bảo thứ tự chính xác cho admin
      data['createdAt'] = FieldValue.serverTimestamp();
      await _col.doc(request.id).set(data, SetOptions(merge: true));

      // Ghi event log lifecycle
      await _firestore.collection('event_logs').add({
        'sosId': request.id,
        'householdId': request.householdId,
        'action': 'sos_created',
        'message':
            'Hộ ${request.householdId} gửi SOS (điểm ưu tiên ${request.priorityScore}).',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Notify tất cả admin trong xã
      await _inbox.push(
        kind: AppNotificationKind.sosCreated,
        title: '🆘 SOS mới — ${_priorityLabel(request.priorityScore)}',
        body:
            'Hộ ${request.householdId} · ${request.memberCount} người · ${request.sectorLabel ?? "chưa rõ khu vực"}',
        recipientTopics: const ['role_admin_commune_binh_lieu'],
        actionRoute: '/admin',
        data: {'sosId': request.id},
        createdBy: request.householdId,
      );

      // Xoá khỏi Hive queue sau khi push thành công.
      await _queueBox.delete(request.id);
      AppLogger.i('SOS ${request.id} đã đẩy lên Firestore');
    } catch (e, s) {
      AppLogger.w('Không đẩy được SOS ${request.id}, giữ trong Hive queue',
          error: e, stackTrace: s);
      // Giữ trong queue, SosSyncService sẽ retry khi có mạng.
      rethrow;
    }
  }

  @override
  Future<void> updateSosStatus(String id, SosStatus status) async {
    await _col.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('event_logs').add({
      'sosId': id,
      'action': 'sos_status_change',
      'newStatus': status.name,
      'message': 'Trạng thái SOS $id → ${status.name}',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> assignRescueTeam(String sosId, String teamId) async {
    // DR-027: Transaction — hai admin không thể cùng gán 1 SOS.
    await _firestore.runTransaction((tx) async {
      final sosRef = _col.doc(sosId);
      final teamRef = _firestore.collection('rescue_teams').doc(teamId);

      final sosSnap = await tx.get(sosRef);
      final teamSnap = await tx.get(teamRef);

      if (!sosSnap.exists) {
        throw Exception('SOS $sosId không tồn tại');
      }
      if (!teamSnap.exists) {
        throw Exception('Đội cứu hộ $teamId không tồn tại');
      }

      final currentStatus = sosSnap.data()?['status'] as String?;
      final currentAssigned = sosSnap.data()?['assignedTeamId'] as String?;
      if (currentAssigned != null &&
          currentAssigned.isNotEmpty &&
          currentAssigned != teamId) {
        throw Exception(
            'SOS $sosId đã được gán cho đội khác ($currentAssigned)');
      }
      if (currentStatus == SosStatus.completed.name ||
          currentStatus == SosStatus.cancelled.name) {
        throw Exception('SOS $sosId đã kết thúc, không thể gán');
      }

      final teamStatus = teamSnap.data()?['status'] as String?;
      if (teamStatus != RescueTeamStatus.available.name) {
        // FR-09.8: chỉ đội available được nhận SOS mới.
        throw Exception(
            'Đội $teamId đang ở trạng thái $teamStatus, không sẵn sàng');
      }

      tx.update(sosRef, {
        'status': SosStatus.assigned.name,
        'assignedTeamId': teamId,
        'assignedAt': FieldValue.serverTimestamp(),
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
      'action': 'sos_assigned',
      'message': 'Đã gán SOS $sosId cho đội $teamId',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify đội cứu hộ: "Bạn được gán SOS mới"
    await _inbox.push(
      kind: AppNotificationKind.sosAssigned,
      title: '⛑️ Nhiệm vụ mới — SOS $sosId',
      body: 'Bạn vừa được gán ca cứu hộ. Bấm để xem chi tiết.',
      recipientTopics: ['team_$teamId'],
      actionRoute: '/rescue-sos-detail?sosId=$sosId',
      data: {'sosId': sosId, 'teamId': teamId},
    );
  }

  static String _priorityLabel(int score) {
    if (score >= 70) return 'ĐỎ $score';
    if (score >= 40) return 'CAM $score';
    return 'VÀNG $score';
  }

  @override
  Future<List<SosRequestEntity>> getOfflineQueue() async {
    final list = <SosRequestEntity>[];
    for (final key in _queueBox.keys) {
      final raw = _queueBox.get(key) as String?;
      if (raw != null) {
        list.add(SosRequestEntity.fromJson(jsonDecode(raw)));
      }
    }
    return list;
  }

  @override
  Future<void> removeFromFileQueue(String id) async {
    await _queueBox.delete(id);
  }

  static void _normaliseTimestamps(
      Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is Timestamp) {
        data[k] = v.toDate().toIso8601String();
      }
    }
  }
}
