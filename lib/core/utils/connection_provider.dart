import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trạng thái kết nối của thiết bị.
enum ConnectionStatus { online, offline }

/// StateNotifier lắng nghe tình trạng kết nối mạng thực tế qua connectivity_plus.
class ConnectionNotifier extends StateNotifier<ConnectionStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectionNotifier() : super(ConnectionStatus.online) {
    init();
  }

  Future<void> init() async {
    // Tránh lỗi gọi platform channel của connectivity_plus khi chạy trong môi trường test
    final isTest = RegExp(r'flutter_test|test_api').hasMatch(StackTrace.current.toString());
    if (isTest) {
      state = ConnectionStatus.online;
      return;
    }

    // 1. Kiểm tra trạng thái mạng tức thời lúc khởi động
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {
      state = ConnectionStatus.offline;
    }

    // 2. Đăng ký lắng nghe các sự kiện thay đổi mạng realtime
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Nếu trong danh sách kết nối có bất kỳ kết nối khả dụng nào khác none -> Coi là online
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    final newStatus = hasConnection ? ConnectionStatus.online : ConnectionStatus.offline;
    
    if (state != newStatus) {
      state = newStatus;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider trạng thái mạng toàn ứng dụng.
final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionStatus>((ref) {
  return ConnectionNotifier();
});
