import 'rescue_team_status.dart';

enum RescueTeamKind { permanent, volunteer }

/// Metadata "tạm nghỉ" (khi status == onBreak).
class RescueBreakInfo {
  final String reason;
  final DateTime? plannedReturnAt;

  const RescueBreakInfo({required this.reason, this.plannedReturnAt});

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'plannedReturnAt': plannedReturnAt?.toIso8601String(),
      };

  static RescueBreakInfo? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return RescueBreakInfo(
      reason: (json['reason'] as String?) ?? '',
      plannedReturnAt: json['plannedReturnAt'] == null
          ? null
          : DateTime.tryParse(json['plannedReturnAt'] as String),
    );
  }
}

class RescueTeamModel {
  final String id;
  final String name;
  final String leaderName;
  final String contactPhone;
  final RescueTeamStatus status;
  final double currentLatitude;
  final double currentLongitude;
  final String? assignedSosId;

  /// Đội thường trực hay vãng lai (MTQ). Ảnh hưởng bộ lọc gán việc.
  final RescueTeamKind teamType;

  /// Phê duyệt hoạt động tác chiến (đặc biệt cho đội vãng lai)
  final bool isApproved;

  /// Số thành viên và số phương tiện di chuyển
  final int memberCount;
  final int boatCount;

  /// Nhu yếu phẩm/vật tư mang theo của đội
  final Map<String, int> broughtSupplies;

  /// UID chủ tài khoản đội (để rules chặn team khác không sửa được).
  final String? ownerUid;

  final String? communeId;
  final String? sectorId;
  final DateTime? lastHeartbeatAt;
  final RescueBreakInfo? breakInfo;

  const RescueTeamModel({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.contactPhone,
    required this.status,
    required this.currentLatitude,
    required this.currentLongitude,
    this.assignedSosId,
    this.teamType = RescueTeamKind.permanent,
    this.isApproved = true,
    this.memberCount = 5,
    this.boatCount = 1,
    this.broughtSupplies = const {},
    this.ownerUid,
    this.communeId,
    this.sectorId,
    this.lastHeartbeatAt,
    this.breakInfo,
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
    bool clearAssignedSosId = false,
    RescueTeamKind? teamType,
    bool? isApproved,
    int? memberCount,
    int? boatCount,
    Map<String, int>? broughtSupplies,
    String? ownerUid,
    String? communeId,
    String? sectorId,
    DateTime? lastHeartbeatAt,
    RescueBreakInfo? breakInfo,
    bool clearBreakInfo = false,
  }) {
    return RescueTeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      leaderName: leaderName ?? this.leaderName,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      assignedSosId:
          clearAssignedSosId ? null : (assignedSosId ?? this.assignedSosId),
      teamType: teamType ?? this.teamType,
      isApproved: isApproved ?? this.isApproved,
      memberCount: memberCount ?? this.memberCount,
      boatCount: boatCount ?? this.boatCount,
      broughtSupplies: broughtSupplies ?? this.broughtSupplies,
      ownerUid: ownerUid ?? this.ownerUid,
      communeId: communeId ?? this.communeId,
      sectorId: sectorId ?? this.sectorId,
      lastHeartbeatAt: lastHeartbeatAt ?? this.lastHeartbeatAt,
      breakInfo: clearBreakInfo ? null : (breakInfo ?? this.breakInfo),
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
      'teamType': teamType.name,
      'isApproved': isApproved,
      'memberCount': memberCount,
      'boatCount': boatCount,
      'broughtSupplies': broughtSupplies,
      'ownerUid': ownerUid,
      'communeId': communeId,
      'sectorId': sectorId,
      'lastHeartbeatAt': lastHeartbeatAt?.toIso8601String(),
      'breakInfo': breakInfo?.toJson(),
    };
  }

  factory RescueTeamModel.fromJson(Map<String, dynamic> json) {
    return RescueTeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      leaderName: (json['leaderName'] as String?) ?? '',
      contactPhone: (json['contactPhone'] as String?) ?? '',
      status: RescueTeamStatus.values.byName(json['status'] as String),
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble() ?? 0,
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble() ?? 0,
      assignedSosId: json['assignedSosId'] as String?,
      teamType: json['teamType'] == null
          ? RescueTeamKind.permanent
          : RescueTeamKind.values.byName(json['teamType'] as String),
      isApproved: json['isApproved'] as bool? ?? true,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 5,
      boatCount: (json['boatCount'] as num?)?.toInt() ?? 1,
      broughtSupplies: json['broughtSupplies'] == null
          ? const {}
          : Map<String, int>.from(
              (json['broughtSupplies'] as Map).map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ),
            ),
      ownerUid: json['ownerUid'] as String?,
      communeId: json['communeId'] as String?,
      sectorId: json['sectorId'] as String?,
      lastHeartbeatAt: json['lastHeartbeatAt'] == null
          ? null
          : DateTime.tryParse(json['lastHeartbeatAt'] as String),
      breakInfo: RescueBreakInfo.fromJson(
          json['breakInfo'] as Map<String, dynamic>?),
    );
  }
}
