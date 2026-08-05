import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';

class SafetyStatusNotifier extends StateNotifier<SafetyStatus> {
  final Ref _ref;

  SafetyStatusNotifier(this._ref)
      : super(SafetyStatus(
          status: SafetyState.safe,
          source: SafetySource.selfApp,
          confidence: 90,
          verifiedAt: DateTime.now(),
        ));

  Future<void> markAsSafe() async {
    // Cập nhật trạng thái an toàn nội bộ ngay lập tức (optimistic UI)
    state = SafetyStatus(
      status: SafetyState.safe,
      source: SafetySource.selfApp,
      confidence: 90,
      verifiedAt: DateTime.now(),
      note: 'Hộ tự xác nhận qua app',
    );

    // Gửi yêu cầu qua hàng đợi offline
    final payload = {
      'status': SafetyState.safe.name,
      'source': SafetySource.selfApp.name,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _ref.read(offlineQueueProvider.notifier).addRequest('safety_status', payload);
  }
}

final safetyStatusProvider =
    StateNotifierProvider<SafetyStatusNotifier, SafetyStatus>((ref) {
  return SafetyStatusNotifier(ref);
});
