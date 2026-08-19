import 'sos_status.dart';

/// Priority classification derived from `priorityScore` — SRS: ≥70 red, 40–69 orange, <40 yellow.
enum SosPriorityLevel { red, orange, yellow }

SosPriorityLevel sosPriorityLevelFor(int score) {
  if (score >= 70) return SosPriorityLevel.red;
  if (score >= 40) return SosPriorityLevel.orange;
  return SosPriorityLevel.yellow;
}

/// Tín hiệu SOS — nội dung nghiệp vụ ghi thẳng trên `sos_requests/{id}` để
/// đội cứu hộ và admin thấy nhanh. PII của hộ (tên, SĐT, địa chỉ chi tiết) KHÔNG
/// nằm trên doc này — chỉ có `householdId`; các bên có quyền truy vấn
/// `households/{householdId}` để mở khoá thông tin sau khi được gán.
class SosRequestEntity {
  final String id;
  final String householdId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final SosStatus status;
  final int priorityScore;
  final String? assignedTeamId;
  final bool isOffline;

  /// Chip tình huống hiển thị trên card / màn chi tiết
  /// (VD: "5 người", "2 trẻ em", "Cần thuốc", "Nước ngang ngực").
  final List<String> situationChips;

  /// Số thành viên trong hộ vào thời điểm SOS (snapshot).
  final int memberCount;

  /// Mức nước — theo enum SRS: chest / roof / floor / null.
  final String? waterLevel;

  /// Ảnh hiện trường (Firebase Storage URL).
  final List<String> photos;

  final String? note;

  /// Thôn/xã ngắn gọn — không phải địa chỉ nhà chi tiết.
  /// Dùng cho danh sách/admin map.
  final String? sectorLabel;

  /// Tham chiếu tới đợt thiên tai (nếu có).
  final String? disasterEventId;

  const SosRequestEntity({
    required this.id,
    required this.householdId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.status,
    this.priorityScore = 0,
    this.assignedTeamId,
    this.isOffline = false,
    this.situationChips = const [],
    this.memberCount = 0,
    this.waterLevel,
    this.photos = const [],
    this.note,
    this.sectorLabel,
    this.disasterEventId,
  });

  SosPriorityLevel get priorityLevel => sosPriorityLevelFor(priorityScore);

  SosRequestEntity copyWith({
    String? id,
    String? householdId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    SosStatus? status,
    int? priorityScore,
    String? assignedTeamId,
    bool clearAssignedTeamId = false,
    bool? isOffline,
    List<String>? situationChips,
    int? memberCount,
    String? waterLevel,
    List<String>? photos,
    String? note,
    String? sectorLabel,
    String? disasterEventId,
  }) {
    return SosRequestEntity(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priorityScore: priorityScore ?? this.priorityScore,
      assignedTeamId:
          clearAssignedTeamId ? null : (assignedTeamId ?? this.assignedTeamId),
      isOffline: isOffline ?? this.isOffline,
      situationChips: situationChips ?? this.situationChips,
      memberCount: memberCount ?? this.memberCount,
      waterLevel: waterLevel ?? this.waterLevel,
      photos: photos ?? this.photos,
      note: note ?? this.note,
      sectorLabel: sectorLabel ?? this.sectorLabel,
      disasterEventId: disasterEventId ?? this.disasterEventId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'priorityScore': priorityScore,
      'assignedTeamId': assignedTeamId,
      'isOffline': isOffline,
      'situationChips': situationChips,
      'memberCount': memberCount,
      'waterLevel': waterLevel,
      'photos': photos,
      'note': note,
      'sectorLabel': sectorLabel,
      'disasterEventId': disasterEventId,
    };
  }

  factory SosRequestEntity.fromJson(Map<String, dynamic> json) {
    return SosRequestEntity(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: SosStatus.values.byName(json['status'] as String),
      priorityScore: json['priorityScore'] as int? ?? 0,
      assignedTeamId: json['assignedTeamId'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
      situationChips:
          List<String>.from(json['situationChips'] as List? ?? const []),
      memberCount: json['memberCount'] as int? ?? 0,
      waterLevel: json['waterLevel'] as String?,
      photos: List<String>.from(json['photos'] as List? ?? const []),
      note: json['note'] as String?,
      sectorLabel: json['sectorLabel'] as String?,
      disasterEventId: json['disasterEventId'] as String?,
    );
  }
}
