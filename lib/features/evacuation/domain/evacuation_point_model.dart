class EvacuationPointModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int currentCount;
  final String status; // 'open', 'nearly_full', 'full', 'closed'
  final List<String> supplies; // ['chăn', 'nước', 'lương khô', 'thuốc']
  final String inChargeName;
  final String inChargePhone;
  final List<String> checkedInHouseholdIds;

  const EvacuationPointModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.currentCount,
    required this.status,
    required this.supplies,
    required this.inChargeName,
    required this.inChargePhone,
    required this.checkedInHouseholdIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'currentCount': currentCount,
      'status': status,
      'supplies': supplies,
      'inChargeName': inChargeName,
      'inChargePhone': inChargePhone,
      'checkedInHouseholdIds': checkedInHouseholdIds,
    };
  }

  factory EvacuationPointModel.fromJson(Map<String, dynamic> json) {
    return EvacuationPointModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      capacity: json['capacity'] as int? ?? 100,
      currentCount: json['currentCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      supplies: (json['supplies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      inChargeName: json['inChargeName'] as String? ?? '',
      inChargePhone: json['inChargePhone'] as String? ?? '',
      checkedInHouseholdIds: (json['checkedInHouseholdIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  EvacuationPointModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? capacity,
    int? currentCount,
    String? status,
    List<String>? supplies,
    String? inChargeName,
    String? inChargePhone,
    List<String>? checkedInHouseholdIds,
  }) {
    return EvacuationPointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      currentCount: currentCount ?? this.currentCount,
      status: status ?? this.status,
      supplies: supplies ?? this.supplies,
      inChargeName: inChargeName ?? this.inChargeName,
      inChargePhone: inChargePhone ?? this.inChargePhone,
      checkedInHouseholdIds: checkedInHouseholdIds ?? this.checkedInHouseholdIds,
    );
  }
}
