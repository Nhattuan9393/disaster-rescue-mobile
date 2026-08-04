/// Model leo thang — FR-13.1 (quyết định 2.5).
/// EscalationEvidence: hệ thống tự sinh, admin không sửa được.

enum EscalationRequestType {
  manpower('Nhân lực'),
  supplies('Vật tư'),
  medical('Y tế'),
  other('Khác');

  final String label;
  const EscalationRequestType(this.label);
}

enum EscalationStatus {
  draft('Nháp'),
  sent('Đã gửi'),
  acknowledged('Đã tiếp nhận'),
  resolved('Đã xử lý');

  final String label;
  const EscalationStatus(this.label);
}

/// Bằng chứng leo thang — hệ thống tự tính, admin KHÔNG sửa được.
class EscalationEvidence {
  final int redSosUnassigned;
  final Duration longestWait;
  final int householdsMissing;
  final int teamsAvailable;
  final int teamsTotal;
  final int itemsBelowThreshold;
  final int evacuationSlotsFree;
  final DateTime computedAt;

  const EscalationEvidence({
    required this.redSosUnassigned,
    required this.longestWait,
    required this.householdsMissing,
    required this.teamsAvailable,
    required this.teamsTotal,
    required this.itemsBelowThreshold,
    required this.evacuationSlotsFree,
    required this.computedAt,
  });
}

/// Yêu cầu leo thang gửi lên huyện
class EscalationRequest {
  final String id;
  final EscalationRequestType type;
  final Map<String, int> specificNeeds; // VD: {"Người": 20, "Xuồng máy": 3}
  final String description;
  final EscalationEvidence evidence;
  final EscalationStatus status;
  final DateTime createdAt;
  final String? imageUrl;

  const EscalationRequest({
    required this.id,
    required this.type,
    required this.specificNeeds,
    required this.description,
    required this.evidence,
    required this.status,
    required this.createdAt,
    this.imageUrl,
  });
}

/// Sự kiện trong nhật ký (Tab Nhật ký)
enum EventLogType {
  sos('SOS'),
  evacuation('Sơ tán'),
  relief('Cứu trợ'),
  escalation('Leo thang');

  final String label;
  const EventLogType(this.label);
}

class EventLogEntry {
  final String id;
  final EventLogType type;
  final String title;
  final String? detail;
  final DateTime timestamp;

  const EventLogEntry({
    required this.id,
    required this.type,
    required this.title,
    this.detail,
    required this.timestamp,
  });
}
