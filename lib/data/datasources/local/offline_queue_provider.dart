import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:disaster_rescue/core/utils/connection_provider.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';

/// Trạng thái của Hàng đợi đồng bộ.
class OfflineQueueState {
  final List<OfflineRequest> requests;
  final bool isSyncing;

  const OfflineQueueState({
    required this.requests,
    this.isSyncing = false,
  });

  /// Lọc các yêu cầu SOS khẩn cấp.
  int get sosCount => requests.where((r) => r.type == 'sos').length;

  /// Lọc các thao tác thông thường khác.
  int get actionCount => requests.where((r) => r.type != 'sos').length;
}

/// Notifier quản lý lưu giữ các tác vụ ngoại tuyến vào Hive và xử lý đồng bộ tự động.
class OfflineQueueNotifier extends StateNotifier<OfflineQueueState> {
  final Box<OfflineRequest> _box;
  final Ref _ref;

  OfflineQueueNotifier(this._box, this._ref)
      : super(OfflineQueueState(requests: _box.values.toList())) {
    // Tự động lắng nghe connectionProvider. Khi chuyển sang online, thực hiện đồng bộ ngay.
    _ref.listen<ConnectionStatus>(connectionProvider, (previous, next) {
      if (next == ConnectionStatus.online) {
        syncQueue();
      }
    });
  }

  /// Thêm yêu cầu ghi ngoại tuyến mới vào hàng đợi Hive.
  Future<void> addRequest(String type, Map<String, dynamic> payload) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final request = OfflineRequest(
      id: id,
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );

    await _box.add(request);
    state = OfflineQueueState(
      requests: _box.values.toList(),
      isSyncing: state.isSyncing,
    );

    // Nếu mạng đang online, kích hoạt đồng bộ hóa tức thì
    final connection = _ref.read(connectionProvider);
    if (connection == ConnectionStatus.online) {
      syncQueue();
    }
  }

  /// Xoá yêu cầu khỏi hàng đợi Hive sau khi gửi thành công.
  Future<void> removeRequest(String id) async {
    final key = _box.keys.firstWhere((k) {
      final req = _box.get(k);
      return req?.id == id;
    }, orElse: () => null);

    if (key != null) {
      await _box.delete(key);
      state = OfflineQueueState(
        requests: _box.values.toList(),
        isSyncing: state.isSyncing,
      );
    }
  }

  /// Tiến trình đồng bộ toàn bộ hàng đợi Hive lên máy chủ.
  Future<void> syncQueue() async {
    // Tránh chạy song song hoặc đồng bộ khi hàng đợi trống
    if (state.isSyncing || state.requests.isEmpty) return;

    state = OfflineQueueState(requests: state.requests, isSyncing: true);

    // Clone danh sách để lặp qua
    final List<OfflineRequest> requestsToProcess = List.from(state.requests);

    for (final request in requestsToProcess) {
      try {
        // Giả lập độ trễ gửi mạng 1 giây
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Cứu nạn khẩn cấp: hoàn thành mô phỏng gửi thành công
        await removeRequest(request.id);
      } catch (e) {
        // Tăng số lần thử lại nếu gặp lỗi mạng
        request.retryCount++;
        await request.save();
      }
    }

    state = OfflineQueueState(
      requests: _box.values.toList(),
      isSyncing: false,
    );
  }
}

/// Provider cung cấp trạng thái và quyền thao tác với Hàng đợi Ngoại tuyến.
final offlineQueueProvider =
    StateNotifierProvider<OfflineQueueNotifier, OfflineQueueState>((ref) {
  final box = Hive.box<OfflineRequest>('offline_requests');
  return OfflineQueueNotifier(box, ref);
});
