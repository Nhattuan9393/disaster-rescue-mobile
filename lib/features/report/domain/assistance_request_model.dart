class AssistanceRequestModel {
  final String id;
  final String householdId;
  final String reporterId;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final List<String> neededSupports;
  final int priorityScore;
  final String urgencyWindow; // e.g. "1h", "3h", "tonight"
  final String? targetEvacuationPointId;
  final String status; // e.g. "pending", "verified", "inProgress", "completed"
  final int confidenceScore;
  final DateTime timestamp;

  const AssistanceRequestModel({
    required this.id,
    required this.householdId,
    required this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    required this.neededSupports,
    required this.priorityScore,
    required this.urgencyWindow,
    this.targetEvacuationPointId,
    required this.status,
    required this.confidenceScore,
    required this.timestamp,
  });

  AssistanceRequestModel copyWith({
    String? id,
    String? householdId,
    String? reporterId,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
    List<String>? neededSupports,
    int? priorityScore,
    String? urgencyWindow,
    String? targetEvacuationPointId,
    String? status,
    int? confidenceScore,
    DateTime? timestamp,
  }) {
    return AssistanceRequestModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      reporterId: reporterId ?? this.reporterId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      description: description ?? this.description,
      neededSupports: neededSupports ?? this.neededSupports,
      priorityScore: priorityScore ?? this.priorityScore,
      urgencyWindow: urgencyWindow ?? this.urgencyWindow,
      targetEvacuationPointId: targetEvacuationPointId ?? this.targetEvacuationPointId,
      status: status ?? this.status,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'reporterId': reporterId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'neededSupports': neededSupports,
      'priorityScore': priorityScore,
      'urgencyWindow': urgencyWindow,
      'targetEvacuationPointId': targetEvacuationPointId,
      'status': status,
      'confidenceScore': confidenceScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AssistanceRequestModel.fromJson(Map<String, dynamic> json) {
    return AssistanceRequestModel(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      reporterId: json['reporterId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      neededSupports: List<String>.from(json['neededSupports'] as List? ?? []),
      priorityScore: json['priorityScore'] as int? ?? 0,
      urgencyWindow: json['urgencyWindow'] as String? ?? '3h',
      targetEvacuationPointId: json['targetEvacuationPointId'] as String?,
      status: json['status'] as String? ?? 'pending',
      confidenceScore: json['confidenceScore'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
