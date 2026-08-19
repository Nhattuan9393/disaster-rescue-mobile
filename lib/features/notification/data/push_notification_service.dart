import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/providers/auth_controller.dart';

final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

/// FCM + local notification. Chịu trách nhiệm:
/// - Xin quyền push (iOS/Android 13+).
/// - Nhận `fcmToken` → ghi vào `users/{uid}.fcmToken`.
/// - Subscribe topic theo role/team/household để backend push đúng chỗ:
///     - `role_admin_<communeId>` — cho toàn bộ admin trong xã (nhận SOS mới).
///     - `team_<teamId>` — cho đội cứu hộ (nhận thông báo gán việc).
///     - `household_<householdId>` — cho hộ dân (nhận lệnh sơ tán, cập nhật SOS).
///     - `sector_<sectorId>` — cho cả cụm (lệnh sơ tán vùng).
/// - Hiện toast local khi app đang mở (foreground message không tự bật notification).
class PushNotificationService {
  final Ref _ref;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final FirebaseFirestore _firestore;

  bool _initialized = false;
  ProviderSubscription<AuthState>? _authSub;
  String? _lastSubscribedUid;

  PushNotificationService(
    this._ref, {
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? local,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _local = local ?? FlutterLocalNotificationsPlugin(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      await _initLocalNotifications();

      // Foreground: dùng local notification để hiện banner
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Đăng ký lại subscription mỗi khi user thay đổi (login/logout)
      _authSub = _ref.listen<AuthState>(authControllerProvider,
          (previous, next) => _syncSubscriptions(next.user), fireImmediately: true);
    } catch (e, s) {
      AppLogger.w('PushNotification init lỗi (bỏ qua nếu chưa cấu hình FCM)',
          error: e, stackTrace: s);
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    // Kênh có sound + heads-up cho SOS
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'disaster_rescue_urgent',
            'Cảnh báo khẩn cấp',
            description: 'SOS, lệnh sơ tán, gán nhiệm vụ',
            importance: Importance.high,
            playSound: true,
          ),
        );
  }

  Future<void> _syncSubscriptions(UserModel? user) async {
    if (user == null) {
      if (_lastSubscribedUid != null) {
        await _unsubscribeAllKnownTopics();
        _lastSubscribedUid = null;
      }
      return;
    }
    if (_lastSubscribedUid == user.uid) return;
    _lastSubscribedUid = user.uid;

    try {
      // FCM token → users/{uid}
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});
      });

      // Topics theo role
      final topics = _topicsFor(user);
      for (final t in topics) {
        try {
          await _messaging.subscribeToTopic(t);
        } catch (_) {}
      }
    } catch (e, s) {
      AppLogger.w('PushNotification syncSubscriptions lỗi',
          error: e, stackTrace: s);
    }
  }

  Future<void> _unsubscribeAllKnownTopics() async {
    // Không giữ danh sách chính xác → best-effort: chỉ unsubscribe bộ chung
    for (final t in const ['role_admin_commune_binh_lieu']) {
      try {
        await _messaging.unsubscribeFromTopic(t);
      } catch (_) {}
    }
  }

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

  Future<void> _onForegroundMessage(RemoteMessage msg) async {
    final notif = msg.notification;
    if (notif == null) return;
    await _local.show(
      msg.hashCode,
      notif.title ?? 'DisasterRescue',
      notif.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'disaster_rescue_urgent',
          'Cảnh báo khẩn cấp',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: msg.data.toString(),
    );
  }

  /// Hiện thông báo local ngay lập tức (dùng cho các event mà cùng máy vừa
  /// làm — VD toast xác nhận, hoặc khi chưa có Cloud Function).
  Future<void> showLocal({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'disaster_rescue_urgent',
          'Cảnh báo khẩn cấp',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void dispose() {
    _authSub?.close();
  }
}
