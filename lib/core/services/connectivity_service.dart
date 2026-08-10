import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// Lắng nghe trạng thái mạng liên tục
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider kiểm tra nhanh xem thiết bị có internet hay không
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.when(
    data: (results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      AppLogger.d('Trạng thái mạng thay đổi: $results. Online: $isOnline');
      return isOnline;
    },
    loading: () => true, // Mặc định cho qua trong lúc load
    error: (err, stack) {
      AppLogger.e('Lỗi kiểm tra mạng', error: err, stackTrace: stack);
      return false;
    },
  );
});
