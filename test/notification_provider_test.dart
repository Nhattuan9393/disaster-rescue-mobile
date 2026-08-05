import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/notification/providers/notification_provider.dart';

void main() {
  group('NotificationNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state loads mock data and has unread messages', () {
      final state = container.read(notificationProvider);
      final notifier = container.read(notificationProvider.notifier);
      
      expect(state.isLoading, isFalse);
      expect(state.notifications.isNotEmpty, isTrue);
      expect(notifier.unreadCount, equals(2)); // Mock data có 2 tin chưa đọc
    });

    test('markAsRead updates the correct notification', () {
      final notifier = container.read(notificationProvider.notifier);
      
      // Giả sử tin id 1 ban đầu chưa đọc
      notifier.markAsRead('1');
      
      final state = container.read(notificationProvider);
      final item = state.notifications.firstWhere((n) => n.id == '1');
      
      expect(item.isRead, isTrue);
      expect(notifier.unreadCount, equals(1)); // Giảm đi 1
    });

    test('markAllAsRead sets all to read', () {
      final notifier = container.read(notificationProvider.notifier);
      
      notifier.markAllAsRead();
      
      final state = container.read(notificationProvider);
      final allRead = state.notifications.every((n) => n.isRead);
      
      expect(allRead, isTrue);
      expect(notifier.unreadCount, equals(0));
    });
  });
}
