class EvacuationOrderModel {
  final String id;
  final List<String> targetVillages;
  final String targetPointId;
  final String targetPointName;
  final String contentVi;
  final String contentTay;
  final String senderId;

  /// Danh sách sectorId đích — dùng để push đúng topic.
  final List<String> targetSectorIds;

  final DateTime timestamp;

  const EvacuationOrderModel({
    required this.id,
    required this.targetVillages,
    required this.targetPointId,
    required this.targetPointName,
    required this.contentVi,
    required this.contentTay,
    required this.senderId,
    this.targetSectorIds = const [],
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetVillages': targetVillages,
      'targetPointId': targetPointId,
      'targetPointName': targetPointName,
      'contentVi': contentVi,
      'contentTay': contentTay,
      'senderId': senderId,
      'targetSectorIds': targetSectorIds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EvacuationOrderModel.fromJson(Map<String, dynamic> json) {
    return EvacuationOrderModel(
      id: json['id'] as String? ?? '',
      targetVillages: (json['targetVillages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      targetPointId: json['targetPointId'] as String? ?? '',
      targetPointName: json['targetPointName'] as String? ?? '',
      contentVi: json['contentVi'] as String? ?? '',
      contentTay: json['contentTay'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      targetSectorIds: (json['targetSectorIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
