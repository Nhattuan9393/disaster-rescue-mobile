import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisasterStateNotifier extends StateNotifier<bool> {
  DisasterStateNotifier() : super(true); // Mặc định đang có thiên tai để phục vụ demo/test

  void setDisasterActive(bool active) {
    state = active;
  }
}

final disasterStateProvider = StateNotifierProvider<DisasterStateNotifier, bool>((ref) {
  return DisasterStateNotifier();
});
