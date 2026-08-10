import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/logger.dart';
import '../domain/i_sos_repository.dart';
import '../domain/sos_model.dart';
import 'sos_repository_impl.dart';

final sosRepositoryProvider = Provider<ISosRepository>((ref) {
  return SosRepositoryImpl();
});

final sosSyncServiceProvider = Provider<SosSyncService>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  final service = SosSyncService(repo, ref);
  service.listenToConnection();
  return service;
});

class SosSyncService {
  final ISosRepository _repository;
  final Ref _ref;
  bool _isSyncing = false;

  SosSyncService(this._repository, this._ref);

  void listenToConnection() {
    // Lắng nghe cờ trạng thái mạng từ Connectivity Service
    _ref.listen<bool>(isOnlineProvider, (previous, isOnline) {
      if (isOnline) {
        AppLogger.i('Mạng hoạt động trở lại! Bắt đầu đồng bộ SOS...');
        syncOfflineQueue();
      }
    });
  }

  Future<void> syncOfflineQueue() async {
    if (_isSyncing) return; // Khóa chống Race Condition (Trùng lặp tiến trình)
    _isSyncing = true;

    try {
      final offlineQueue = await _repository.getOfflineQueue();
      if (offlineQueue.isEmpty) {
        AppLogger.d('Hàng đợi offline rỗng.');
        _isSyncing = false;
        return;
      }

      AppLogger.i('Phát hiện ${offlineQueue.length} tín hiệu SOS đang chờ đồng bộ...');

      for (SosRequestEntity request in offlineQueue) {
        try {
          // Tạo một request mới với cờ isOffline = false để đẩy lên Firestore
          final updatedRequest = request.copyWith(isOffline: false);
          
          // Gửi lên Firestore
          await _repository.sendSosRequest(updatedRequest);
          
          // Xóa khỏi local
          await _repository.removeFromFileQueue(request.id);
        } catch (e) {
          AppLogger.e('Đồng bộ SOS ${request.id} thất bại. Sẽ thử lại sau.', error: e);
          // Vẫn giữ lại trong queue để retry lần sau
        }
      }
    } catch (e, stack) {
      AppLogger.e('Lỗi trong quá trình chạy Sync Service', error: e, stackTrace: stack);
    } finally {
      _isSyncing = false;
    }
  }
}
