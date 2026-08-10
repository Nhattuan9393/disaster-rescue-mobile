import 'sos_status.dart';

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
  });

  SosRequestEntity copyWith({
    String? id,
    String? householdId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    SosStatus? status,
    int? priorityScore,
    String? assignedTeamId,
    bool? isOffline,
  }) {
    return SosRequestEntity(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priorityScore: priorityScore ?? this.priorityScore,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      isOffline: isOffline ?? this.isOffline,
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
    );
  }
}
