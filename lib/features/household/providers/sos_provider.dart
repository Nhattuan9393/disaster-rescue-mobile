import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class SosNotifier extends StateNotifier<SosButtonState> {
  final Ref _ref;

  SosNotifier(this._ref) : super(SosButtonState.idle);

  Future<void> sendSos() async {
    if (state != SosButtonState.idle) return;

    state = SosButtonState.sending;

    try {
      // Giả lập việc lấy toạ độ GPS
      await Future.delayed(const Duration(milliseconds: 1000));

      // Dữ liệu giả lập profile hộ dân để tính điểm ưu tiên (theo FR-02.3)
      final context = const SosContext(
        hasChildren: true,
        hasElderly: false,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: true,
        needsMedicine: false,
        waterLevel: WaterLevel.chest,
        houseType: HouseType.level4,
        peopleCount: 4,
      );

      final priorityScore = calculatePriority(context);
      final priorityLevel = getPriorityLevel(priorityScore);

      final payload = {
        'lat': 21.0285,
        'lng': 105.8542,
        'priorityScore': priorityScore,
        'priorityLevel': priorityLevel.name,
        'timestamp': DateTime.now().toIso8601String(),
        'context': context.toJson(),
      };

      // Thêm vào hàng đợi offline
      await _ref.read(offlineQueueProvider.notifier).addRequest('sos', payload);

      if (mounted) {
        state = SosButtonState.sent;
        
        // Trở về idle sau 3 giây để người dùng có thể gửi lại nếu cần
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            state = SosButtonState.idle;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        state = SosButtonState.idle;
      }
    }
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosButtonState>((ref) {
  return SosNotifier(ref);
});
