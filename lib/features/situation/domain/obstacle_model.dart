class ObstacleModel {
  final String id;
  final String reporterId;
  final double latitude;
  final double longitude;
  final String title;
  final String obstacleType; // 'landslide', 'bridge_collapsed', 'deep_flooding', 'tree_down'
  final String description;
  final String locationName;
  final DateTime timestamp;

  const ObstacleModel({
    required this.id,
    required this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.obstacleType,
    required this.description,
    required this.locationName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'obstacleType': obstacleType,
      'description': description,
      'locationName': locationName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ObstacleModel.fromJson(Map<String, dynamic> json) {
    return ObstacleModel(
      id: json['id'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? '',
      obstacleType: json['obstacleType'] as String? ?? 'landslide',
      description: json['description'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
