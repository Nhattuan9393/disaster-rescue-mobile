class HouseholdModel {
  final String id;
  final String ownerUid;
  final String address;
  final double latitude;
  final double longitude;
  final int memberCount;
  final int childrenCount;
  final int elderlyCount;
  final int sickCount;
  final String? headName;
  final String? contactPhone;

  const HouseholdModel({
    required this.id,
    required this.ownerUid,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.memberCount = 1,
    this.childrenCount = 0,
    this.elderlyCount = 0,
    this.sickCount = 0,
    this.headName,
    this.contactPhone,
  });

  HouseholdModel copyWith({
    String? id,
    String? ownerUid,
    String? address,
    double? latitude,
    double? longitude,
    int? memberCount,
    int? childrenCount,
    int? elderlyCount,
    int? sickCount,
    String? headName,
    String? contactPhone,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      memberCount: memberCount ?? this.memberCount,
      childrenCount: childrenCount ?? this.childrenCount,
      elderlyCount: elderlyCount ?? this.elderlyCount,
      sickCount: sickCount ?? this.sickCount,
      headName: headName ?? this.headName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'memberCount': memberCount,
      'childrenCount': childrenCount,
      'elderlyCount': elderlyCount,
      'sickCount': sickCount,
      'headName': headName,
      'contactPhone': contactPhone,
    };
  }

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      ownerUid: json['ownerUid'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      memberCount: json['memberCount'] as int? ?? 1,
      childrenCount: json['childrenCount'] as int? ?? 0,
      elderlyCount: json['elderlyCount'] as int? ?? 0,
      sickCount: json['sickCount'] as int? ?? 0,
      headName: json['headName'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }
}
