class EventLogModel {
  final String id;
  final String sosId;
  final String action; // 'create', 'assign', 'accept', 'complete'
  final String message; // Nội dung mô tả sự kiện bằng tiếng Việt
  final String actorId; // ID người thực hiện (Chủ hộ, Admin, Đội trưởng cứu hộ)
  final DateTime timestamp;

  const EventLogModel({
    required this.id,
    required this.sosId,
    required this.action,
    required this.message,
    required this.actorId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sosId': sosId,
      'action': action,
      'message': message,
      'actorId': actorId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EventLogModel.fromJson(Map<String, dynamic> json) {
    return EventLogModel(
      id: json['id'] as String,
      sosId: json['sosId'] as String,
      action: json['action'] as String,
      message: json['message'] as String,
      actorId: json['actorId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
