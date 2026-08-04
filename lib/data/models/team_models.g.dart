// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RescueTeamImpl _$$RescueTeamImplFromJson(Map<String, dynamic> json) =>
    _$RescueTeamImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      type: $enumDecode(_$TeamTypeEnumMap, json['type']),
      status: $enumDecode(_$TeamStatusEnumMap, json['status']),
      members: (json['members'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      equipment: (json['equipment'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      supplies: (json['supplies'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      qrCode: json['qrCode'] as String,
      restingReason: json['restingReason'] as String?,
      returnTime: json['returnTime'] == null
          ? null
          : DateTime.parse(json['returnTime'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );

Map<String, dynamic> _$$RescueTeamImplToJson(_$RescueTeamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'type': _$TeamTypeEnumMap[instance.type]!,
      'status': _$TeamStatusEnumMap[instance.status]!,
      'members': instance.members,
      'equipment': instance.equipment,
      'supplies': instance.supplies,
      'qrCode': instance.qrCode,
      'restingReason': instance.restingReason,
      'returnTime': instance.returnTime?.toIso8601String(),
      'lastActive': instance.lastActive.toIso8601String(),
    };

const _$TeamTypeEnumMap = {
  TeamType.standing: 'standing',
  TeamType.adhoc: 'adhoc',
};

const _$TeamStatusEnumMap = {
  TeamStatus.available: 'available',
  TeamStatus.onMission: 'onMission',
  TeamStatus.resting: 'resting',
  TeamStatus.offline: 'offline',
  TeamStatus.ended: 'ended',
};
