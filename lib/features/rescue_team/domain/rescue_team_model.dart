import 'rescue_team_status.dart';

class RescueTeamModel {
  final String id;
  final String name;
  final String leaderName;
  final String contactPhone;
  final RescueTeamStatus status;
  final double currentLatitude;
  final double currentLongitude;
  final String? assignedSosId; // SOS ID đang được phân công (nếu đang làm nhiệm vụ)

  const RescueTeamModel({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.contactPhone,
    required this.status,
    required this.currentLatitude,
    required this.currentLongitude,
    this.assignedSosId,
  });

  RescueTeamModel copyWith({
    String? id,
    String? name,
    String? leaderName,
    String? contactPhone,
    RescueTeamStatus? status,
    double? currentLatitude,
    double? currentLongitude,
    String? assignedSosId,
  }) {
    return RescueTeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      leaderName: leaderName ?? this.leaderName,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      assignedSosId: assignedSosId ?? this.assignedSosId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'leaderName': leaderName,
      'contactPhone': contactPhone,
      'status': status.name,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'assignedSosId': assignedSosId,
    };
  }

  factory RescueTeamModel.fromJson(Map<String, dynamic> json) {
    return RescueTeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      leaderName: json['leaderName'] as String,
      contactPhone: json['contactPhone'] as String,
      status: RescueTeamStatus.values.byName(json['status'] as String),
      currentLatitude: (json['currentLatitude'] as num).toDouble(),
      currentLongitude: (json['currentLongitude'] as num).toDouble(),
      assignedSosId: json['assignedSosId'] as String?,
    );
  }
}
