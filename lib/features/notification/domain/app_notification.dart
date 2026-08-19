enum AppNotificationKind {
  sosCreated,
  sosAssigned,
  sosInProgress,
  sosCompleted,
  evacuationOrder,
  safetyRequest,
  reliefIncoming,
  other,
}

AppNotificationKind kindFromString(String? s) {
  if (s == null) return AppNotificationKind.other;
  try {
    return AppNotificationKind.values.byName(s);
  } catch (_) {
    return AppNotificationKind.other;
  }
}

/// Thông báo cross-device trong `notifications/{id}`. Mỗi máy watch bằng
/// query `where('recipientTopics', arrayContainsAny: myTopics)` để nhận đúng.
class AppNotification {
  final String id;
  final AppNotificationKind kind;
  final String title;
  final String body;

  /// Danh sách topic được nhận thông báo này — VD `['role_admin_commune_binh_lieu']`
  /// hoặc `['team_team_abc']` hoặc `['household_h1', 'sector_sector_pac_lieng']`.
  final List<String> recipientTopics;

  /// Route để deep-link khi bấm — VD `/rescue-sos-detail?sosId=xxx`.
  final String? actionRoute;

  /// Payload thô gắn kèm (VD sosId, orderId).
  final Map<String, dynamic> data;

  final DateTime createdAt;
  final String? createdBy;
  final bool readByAll;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.recipientTopics,
    this.actionRoute,
    this.data = const {},
    required this.createdAt,
    this.createdBy,
    this.readByAll = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'recipientTopics': recipientTopics,
        'actionRoute': actionRoute,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'readByAll': readByAll,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      kind: kindFromString(json['kind'] as String?),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      recipientTopics:
          List<String>.from(json['recipientTopics'] as List? ?? const []),
      actionRoute: json['actionRoute'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      createdBy: json['createdBy'] as String?,
      readByAll: json['readByAll'] as bool? ?? false,
    );
  }
}
