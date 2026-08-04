import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';

class EvacuationRequestState {
  final Set<String> selectedAssistanceTypes;
  final int memberCount;
  final String timeframe;
  final String note;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEmergencyWarning; // Cảnh báo khi phát hiện từ khoá SOS

  EvacuationRequestState({
    this.selectedAssistanceTypes = const {},
    this.memberCount = 1,
    this.timeframe = 'trong 3 giờ',
    this.note = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isEmergencyWarning = false,
  });

  EvacuationRequestState copyWith({
    Set<String>? selectedAssistanceTypes,
    int? memberCount,
    String? timeframe,
    String? note,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEmergencyWarning,
  }) {
    return EvacuationRequestState(
      selectedAssistanceTypes: selectedAssistanceTypes ?? this.selectedAssistanceTypes,
      memberCount: memberCount ?? this.memberCount,
      timeframe: timeframe ?? this.timeframe,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEmergencyWarning: isEmergencyWarning ?? this.isEmergencyWarning,
    );
  }
}

class EvacuationRequestNotifier extends StateNotifier<EvacuationRequestState> {
  final Ref _ref;

  EvacuationRequestNotifier(this._ref) : super(EvacuationRequestState());

  void toggleAssistanceType(String type) {
    final newTypes = Set<String>.from(state.selectedAssistanceTypes);
    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }
    state = state.copyWith(selectedAssistanceTypes: newTypes, errorMessage: null);
  }

  void updateMemberCount(int count) {
    if (count >= 1) {
      state = state.copyWith(memberCount: count, errorMessage: null);
    }
  }

  void updateTimeframe(String timeframe) {
    state = state.copyWith(timeframe: timeframe, errorMessage: null);
  }

  void updateNote(String note) {
    final lowerNote = note.toLowerCase();
    // Phân tích từ khoá cảnh báo khẩn cấp
    final isWarning = lowerNote.contains('sắp chìm') ||
        lowerNote.contains('cứu') ||
        lowerNote.contains('ngập lụt') ||
        lowerNote.contains('đang trôi') ||
        lowerNote.contains('chết') ||
        lowerNote.contains('máu');

    state = state.copyWith(
      note: note,
      isEmergencyWarning: isWarning,
      errorMessage: null,
    );
  }

  Future<bool> submitRequest() async {
    if (state.selectedAssistanceTypes.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ít nhất 1 loại hỗ trợ.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final payload = {
        'id': DateTime.now().microsecondsSinceEpoch.toString(), // Mock UUID
        'householdId': 'mock_household_01',
        'assistanceTypes': state.selectedAssistanceTypes.toList(),
        'memberCount': state.memberCount,
        'timeframe': state.timeframe,
        'note': state.note,
        'status': 'pending',
        'latitude': 21.0285, // Mock GPS
        'longitude': 105.8542,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _ref.read(offlineQueueProvider.notifier).addRequest('evacuation', payload);
      
      // Thành công thì không cần reset state ngay, vì màn hình sẽ đóng lại.
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Có lỗi xảy ra khi lưu yêu cầu.',
      );
      return false;
    }
  }
}

final evacuationRequestProvider =
    StateNotifierProvider.autoDispose<EvacuationRequestNotifier, EvacuationRequestState>((ref) {
  return EvacuationRequestNotifier(ref);
});
