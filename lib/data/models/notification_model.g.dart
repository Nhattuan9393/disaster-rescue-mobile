// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TargetLocationImpl _$$TargetLocationImplFromJson(Map<String, dynamic> json) =>
    _$TargetLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );

Map<String, dynamic> _$$TargetLocationImplToJson(
  _$TargetLocationImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
};

_$ShelterInfoImpl _$$ShelterInfoImplFromJson(Map<String, dynamic> json) =>
    _$ShelterInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      currentOccupancy: (json['currentOccupancy'] as num).toInt(),
      availableSupplies: (json['availableSupplies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ShelterInfoImplToJson(_$ShelterInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
      'currentOccupancy': instance.currentOccupancy,
      'availableSupplies': instance.availableSupplies,
    };

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  bodyTay: json['bodyTay'] as String?,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
  targetLocation: json['targetLocation'] == null
      ? null
      : TargetLocation.fromJson(json['targetLocation'] as Map<String, dynamic>),
  shelterInfo: json['shelterInfo'] == null
      ? null
      : ShelterInfo.fromJson(json['shelterInfo'] as Map<String, dynamic>),
  requiredItems: (json['requiredItems'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'bodyTay': instance.bodyTay,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'isRead': instance.isRead,
  'targetLocation': instance.targetLocation,
  'shelterInfo': instance.shelterInfo,
  'requiredItems': instance.requiredItems,
};

const _$NotificationTypeEnumMap = {
  NotificationType.weatherAlert: 'weatherAlert',
  NotificationType.evacuationOrder: 'evacuationOrder',
  NotificationType.mySosStatus: 'mySosStatus',
  NotificationType.reliefDistribution: 'reliefDistribution',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.urgent: 'urgent',
  NotificationPriority.warning: 'warning',
  NotificationPriority.info: 'info',
};
