class EvacuationOrderModel {
  final String id;
  final List<String> targetVillages;
  final String targetPointId;
  final String targetPointName;
  final String contentVi;
  final String contentTay;
  final String senderId;
  final DateTime timestamp;

  const EvacuationOrderModel({
    required this.id,
    required this.targetVillages,
    required this.targetPointId,
    required this.targetPointName,
    required this.contentVi,
    required this.contentTay,
    required this.senderId,
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
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EvacuationOrderModel.fromJson(Map<String, dynamic> json) {
    return EvacuationOrderModel(
      id: json['id'] as String? ?? '',
      targetVillages: (json['targetVillages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      targetPointId: json['targetPointId'] as String? ?? '',
      targetPointName: json['targetPointName'] as String? ?? '',
      contentVi: json['contentVi'] as String? ?? '',
      contentTay: json['contentTay'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
