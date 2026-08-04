// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SafetyStatusImpl _$$SafetyStatusImplFromJson(Map<String, dynamic> json) =>
    _$SafetyStatusImpl(
      status: $enumDecode(_$SafetyStateEnumMap, json['status']),
      source: $enumDecode(_$SafetySourceEnumMap, json['source']),
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: DateTime.parse(json['verifiedAt'] as String),
      confidence: (json['confidence'] as num).toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$SafetyStatusImplToJson(_$SafetyStatusImpl instance) =>
    <String, dynamic>{
      'status': _$SafetyStateEnumMap[instance.status]!,
      'source': _$SafetySourceEnumMap[instance.source]!,
      'verifiedBy': instance.verifiedBy,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
      'confidence': instance.confidence,
      'note': instance.note,
    };

const _$SafetyStateEnumMap = {
  SafetyState.safe: 'safe',
  SafetyState.sos: 'sos',
  SafetyState.missingContact: 'missingContact',
  SafetyState.rescued: 'rescued',
  SafetyState.evacuated: 'evacuated',
};

const _$SafetySourceEnumMap = {
  SafetySource.rescueTeam: 'rescueTeam',
  SafetySource.evacuationCheckin: 'evacuationCheckin',
  SafetySource.selfApp: 'selfApp',
  SafetySource.adminManual: 'adminManual',
  SafetySource.neighborReport: 'neighborReport',
};
