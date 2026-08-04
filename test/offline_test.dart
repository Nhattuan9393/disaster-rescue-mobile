import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:disaster_rescue/core/utils/connection_provider.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';

class ConnectionNotifierMock extends ConnectionNotifier {
  ConnectionNotifierMock(ConnectionStatus initialStatus) : super() {
    state = initialStatus;
  }

  @override
  Future<void> init() async {
    // Không làm gì để tránh gọi connectivity thực tế trong môi trường test
  }
}

void main() {
  late Directory tempDir;
  late Box<OfflineRequest> box;

  setUpAll(() {
    // Tránh lỗi đăng ký Adapter trùng lặp khi chạy toàn bộ test suite
    try {
      Hive.registerAdapter(OfflineRequestAdapter());
    } catch (_) {}
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_offline_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OfflineRequest>('offline_requests');
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('Offline Queue & Connection Provider Unit Tests', () {
    test('OfflineRequest serializes and deserializes correctly via Hive Box', () async {
      final request = OfflineRequest(
        id: 'req-999',
        type: 'sos',
        payload: {'level': 'roof', 'people': 5},
        timestamp: DateTime.now(),
      );

      await box.add(request);
      expect(box.length, 1);

      final retrieved = box.getAt(0);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'req-999');
      expect(retrieved.type, 'sos');
      expect(retrieved.payload['level'], 'roof');
      expect(retrieved.payload['people'], 5);
    });

    test('OfflineQueueNotifier adds requests and filters type counts correctly', () async {
      final container = ProviderContainer(
        overrides: [
          connectionProvider.overrideWith((ref) => ConnectionNotifierMock(ConnectionStatus.offline) as ConnectionNotifier),
        ],
      );

      final notifier = container.read(offlineQueueProvider.notifier);

      // Thêm 2 SOS
      await notifier.addRequest('sos', {'people': 2});
      await notifier.addRequest('sos', {'people': 4});
      // Thêm 1 check-in phát hàng (không phải SOS)
      await notifier.addRequest('relief_delivery', {'item': 'water', 'qty': 10});

      final state = container.read(offlineQueueProvider);
      expect(state.requests.length, 3);
      expect(state.sosCount, 2);
      expect(state.actionCount, 1);
    });

    test('OfflineQueueNotifier syncs and removes items from local queue successfully', () async {
      final container = ProviderContainer(
        overrides: [
          connectionProvider.overrideWith((ref) => ConnectionNotifierMock(ConnectionStatus.offline) as ConnectionNotifier),
        ],
      );

      final notifier = container.read(offlineQueueProvider.notifier);

      // Thêm yêu cầu lúc offline
      await notifier.addRequest('sos', {'people': 2});
      expect(container.read(offlineQueueProvider).requests.length, 1);

      // Chạy tiến trình đồng bộ (đồng bộ sẽ chạy tuần tự gửi lên server ảo và xóa khỏi box)
      await notifier.syncQueue();

      // Sau khi đồng bộ, hàng đợi phải trống rỗng
      expect(container.read(offlineQueueProvider).requests.length, 0);
    });
  });
}
