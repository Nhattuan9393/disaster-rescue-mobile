import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/providers/disaster_state_provider.dart';
import 'package:disaster_rescue/features/household/providers/safety_status_provider.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';

import 'dart:io';

class SafetyReminderNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;
  Duration checkInterval = const Duration(seconds: 5); // Tần suất quét kiểm tra
  Duration safetyThreshold = const Duration(hours: 2); // Ngưỡng cảnh báo (2 giờ)

  SafetyReminderNotifier(this._ref) : super(false) {
    _startTimer();
    _checkReminder();
  }

  void setThresholdForTesting(Duration duration) {
    safetyThreshold = duration;
    _checkReminder();
  }

  void _startTimer() {
    // Không chạy Timer periodic trong môi trường kiểm thử để tránh rò rỉ Timer (leak)
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) => _checkReminder());
  }

  void _checkReminder() {
    final disasterActive = _ref.read(disasterStateProvider);
    final sosState = _ref.read(sosProvider);
    final safetyStatus = _ref.read(safetyStatusProvider);

    // Kích hoạt khi:
    // 1. Thiên tai đang diễn ra
    // 2. Chưa gửi SOS khẩn cấp (SosButtonState == idle)
    // 3. Chưa xác nhận an toàn trong vòng 2 giờ
    final now = DateTime.now();
    final difference = now.difference(safetyStatus.verifiedAt);
    
    final shouldTrigger = disasterActive &&
        sosState.buttonState == SosButtonState.idle &&
        safetyStatus.status != SafetyState.sos &&
        difference >= safetyThreshold;

    if (shouldTrigger != state) {
      state = shouldTrigger;
    }
  }

  void dismissReminder() {
    state = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final safetyReminderProvider = StateNotifierProvider<SafetyReminderNotifier, bool>((ref) {
  return SafetyReminderNotifier(ref);
});
