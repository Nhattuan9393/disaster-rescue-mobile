import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/assistance_request_model.dart';
import '../../domain/situation_report_model.dart';
import '../../data/report_sync_service.dart';

// Stream của tất cả yêu cầu hỗ trợ (Flow B)
final allAssistanceRequestsStreamProvider = StreamProvider<List<AssistanceRequestModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.watchAssistanceRequests();
});

// Stream của tất cả báo cáo tình hình (Flow C)
final allSituationReportsStreamProvider = StreamProvider<List<SituationReportModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.watchSituationReports();
});

// Trạng thái cho ReportController
class ReportState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ReportState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ReportState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// Controller quản lý gửi Báo Cáo
final reportControllerProvider = StateNotifierProvider<ReportController, ReportState>((ref) {
  return ReportController(ref);
});

class ReportController extends StateNotifier<ReportState> {
  final Ref _ref;

  ReportController(this._ref) : super(const ReportState());

  Future<void> submitAssistanceRequest({
    required String householdId,
    required String reporterId,
    required double latitude,
    required double longitude,
    required String address,
    required String description,
    required List<String> neededSupports,
    required String urgencyWindow,
    required int confidenceScore,
    String? targetEvacuationPointId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(reportRepositoryProvider);
      final id = const Uuid().v4();
      
      final request = AssistanceRequestModel(
        id: id,
        householdId: householdId,
        reporterId: reporterId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        neededSupports: neededSupports,
        priorityScore: neededSupports.length * 15 + (urgencyWindow == '1h' ? 25 : 10),
        urgencyWindow: urgencyWindow,
        targetEvacuationPointId: targetEvacuationPointId,
        status: 'pending',
        confidenceScore: confidenceScore,
        timestamp: DateTime.now(),
      );

      await repo.sendAssistanceRequest(request);
      state = state.copyWith(isLoading: false, successMessage: 'Đã gửi yêu cầu hỗ trợ thành công!');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi gửi tin: ${e.toString()}');
    }
  }

  Future<void> submitSituationReport({
    required String reporterId,
    required double latitude,
    required double longitude,
    required String address,
    required String incidentType,
    required String description,
    required List<String> photoUrls,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(reportRepositoryProvider);
      final id = const Uuid().v4();

      final report = SituationReportModel(
        id: id,
        reporterId: reporterId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        incidentType: incidentType,
        description: description,
        photoUrls: photoUrls,
        timestamp: DateTime.now(),
      );

      await repo.sendSituationReport(report);
      state = state.copyWith(isLoading: false, successMessage: 'Đã gửi báo cáo tình hình thành công!');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi gửi báo cáo: ${e.toString()}');
    }
  }

  Future<void> approveRequest(AssistanceRequestModel request) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(reportRepositoryProvider);
      await repo.approveAndCreateSos(request);
      state = state.copyWith(isLoading: false, successMessage: 'Đã duyệt tin báo và tạo ca SOS thành công!');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi duyệt báo cáo: ${e.toString()}');
    }
  }

  Future<void> rejectRequest(String requestId) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(reportRepositoryProvider);
      await repo.updateAssistanceRequestStatus(requestId, 'rejected');
      state = state.copyWith(isLoading: false, successMessage: 'Đã từ chối báo cáo thành công.');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi từ chối báo cáo: ${e.toString()}');
    }
  }
}
