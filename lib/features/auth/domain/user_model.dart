enum UserRole {
  household,
  admin,
  rescueTeam,
  public,
}

class UserModel {
  final String uid;
  final UserRole role;
  final String? phoneNumber;
  final String? displayName;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.role,
    this.phoneNumber,
    this.displayName,
    this.isActive = true,
  });

  UserModel copyWith({
    String? uid,
    UserRole? role,
    String? phoneNumber,
    String? displayName,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role.name,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'isActive': isActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      role: UserRole.values.byName(json['role'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
