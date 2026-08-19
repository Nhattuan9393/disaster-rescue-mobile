import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../../sos/domain/sos_status.dart';
import '../domain/assistance_request_model.dart';
import '../domain/i_report_repository.dart';
import '../domain/situation_report_model.dart';

/// Firestore-backed report repository. Bỏ ApiSyncService (kvdb.io) — mọi máy
/// đọc trực tiếp từ Firestore snapshots.
class ReportRepositoryImpl implements IReportRepository {
  final FirebaseFirestore _firestore;
  final Box _queueBox;

  ReportRepositoryImpl({
    FirebaseFirestore? firestore,
    Box? queueBox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _queueBox = queueBox ?? HiveService.getReportQueueBox();

  CollectionReference<Map<String, dynamic>> get _assistanceCollection =>
      _firestore.collection('assistance_requests');

  CollectionReference<Map<String, dynamic>> get _situationCollection =>
      _firestore.collection('situation_reports');

  @override
  Future<void> sendAssistanceRequest(AssistanceRequestModel request) async {
    final isOffline = await _isOffline();

    final payload = {
      'type': 'assistance',
      'data': request.toJson(),
    };

    if (isOffline) {
      AppLogger.w('Offline. Đưa yêu cầu hỗ trợ vào queue: ${request.id}');
      await _queueBox.put(request.id, jsonEncode(payload));
      return;
    }

    try {
      final data = Map<String, dynamic>.from(request.toJson());
      data['timestamp'] = FieldValue.serverTimestamp();
      await _assistanceCollection.doc(request.id).set(data);

      await _firestore.collection('event_logs').add({
        'sosId': request.id,
        'action': 'assistance_created',
        'message':
            'Yêu cầu hỗ trợ ${request.id} — hộ ${request.householdId} — ${request.urgencyWindow}',
        'actorId': request.reporterId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, s) {
      AppLogger.e('Không đẩy được assistance ${request.id}, giữ queue',
          error: e, stackTrace: s);
      await _queueBox.put(request.id, jsonEncode(payload));
    }
  }

  @override
  Future<void> sendSituationReport(SituationReportModel report) async {
    final isOffline = await _isOffline();
    final payload = {
      'type': 'situation',
      'data': report.toJson(),
    };
    if (isOffline) {
      await _queueBox.put(report.id, jsonEncode(payload));
      return;
    }
    try {
      final data = Map<String, dynamic>.from(report.toJson());
      data['timestamp'] = FieldValue.serverTimestamp();
      await _situationCollection.doc(report.id).set(data);

      await _firestore.collection('event_logs').add({
        'sosId': report.id,
        'action': 'situation_report_created',
        'message':
            'Báo cáo tình hình: ${report.incidentType.toUpperCase()} tại ${report.address}',
        'actorId': report.reporterId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.w('Không đẩy được situation ${report.id}, giữ queue',
          error: e);
      await _queueBox.put(report.id, jsonEncode(payload));
    }
  }

  @override
  Stream<List<AssistanceRequestModel>> watchAssistanceRequests() {
    return _assistanceCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        _normaliseTimestamps(data, const ['timestamp']);
        return AssistanceRequestModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<SituationReportModel>> watchSituationReports() {
    return _situationCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        _normaliseTimestamps(data, const ['timestamp']);
        return SituationReportModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> updateAssistanceRequestStatus(String id, String status) async {
    await _assistanceCollection.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> approveAndCreateSos(AssistanceRequestModel request) async {
    AppLogger.i('Duyệt tin báo ${request.id} → tạo ca SOS mới');
    await _assistanceCollection.doc(request.id).update({
      'status': 'verified',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final sosId = 'SOS-${DateTime.now().millisecondsSinceEpoch}';
    await _firestore.collection('sos_requests').doc(sosId).set({
      'id': sosId,
      'householdId': request.householdId,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'priorityScore': request.priorityScore,
      'status': SosStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'note': 'Tạo từ tin báo Flow B: ${request.description}',
      'sectorLabel': request.address,
    });

    await _firestore.collection('event_logs').add({
      'sosId': sosId,
      'assistanceRequestId': request.id,
      'action': 'verify_and_create_sos',
      'message':
          'Admin duyệt tin báo ${request.id} → tạo ca SOS $sosId',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _isOffline() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.none);
  }

  static void _normaliseTimestamps(
      Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is Timestamp) data[k] = v.toDate().toIso8601String();
    }
  }
}
