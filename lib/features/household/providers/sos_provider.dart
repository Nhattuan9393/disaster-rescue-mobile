import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class SosState {
  final SosButtonState buttonState;
  final SosContext currentContext;

  SosState({
    required this.buttonState,
    required this.currentContext,
  });

  SosState copyWith({
    SosButtonState? buttonState,
    SosContext? currentContext,
  }) {
    return SosState(
      buttonState: buttonState ?? this.buttonState,
      currentContext: currentContext ?? this.currentContext,
    );
  }
}

class SosNotifier extends StateNotifier<SosState> {
  final Ref _ref;

  SosNotifier(this._ref)
      : super(SosState(
          buttonState: SosButtonState.idle,
          currentContext: const SosContext(
            hasChildren: false,
            hasElderly: false,
            hasSeriouslyIll: false,
            hasDisabled: false,
            groundFloorFlooded: false,
            needsMedicine: false,
            waterLevel: WaterLevel.none,
            houseType: HouseType.multiStory,
            peopleCount: 1,
          ),
        ));

  Future<void> sendSos() async {
    if (state.buttonState != SosButtonState.idle) return;

    state = state.copyWith(buttonState: SosButtonState.sending);

    try {
      // Giả lập việc lấy toạ độ GPS
      await Future.delayed(const Duration(milliseconds: 1000));

      final priorityScore = calculatePriority(state.currentContext);
      final priorityLevel = getPriorityLevel(priorityScore);

      final payload = {
        'lat': 21.0285,
        'lng': 105.8542,
        'priorityScore': priorityScore,
        'priorityLevel': priorityLevel.name,
        'timestamp': DateTime.now().toIso8601String(),
        'context': state.currentContext.toJson(),
      };

      // Thêm vào hàng đợi offline
      await _ref.read(offlineQueueProvider.notifier).addRequest('sos', payload);

      if (mounted) {
        state = state.copyWith(buttonState: SosButtonState.sent);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(buttonState: SosButtonState.idle);
      }
    }
  }

  void resetSos() {
    state = state.copyWith(buttonState: SosButtonState.idle);
  }

  Future<void> updateSosDetails(SosContext context) async {
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

    // Đẩy yêu cầu cập nhật chi tiết SOS vào local queue
    await _ref.read(offlineQueueProvider.notifier).addRequest('sos_update', payload);

    if (mounted) {
      state = state.copyWith(currentContext: context);
    }
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier(ref);
});
