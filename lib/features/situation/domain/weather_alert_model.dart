class WeatherAlertModel {
  final String id;
  final String alertTitle;
  final String alertLevel; // 'Level 1', 'Level 2', 'Level 3'
  final double riverLevelMeters;
  final int rainfallMm;
  final String warningMessage;
  final DateTime issuedAt;

  const WeatherAlertModel({
    required this.id,
    required this.alertTitle,
    required this.alertLevel,
    required this.riverLevelMeters,
    required this.rainfallMm,
    required this.warningMessage,
    required this.issuedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alertTitle': alertTitle,
      'alertLevel': alertLevel,
      'riverLevelMeters': riverLevelMeters,
      'rainfallMm': rainfallMm,
      'warningMessage': warningMessage,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }

  factory WeatherAlertModel.fromJson(Map<String, dynamic> json) {
    return WeatherAlertModel(
      id: json['id'] as String? ?? '',
      alertTitle: json['alertTitle'] as String? ?? '',
      alertLevel: json['alertLevel'] as String? ?? 'Level 3',
      riverLevelMeters: (json['riverLevelMeters'] as num?)?.toDouble() ?? 2.5,
      rainfallMm: json['rainfallMm'] as int? ?? 180,
      warningMessage: json['warningMessage'] as String? ?? '',
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'] as String)
          : DateTime.now(),
    );
  }
}
