enum UserRole {
  household,
  admin,
  rescueTeam,
  public,
}

/// Loại đội cứu hộ khi role == rescueTeam
enum RescueTeamType {
  permanent,
  volunteer,
}

/// Hồ sơ người dùng — được ghi vào Firestore `users/{uid}` khi đăng ký/lần đầu đăng nhập.
/// Là source-of-truth để phân quyền UI (thay cho hardcoded id trước đây như
/// `household_123`, `admin_commune`, `team_01`).
class UserModel {
  final String uid;
  final UserRole role;
  final String displayName;
  final String? phoneNumber;
  final String? email;

  /// Chỉ có khi role == rescueTeam. Trỏ tới `rescue_teams/{teamId}`.
  final String? teamId;
  final RescueTeamType? teamType;

  /// Chỉ có khi role == household. Trỏ tới `households/{householdId}`.
  final String? householdId;

  /// Phạm vi địa lý — dùng để filter SOS theo sector cho admin/đội cứu hộ.
  final String? sectorId;
  final String? communeId;

  /// Device token cho FCM. Cập nhật mỗi lần app khởi động.
  final String? fcmToken;

  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.role,
    required this.displayName,
    this.phoneNumber,
    this.email,
    this.teamId,
    this.teamType,
    this.householdId,
    this.sectorId,
    this.communeId,
    this.fcmToken,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    UserRole? role,
    String? displayName,
    String? phoneNumber,
    String? email,
    String? teamId,
    RescueTeamType? teamType,
    String? householdId,
    String? sectorId,
    String? communeId,
    String? fcmToken,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      teamId: teamId ?? this.teamId,
      teamType: teamType ?? this.teamType,
      householdId: householdId ?? this.householdId,
      sectorId: sectorId ?? this.sectorId,
      communeId: communeId ?? this.communeId,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role.name,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'teamId': teamId,
      'teamType': teamType?.name,
      'householdId': householdId,
      'sectorId': sectorId,
      'communeId': communeId,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      role: UserRole.values.byName(json['role'] as String),
      displayName: (json['displayName'] as String?) ?? 'Người dùng',
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      teamId: json['teamId'] as String?,
      teamType: json['teamType'] == null
          ? null
          : RescueTeamType.values.byName(json['teamType'] as String),
      householdId: json['householdId'] as String?,
      sectorId: json['sectorId'] as String?,
      communeId: json['communeId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    // Firestore Timestamp gets serialized as {seconds:..., nanoseconds:...}
    // Repositories should convert Timestamp → DateTime before calling fromJson.
    return null;
  }
}
