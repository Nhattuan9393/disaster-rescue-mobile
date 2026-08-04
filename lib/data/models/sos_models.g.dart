// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SosContextImpl _$$SosContextImplFromJson(Map<String, dynamic> json) =>
    _$SosContextImpl(
      hasChildren: json['hasChildren'] as bool,
      hasElderly: json['hasElderly'] as bool,
      hasSeriouslyIll: json['hasSeriouslyIll'] as bool,
      hasDisabled: json['hasDisabled'] as bool,
      groundFloorFlooded: json['groundFloorFlooded'] as bool,
      needsMedicine: json['needsMedicine'] as bool,
      waterLevel: $enumDecode(_$WaterLevelEnumMap, json['waterLevel']),
      houseType: $enumDecode(_$HouseTypeEnumMap, json['houseType']),
      peopleCount: (json['peopleCount'] as num).toInt(),
    );

Map<String, dynamic> _$$SosContextImplToJson(_$SosContextImpl instance) =>
    <String, dynamic>{
      'hasChildren': instance.hasChildren,
      'hasElderly': instance.hasElderly,
      'hasSeriouslyIll': instance.hasSeriouslyIll,
      'hasDisabled': instance.hasDisabled,
      'groundFloorFlooded': instance.groundFloorFlooded,
      'needsMedicine': instance.needsMedicine,
      'waterLevel': _$WaterLevelEnumMap[instance.waterLevel]!,
      'houseType': _$HouseTypeEnumMap[instance.houseType]!,
      'peopleCount': instance.peopleCount,
    };

const _$WaterLevelEnumMap = {
  WaterLevel.none: 'none',
  WaterLevel.knee: 'knee',
  WaterLevel.chest: 'chest',
  WaterLevel.roof: 'roof',
};

const _$HouseTypeEnumMap = {
  HouseType.level4: 'level4',
  HouseType.multiStory: 'multiStory',
};
