import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState(isLoading: true)) {
    _loadMockData();
  }

  void _loadMockData() {
    final mockData = [
      NotificationModel(
        id: '1',
        title: 'Cảnh báo Bão YAGI sắp đổ bộ',
        body: 'Dự báo bão YAGI sẽ đổ bộ vào chiều nay. Vui lòng chằng chống nhà cửa và chuẩn bị sơ tán nếu cần.',
        bodyTay: 'Cần cẩn bão YAGI mừa kỉ pây nay. Thấy chằng chống rườn cưa, chẩn bị tọt slim sơ tán.',
        type: NotificationType.weatherAlert,
        priority: NotificationPriority.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'LỆNH SƠ TÁN KHẨN CẤP',
        body: 'Khu vực của bạn có nguy cơ ngập lụt cao. Vui lòng sơ tán đến Nhà Văn Hóa Xã ngay lập tức.',
        bodyTay: 'Cần tọt slim khẩn cấp pây Nhà Văn Hoá Xã.',
        type: NotificationType.evacuationOrder,
        priority: NotificationPriority.urgent,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
        shelterInfo: const ShelterInfo(
          id: 's1',
          name: 'Nhà Văn Hóa Xã',
          capacity: 200,
          currentOccupancy: 45,
          availableSupplies: ['Nước uống', 'Lều bạt'],
        ),
        targetLocation: const TargetLocation(
          latitude: 21.03,
          longitude: 105.86,
          address: 'Nhà Văn Hóa Xã',
        ),
        requiredItems: ['Giấy tờ tùy thân', 'Thuốc men', 'Đèn pin'],
      ),
      NotificationModel(
        id: '3',
        title: 'Trạng thái SOS của bạn',
        body: 'Đội cứu hộ đang trên đường tới vị trí của bạn.',
        type: NotificationType.mySosStatus,
        priority: NotificationPriority.urgent,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Thông báo nhận hàng cứu trợ',
        body: 'Hộ của bạn được phân bổ nhu yếu phẩm. Vui lòng đến Ủy ban xã để nhận.',
        type: NotificationType.reliefDistribution,
        priority: NotificationPriority.info,
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        isRead: true,
      ),
    ];
    state = NotificationState(notifications: mockData, isLoading: false);
  }

  void markAsRead(String id) {
    final updatedList = state.notifications.map((n) {
      if (n.id == id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updatedList);
  }

  void markAllAsRead() {
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedList);
  }

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredList => state.notifications; // Mặc định hiển thị tất cả
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
