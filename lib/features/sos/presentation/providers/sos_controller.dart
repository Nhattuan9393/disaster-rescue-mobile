import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/gps_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/sos_model.dart';
import '../../domain/sos_status.dart';
import '../../domain/sos_priority_calculator.dart';
import '../../data/sos_sync_service.dart';
import '../../../household/domain/household_model.dart';

class SosState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final DateTime? lastSentTime;

  SosState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.lastSentTime,
  });

  SosState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    DateTime? lastSentTime,
  }) {
    return SosState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      lastSentTime: lastSentTime ?? this.lastSentTime,
    );
  }
}

class SosController extends StateNotifier<SosState> {
  final Ref _ref;
  static const Duration debounceDuration = Duration(seconds: 30);

  SosController(this._ref) : super(SosState());

  Future<void> triggerSOS({
    required HouseholdModel household,
    required bool isWaterAtRoof,
    required bool isInjured,
  }) async {
    final now = DateTime.now();

    // DR-022: Debounce chống spam nếu bấm quá nhanh
    if (state.lastSentTime != null &&
        now.difference(state.lastSentTime!) < debounceDuration) {
      final secondsLeft = debounceDuration.inSeconds - now.difference(state.lastSentTime!).inSeconds;
      state = state.copyWith(
        errorMessage: 'Vui lòng đợi $secondsLeft giây trước khi gửi lại SOS!',
      );
      AppLogger.w('Spam SOS bị chặn bởi Debounce');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      // DR-021: Lấy GPS (có tự động fallback lấy Cache nếu không có quyền)
      final gpsService = _ref.read(gpsServiceProvider);
      final location = await gpsService.getCurrentLocation();

      if (location == null) {
        throw Exception('Không thể lấy tọa độ hiện tại hoặc tọa độ từ Cache.');
      }

      // DR-017: Tính điểm ưu tiên (Priority Score)
      final priority = SosPriorityCalculator.calculate(
        household: household,
        isWaterAtRoof: isWaterAtRoof,
        isInjured: isInjured,
      );

      // Kiểm tra trạng thái mạng
      final isOnline = _ref.read(isOnlineProvider);

      // Khởi tạo model cứu hộ
      final sosRequest = SosRequestEntity(
        id: const Uuid().v4(),
        householdId: household.id,
        latitude: location.latitude,
        longitude: location.longitude,
        createdAt: now,
        status: SosStatus.pending,
        priorityScore: priority,
        isOffline: !isOnline,
      );

      final repo = _ref.read(sosRepositoryProvider);
      await repo.sendSosRequest(sosRequest);

      state = state.copyWith(
        isLoading: false,
        lastSentTime: now,
        successMessage: isOnline 
            ? 'Đã gửi tín hiệu SOS khẩn cấp thành công!' 
            : 'Đã lưu SOS vào hàng đợi. Sẽ gửi tự động khi có mạng!',
      );

    } catch (e, stack) {
      AppLogger.e('Gửi SOS thất bại', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Đã có lỗi xảy ra: ${e.toString()}',
      );
    }
  }
}

final sosControllerProvider = StateNotifierProvider<SosController, SosState>((ref) {
  return SosController(ref);
});
