import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/logger.dart';
import '../../config/data/emergency_config_repository.dart';
import '../../config/domain/emergency_config.dart';
import '../domain/sos_model.dart';
import 'sms_inbox_repository.dart';

/// Trạng thái từng kênh gửi tín hiệu SOS.
enum SosChannelStatus {
  /// Chưa bắt đầu / không áp dụng cho tình huống hiện tại.
  idle,

  /// Đang thử gửi.
  sending,

  /// Đã gửi/queue thành công ở kênh này.
  delivered,

  /// Đang chờ điều kiện đủ (VD chờ mạng, chờ sóng cellular).
  waiting,

  /// Kênh không khả dụng trên thiết bị / thiếu quyền.
  unavailable,

  /// Đã thử nhưng thất bại — sẽ retry.
  failed,
}

enum SosChannel { firestoreQueue, autoSyncInternet, silentSms, bleBeacon }

class SosDeliverySnapshot {
  final String sosId;
  final Map<SosChannel, SosChannelStatus> channels;
  final DateTime lastUpdated;

  const SosDeliverySnapshot({
    required this.sosId,
    required this.channels,
    required this.lastUpdated,
  });

  SosDeliverySnapshot copyWith({Map<SosChannel, SosChannelStatus>? channels}) {
    return SosDeliverySnapshot(
      sosId: sosId,
      channels: channels ?? this.channels,
      lastUpdated: DateTime.now(),
    );
  }

  /// True nếu ít nhất một kênh đã delivered — coi như tín hiệu đã ra khỏi máy.
  bool get anyDelivered =>
      channels.values.any((s) => s == SosChannelStatus.delivered);
}

/// Điều phối việc bắn cùng một SOS qua nhiều kênh song song.
///
/// Hôm nay: `firestoreQueue` và `autoSyncInternet` là thật; `silentSms` và
/// `bleBeacon` là **stub trung thực** — báo `waiting` / `unavailable` chứ
/// không giả vờ đã gửi. Khi cắm plugin native (`SmsManager` /
/// `flutter_blue_plus advertise`), thay 2 stub tương ứng bằng gọi thật.
class SosDeliveryService extends StateNotifier<SosDeliverySnapshot?> {
  final Ref _ref;
  ProviderSubscription<bool>? _connSub;
  SosRequestEntity? _currentSos;

  SosDeliveryService(this._ref) : super(null);

  /// Cú pháp SMS gọn (< 140 ký tự) — server tổng đài parse cột này.
  static String buildSmsPayload(SosRequestEntity sos) {
    final short = sos.householdId.length > 8
        ? sos.householdId.substring(0, 8)
        : sos.householdId;
    final lat = sos.latitude.toStringAsFixed(4);
    final lng = sos.longitude.toStringAsFixed(4);
    return 'SOS#$short#$lat,$lng#P${sos.priorityScore}#${sos.memberCount}';
  }

  /// Gọi sau khi SOS đã được ghi vào Hive queue.
  ///
  /// [isOnline] là trạng thái mạng tại thời điểm bấm SOS. `firestoreQueue`
  /// coi như delivered vì Hive đã lưu; `autoSyncInternet` là `delivered` nếu
  /// đang online, ngược lại `waiting` — sẽ chuyển sang `delivered` khi mạng
  /// trở lại (đã có [SosSyncService] tự xử).
  void beginDelivery(SosRequestEntity sos, {required bool isOnline}) {
    // Cancel bất kỳ theo dõi cũ nào của SOS trước.
    _connSub?.close();
    _currentSos = sos;

    state = SosDeliverySnapshot(
      sosId: sos.id,
      channels: {
        SosChannel.firestoreQueue: SosChannelStatus.delivered,
        SosChannel.autoSyncInternet:
            isOnline ? SosChannelStatus.delivered : SosChannelStatus.waiting,
        SosChannel.silentSms: SosChannelStatus.sending,
        SosChannel.bleBeacon: SosChannelStatus.unavailable,
      },
      lastUpdated: DateTime.now(),
    );

    // Nghe internet cho auto-sync: khi có mạng, đổi sang delivered.
    _connSub = _ref.listen<bool>(isOnlineProvider, (_, next) {
      if (next && state?.channels[SosChannel.autoSyncInternet] ==
          SosChannelStatus.waiting) {
        _setChannel(SosChannel.autoSyncInternet, SosChannelStatus.delivered);
      }
    }, fireImmediately: false);

    _attemptSilentSms(sos);
    // BLE để pha 2 (user chọn skip). Kênh báo unavailable ngay.
  }

  /// Kênh SMS — hôm nay có 2 nhánh thật:
  ///   * `demoMode=true` (mặc định cho demo): giả lập tổng đài SMS gateway
  ///     bằng cách ghi payload vào Firestore `sms_inbox`. Admin thấy realtime.
  ///   * `demoMode=false` + iOS (hoặc Android chưa cắm MethodChannel):
  ///     báo `unavailable` — user dùng nút "Tự tay gửi SMS" bên dưới để
  ///     mở app tin nhắn qua `url_launcher`.
  ///
  /// Pha tiếp (khi cắm plugin SmsManager Kotlin MethodChannel + xin
  /// runtime `SEND_SMS`): thay nhánh `else` bằng gọi native gửi ngầm,
  /// lắng PendingIntent SENT / DELIVERED để đặt `delivered`.
  Future<void> _attemptSilentSms(SosRequestEntity sos) async {
    final cfgRepo = _ref.read(emergencyConfigRepositoryProvider);
    final inboxRepo = _ref.read(smsInboxRepositoryProvider);
    late EmergencyConfig cfg;
    try {
      cfg = await cfgRepo.get();
    } catch (e) {
      AppLogger.w('Không đọc được EmergencyConfig, dùng fallback: $e');
      cfg = EmergencyConfig.fallback;
    }

    final payload = buildSmsPayload(sos);

    if (cfg.demoMode) {
      try {
        await inboxRepo.pushDemoIncoming(
          sos: sos,
          fromNumber: sos.householdId,
          payload: payload,
        );
        AppLogger.i(
            '[SosDeliveryService] silentSms demo relay → Firestore sms_inbox: $payload');
        _setChannel(SosChannel.silentSms, SosChannelStatus.delivered);
      } catch (e) {
        AppLogger.e('Demo relay ghi sms_inbox thất bại', error: e);
        _setChannel(SosChannel.silentSms, SosChannelStatus.failed);
      }
      return;
    }

    // Production path: chưa có plugin native để gửi ngầm.
    // iOS không cho gửi ngầm bao giờ — degrade sang mở app tin nhắn qua
    // link "Tự tay gửi SMS" trong UI.
    if (Platform.isIOS) {
      AppLogger.i(
          '[SosDeliveryService] silentSms iOS: dùng link "Tự tay gửi SMS" mở Messages');
      _setChannel(SosChannel.silentSms, SosChannelStatus.unavailable);
      return;
    }

    // TODO(silent-sms-android): cắm MethodChannel gọi SmsManager
    //   .sendTextMessage(cfg.hotlinePhone, payload) + xin runtime SEND_SMS,
    //   nghe SENT/DELIVERED PendingIntent để set delivered/failed thật.
    AppLogger.i(
        '[SosDeliveryService] silentSms Android production: chưa cắm SmsManager — báo unavailable');
    _setChannel(SosChannel.silentSms, SosChannelStatus.unavailable);
  }

  void _setChannel(SosChannel c, SosChannelStatus s) {
    final cur = state;
    if (cur == null) return;
    final next = Map<SosChannel, SosChannelStatus>.from(cur.channels);
    next[c] = s;
    state = cur.copyWith(channels: next);
  }

  void clear() {
    _connSub?.close();
    _connSub = null;
    _currentSos = null;
    state = null;
  }

  SosRequestEntity? get currentSos => _currentSos;

  @override
  void dispose() {
    _connSub?.close();
    super.dispose();
  }
}

final sosDeliveryServiceProvider =
    StateNotifierProvider<SosDeliveryService, SosDeliverySnapshot?>((ref) {
  return SosDeliveryService(ref);
});
