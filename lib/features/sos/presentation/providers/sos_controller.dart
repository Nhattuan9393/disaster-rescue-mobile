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
    if (state.isLoading) {
      AppLogger.w('Đang trong quá trình gửi SOS, bỏ qua yêu cầu trùng lặp');
      return;
    }

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

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      lastSentTime: now, // Set early to prevent spamming Geolocator package
    );

    try {
      double lat = household.latitude;
      double lng = household.longitude;
      bool isFallback = false;

      // DR-021: Lấy GPS (có tự động fallback lấy Cache nếu không có quyền), giới hạn 1.5s tránh thời gian chết
      final gpsService = _ref.read(gpsServiceProvider);
      final location = await gpsService.getCurrentLocation().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          AppLogger.w('Quá thời gian 1.5s lấy GPS, chuyển sang tọa độ dự phòng');
          return null;
        },
      );

      if (location != null) {
        lat = location.latitude;
        lng = location.longitude;
      } else {
        isFallback = true;
        AppLogger.w('Không lấy được GPS trực tiếp, sử dụng tọa độ nhà đăng ký làm phương án dự phòng');
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
        latitude: lat,
        longitude: lng,
        createdAt: now,
        status: SosStatus.pending,
        priorityScore: priority,
        isOffline: !isOnline,
      );

      final repo = _ref.read(sosRepositoryProvider);
      await repo.sendSosRequest(sosRequest);

      String msg = '';
      if (isFallback) {
        msg = 'Gửi SOS thành công với vị trí nhà đăng ký (Do chưa định vị được thiết bị)!';
      } else {
        msg = isOnline 
            ? 'Đã gửi tín hiệu SOS khẩn cấp thành công!' 
            : 'Đã lưu SOS vào hàng đợi. Sẽ gửi tự động khi có mạng!';
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: msg,
      );

    } catch (e, stack) {
      AppLogger.e('Gửi SOS thất bại', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final sosControllerProvider = StateNotifierProvider<SosController, SosState>((ref) {
  return SosController(ref);
});
