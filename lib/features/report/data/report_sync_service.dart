import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/logger.dart';
import '../domain/i_report_repository.dart';
import '../domain/assistance_request_model.dart';
import '../domain/situation_report_model.dart';
import 'report_repository_impl.dart';

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepositoryImpl();
});

final reportSyncServiceProvider = Provider<ReportSyncService>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final service = ReportSyncService(ref, repo);
  service.init();
  return service;
});

class ReportSyncService {
  final Ref _ref;
  final IReportRepository _repository;
  final Box _queueBox;
  bool _isSyncing = false;

  ReportSyncService(this._ref, this._repository)
      : _queueBox = HiveService.getReportQueueBox();

  void init() {
    AppLogger.i('Khởi tạo dịch vụ đồng bộ báo cáo ngoại tuyến');
    // Lắng nghe trạng thái mạng
    _ref.listen<bool>(isOnlineProvider, (previous, isOnline) {
      if (isOnline) {
        AppLogger.i('Mạng đã khôi phục. Kích hoạt đồng bộ báo cáo ngoại tuyến...');
        syncPendingReports();
      }
    });

    // Thử chạy đồng bộ ngay khi khởi động
    syncPendingReports();
  }

  Future<void> syncPendingReports() async {
    if (_isSyncing) return;
    if (_queueBox.isEmpty) return;

    _isSyncing = true;
    AppLogger.i('Đang kiểm tra hàng đợi đồng bộ báo cáo: ${_queueBox.length} mục');

    try {
      final keys = List.from(_queueBox.keys);
      for (final key in keys) {
        final rawJson = _queueBox.get(key) as String?;
        if (rawJson == null) continue;

        final payload = jsonDecode(rawJson) as Map<String, dynamic>;
        final type = payload['type'] as String;
        final data = payload['data'] as Map<String, dynamic>;

        try {
          if (type == 'assistance') {
            final request = AssistanceRequestModel.fromJson(data);
            AppLogger.i('Đang đồng bộ yêu cầu hỗ trợ offline: ${request.id}');
            // Gọi trực tiếp để tránh ghi lại vào Hive
            await _repository.sendAssistanceRequest(request);
          } else if (type == 'situation') {
            final report = SituationReportModel.fromJson(data);
            AppLogger.i('Đang đồng bộ báo cáo tình hình offline: ${report.id}');
            await _repository.sendSituationReport(report);
          }
          // Xóa khỏi hàng đợi sau khi thành công
          await _queueBox.delete(key);
        } catch (e) {
          AppLogger.e('Lỗi khi đồng bộ mục báo cáo $key', error: e);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
