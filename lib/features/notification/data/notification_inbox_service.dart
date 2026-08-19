import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/providers/auth_controller.dart';
import '../domain/app_notification.dart';
import 'push_notification_service.dart';

/// Ghi / đọc `notifications` collection để đồng bộ thông báo cross-device
/// mà không cần Cloud Function. Khi có sự kiện quan trọng (SOS mới, gán đội,
/// lệnh sơ tán…) repository ghi 1 doc; các máy khác watch bằng query topic-based
/// và hiện local notification.
class NotificationInboxRepository {
  final FirebaseFirestore _firestore;
  NotificationInboxRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('notifications');

  Future<void> push({
    required AppNotificationKind kind,
    required String title,
    required String body,
    required List<String> recipientTopics,
    String? actionRoute,
    Map<String, dynamic> data = const {},
    String? createdBy,
  }) async {
    if (recipientTopics.isEmpty) return;
    final doc = _col.doc();
    await doc.set({
      'kind': kind.name,
      'title': title,
      'body': body,
      'recipientTopics': recipientTopics,
      'actionRoute': actionRoute,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'readByAll': false,
    });
  }

  Stream<List<AppNotification>> watchForTopics(List<String> topics) {
    if (topics.isEmpty) return Stream.value(const []);
    // Firestore arrayContainsAny giới hạn 10 phần tử — đủ cho các topic của
    // 1 user.
    final safe = topics.take(10).toList();
    return _col
        .where('recipientTopics', arrayContainsAny: safe)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        final v = data['createdAt'];
        if (v is Timestamp) data['createdAt'] = v.toDate().toIso8601String();
        return AppNotification.fromJson(data);
      }).toList();
    });
  }
}

final notificationInboxRepositoryProvider =
    Provider<NotificationInboxRepository>((ref) {
  return NotificationInboxRepository();
});

/// Xem inbox của user hiện tại — dùng cho notifications_screen + toast.
final myNotificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  final topics = _topicsFor(user);
  final repo = ref.watch(notificationInboxRepositoryProvider);
  return repo.watchForTopics(topics);
});

List<String> _topicsFor(UserModel user) {
  final topics = <String>[];
  final commune = user.communeId ?? 'commune_binh_lieu';
  final sector = user.sectorId ?? 'sector_pac_lieng';
  switch (user.role) {
    case UserRole.admin:
      topics.add('role_admin_$commune');
      break;
    case UserRole.rescueTeam:
      if (user.teamId != null) topics.add('team_${user.teamId}');
      topics.add('sector_$sector');
      break;
    case UserRole.household:
      if (user.householdId != null) topics.add('household_${user.householdId}');
      topics.add('sector_$sector');
      break;
    case UserRole.public:
      break;
  }
  return topics;
}

/// Watch inbox và hiện local toast cho mỗi thông báo mới. Được kích hoạt
/// trong Widget cấp cao (RootShell) hoặc từ push_notification_service.
final inboxToastProvider = Provider<InboxToastListener>((ref) {
  return InboxToastListener(ref);
});

class InboxToastListener {
  final Ref _ref;
  DateTime? _lastSeen;
  ProviderSubscription<AsyncValue<List<AppNotification>>>? _sub;

  InboxToastListener(this._ref);

  void start() {
    _sub?.close();
    _sub = _ref.listen<AsyncValue<List<AppNotification>>>(
      myNotificationsStreamProvider,
      (previous, next) {
        next.whenData((list) {
          if (list.isEmpty) return;
          final latest = list.first;
          _lastSeen ??= DateTime.now().subtract(const Duration(seconds: 5));
          if (latest.createdAt.isBefore(_lastSeen!)) return;
          _lastSeen = latest.createdAt;
          _showToast(latest);
        });
      },
      fireImmediately: true,
    );
  }

  void _showToast(AppNotification n) {
    try {
      _ref.read(pushNotificationServiceProvider).showLocal(
            title: n.title,
            body: n.body,
          );
    } catch (e) {
      AppLogger.w('Không hiện được local toast', error: e);
    }
  }

  void dispose() => _sub?.close();
}
