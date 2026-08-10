class SituationReportModel {
  final String id;
  final String reporterId;
  final double latitude;
  final double longitude;
  final String address;
  final String incidentType; // e.g. "flood", "landslide", "road_blocked"
  final String description;
  final List<String> photoUrls;
  final DateTime timestamp;

  const SituationReportModel({
    required this.id,
    required this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.incidentType,
    required this.description,
    required this.photoUrls,
    required this.timestamp,
  });

  SituationReportModel copyWith({
    String? id,
    String? reporterId,
    double? latitude,
    double? longitude,
    String? address,
    String? incidentType,
    String? description,
    List<String>? photoUrls,
    DateTime? timestamp,
  }) {
    return SituationReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'incidentType': incidentType,
      'description': description,
      'photoUrls': photoUrls,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SituationReportModel.fromJson(Map<String, dynamic> json) {
    return SituationReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      incidentType: json['incidentType'] as String? ?? 'flood',
      description: json['description'] as String? ?? '',
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
