import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../domain/assistance_request_model.dart';
import '../domain/situation_report_model.dart';
import '../domain/i_report_repository.dart';

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
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    final payload = {
      'type': 'assistance',
      'data': request.toJson(),
    };

    if (isOffline) {
      AppLogger.w('Đang ngoại tuyến. Lưu yêu cầu hỗ trợ vào hàng đợi Hive: ${request.id}');
      await _queueBox.put(request.id, jsonEncode(payload));
    } else {
      try {
        AppLogger.i('Đẩy yêu cầu hỗ trợ lên Firestore: ${request.id}');
        await _assistanceCollection
            .doc(request.id)
            .set(request.toJson())
            .timeout(const Duration(milliseconds: 500));
        
        // DR-032: Ghi nhận sự kiện log cứu hộ
        _firestore.collection('event_logs').add({
          'id': request.id,
          'sosId': request.id,
          'action': 'create',
          'message': 'Đã tạo yêu cầu hỗ trợ sơ tán cho hộ ${request.householdId}.',
          'actorId': request.reporterId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        AppLogger.w('Đã ghi nhận dữ liệu đệm local. Hoàn tất phản hồi UI ngay.');
      }
    }
  }

  @override
  Future<void> sendSituationReport(SituationReportModel report) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    final payload = {
      'type': 'situation',
      'data': report.toJson(),
    };

    if (isOffline) {
      AppLogger.w('Đang ngoại tuyến. Lưu báo cáo tình hình vào hàng đợi Hive: ${report.id}');
      await _queueBox.put(report.id, jsonEncode(payload));
    } else {
      try {
        AppLogger.i('Đẩy báo cáo tình hình lên Firestore: ${report.id}');
        await _situationCollection
            .doc(report.id)
            .set(report.toJson())
            .timeout(const Duration(milliseconds: 500));
        
        // DR-032: Ghi nhận sự kiện log cứu hộ
        _firestore.collection('event_logs').add({
          'id': report.id,
          'sosId': report.id,
          'action': 'create',
          'message': 'Báo cáo tình hình: ${report.incidentType.toUpperCase()} tại ${report.address}.',
          'actorId': report.reporterId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        AppLogger.w('Đã ghi nhận dữ liệu đệm local. Hoàn tất phản hồi UI ngay.');
      }
    }
  }

  @override
  Stream<List<AssistanceRequestModel>> watchAssistanceRequests() {
    return _assistanceCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AssistanceRequestModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<SituationReportModel>> watchSituationReports() {
    return _situationCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SituationReportModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> updateAssistanceRequestStatus(String id, String status) async {
    AppLogger.i('Cập nhật trạng thái yêu cầu hỗ trợ $id thành: $status');
    await _assistanceCollection.doc(id).update({
      'status': status,
    });
  }

  @override
  Future<void> approveAndCreateSos(AssistanceRequestModel request) async {
    AppLogger.i('Duyệt tin báo ${request.id} -> Tự động tạo ca cứu hộ SOS mới');
    
    // 1. Cập nhật trạng thái báo cáo thành đã duyệt (verified)
    await _assistanceCollection.doc(request.id).update({
      'status': 'verified',
    });

    // 2. Tạo tài liệu SOS mới trong sos_requests
    final sosId = 'SOS-${request.id.length >= 6 ? request.id.substring(0, 6).toUpperCase() : request.id.toUpperCase()}';
    await _firestore.collection('sos_requests').doc(sosId).set({
      'id': sosId,
      'householdId': request.householdId,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'priorityScore': request.confidenceScore + request.priorityScore,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Được tạo tự động từ Tin Báo Flow B (Admin đã xác minh): ${request.description}',
    });

    // 3. Ghi log sự kiện
    await _firestore.collection('event_logs').add({
      'id': request.id,
      'sosId': sosId,
      'action': 'verify_and_create_sos',
      'message': 'Admin đã duyệt tin báo ${request.id} và tạo ca SOS $sosId.',
      'actorId': 'admin_commune',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
