import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType { weatherAlert, evacuationOrder, mySosStatus, reliefDistribution }

enum NotificationPriority { urgent, warning, info }

@freezed
class TargetLocation with _$TargetLocation {
  const factory TargetLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) = _TargetLocation;

  factory TargetLocation.fromJson(Map<String, dynamic> json) => _$TargetLocationFromJson(json);
}

@freezed
class ShelterInfo with _$ShelterInfo {
  const factory ShelterInfo({
    required String id,
    required String name,
    required int capacity,
    required int currentOccupancy,
    required List<String> availableSupplies,
  }) = _ShelterInfo;

  factory ShelterInfo.fromJson(Map<String, dynamic> json) => _$ShelterInfoFromJson(json);
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String body,
    String? bodyTay, // Nội dung tiếng Tày (FR-15.2)
    required NotificationType type,
    required NotificationPriority priority,
    required DateTime createdAt,
    @Default(false) bool isRead,
    TargetLocation? targetLocation,
    ShelterInfo? shelterInfo,
    List<String>? requiredItems,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
}
