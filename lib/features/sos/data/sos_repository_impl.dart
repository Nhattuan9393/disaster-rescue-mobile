import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../domain/i_sos_repository.dart';
import '../domain/sos_model.dart';
import '../domain/sos_status.dart';

class SosRepositoryImpl implements ISosRepository {
  final FirebaseFirestore _firestore;
  final Box _queueBox;

  SosRepositoryImpl({
    FirebaseFirestore? firestore,
    Box? queueBox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _queueBox = queueBox ?? HiveService.getSosQueueBox();

  CollectionReference<Map<String, dynamic>> get _sosCollection =>
      _firestore.collection('sos_requests');

  CollectionReference<Map<String, dynamic>> get _logCollection =>
      _firestore.collection('event_logs');

  @override
  Stream<List<SosRequestEntity>> watchSosRequests() {
    return _sosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SosRequestEntity.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> sendSosRequest(SosRequestEntity request) async {
    if (request.isOffline) {
      // DR-019: Lưu vào hàng đợi Hive nếu ngoại tuyến
      AppLogger.w('Đang ngoại tuyến. Lưu SOS vào local queue: ${request.id}');
      final rawJson = jsonEncode(request.toJson());
      await _queueBox.put(request.id, rawJson);
    } else {
      // DR-018: Đẩy thẳng lên Firestore nếu trực tuyến
      AppLogger.i('Đang trực tuyến. Đẩy SOS lên Cloud: ${request.id}');
      
      final batch = _firestore.batch();
      batch.set(_sosCollection.doc(request.id), request.toJson());
      
      // DR-032: Tự động ghi nhật ký Event Log
      final logId = const Uuid().v4();
      batch.set(_logCollection.doc(logId), {
        'id': logId,
        'sosId': request.id,
        'action': 'create',
        'message': 'Phát tín hiệu SOS khẩn cấp.',
        'actorId': request.householdId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await batch.commit();
    }
  }

  @override
  Future<void> updateSosStatus(String id, SosStatus status) async {
    AppLogger.i('Cập nhật trạng thái SOS $id thành ${status.name}');
    await _sosCollection.doc(id).update({
      'status': status.name,
    });
  }

  @override
  Future<void> assignRescueTeam(String sosId, String teamId) async {
    // DR-027: Gán đội sử dụng cơ chế Transaction để tránh tranh chấp (Atomic)
    final sosDocRef = _sosCollection.doc(sosId);
    final teamDocRef = _firestore.collection('rescue_teams').doc(teamId);
    final logDocRef = _logCollection.doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final sosSnapshot = await transaction.get(sosDocRef);
        final teamSnapshot = await transaction.get(teamDocRef);

        if (!sosSnapshot.exists) {
          throw Exception("Yêu cầu cứu hộ không tồn tại");
        }
        if (!teamSnapshot.exists) {
          throw Exception("Đội cứu hộ không tồn tại");
        }

        final sosData = sosSnapshot.data();
        final teamData = teamSnapshot.data();

        final currentSosStatus = sosData?['status'] as String?;
        final currentSosTeam = sosData?['assignedTeamId'] as String?;
        final currentTeamStatus = teamData?['status'] as String?;

        if (currentSosStatus == SosStatus.assigned.name || currentSosTeam != null) {
          throw Exception("SOS này đã được bàn giao cho đội cứu hộ khác!");
        }
        if (currentTeamStatus != 'available') {
          throw Exception("Đội cứu hộ này đang bận hoặc offline, không thể bàn giao!");
        }

        // 1. Cập nhật trạng thái SOS
        transaction.update(sosDocRef, {
          'status': SosStatus.assigned.name,
          'assignedTeamId': teamId,
        });

        // 2. Cập nhật gán việc cho Đội
        transaction.update(teamDocRef, {
          'assignedSosId': sosId,
        });

        // 3. DR-032: Ghi nhận Event Log gán việc
        transaction.set(logDocRef, {
          'id': logDocRef.id,
          'sosId': sosId,
          'action': 'assign',
          'message': 'Admin phân công đội cứu hộ.',
          'actorId': 'admin',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      AppLogger.w('Transaction thất bại (có thể do chạy Offline/Cache). Thử cập nhật trực tiếp...');
      
      // Fallback trực tiếp (hoạt động tốt với offline cache của Firestore)
      await sosDocRef.update({
        'status': SosStatus.assigned.name,
        'assignedTeamId': teamId,
      });

      await teamDocRef.update({
        'assignedSosId': sosId,
      });

      await logDocRef.set({
        'id': logDocRef.id,
        'sosId': sosId,
        'action': 'assign',
        'message': 'Admin phân công đội cứu hộ (Cập nhật Ngoại Tuyến).',
        'actorId': 'admin',
        'timestamp': DateTime.now().toIso8601String(),
      });
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
