import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';

class ReportToCommuneState {
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  ReportToCommuneState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  ReportToCommuneState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return ReportToCommuneState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class ReportToCommuneNotifier extends StateNotifier<ReportToCommuneState> {
  final Ref _ref;

  ReportToCommuneNotifier(this._ref) : super(ReportToCommuneState());

  Future<bool> submitReportB({
    required String address,
    required String description,
  }) async {
    if (address.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập địa chỉ / vị trí.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final payload = {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'type': 'helpOther',
        'address': address,
        'description': description,
        'confidenceScore': 35,
        'latitude': 21.0285,
        'longitude': 105.8542,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _ref.read(offlineQueueProvider.notifier).addRequest('report_to_commune', payload);

      if (!mounted) return true;

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Đã gửi báo tin giúp người khác. Đang lưu ngoại tuyến nếu mất mạng.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Có lỗi xảy ra khi lưu báo cáo.',
      );
      return false;
    }
  }

  Future<bool> submitReportC({
    required String incidentType,
    required String location,
    required String description,
  }) async {
    if (incidentType.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn loại sự cố.');
      return false;
    }
    if (location.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập vị trí.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final payload = {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'type': 'areaReport',
        'incidentType': incidentType,
        'location': location,
        'description': description,
        'latitude': 21.0285,
        'longitude': 105.8542,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _ref.read(offlineQueueProvider.notifier).addRequest('report_to_commune', payload);

      if (!mounted) return true;

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Đã gửi báo tình hình khu vực. Đang lưu ngoại tuyến nếu mất mạng.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Có lỗi xảy ra khi lưu báo cáo.',
      );
      return false;
    }
  }
}

final reportToCommuneProvider =
    StateNotifierProvider.autoDispose<ReportToCommuneNotifier, ReportToCommuneState>((ref) {
  return ReportToCommuneNotifier(ref);
});
