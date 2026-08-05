// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseholdModelImpl _$$HouseholdModelImplFromJson(Map<String, dynamic> json) =>
    _$HouseholdModelImpl(
      id: json['id'] as String,
      ownerName: json['ownerName'] as String,
      ownerPhone: json['ownerPhone'] as String,
      address: json['address'] as String,
      peopleCount: (json['peopleCount'] as num).toInt(),
      houseType: $enumDecode(_$HouseTypeEnumMap, json['houseType']),
      hasChildren: json['hasChildren'] as bool? ?? false,
      hasElderly: json['hasElderly'] as bool? ?? false,
      hasSeriouslyIll: json['hasSeriouslyIll'] as bool? ?? false,
      hasDisabled: json['hasDisabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$HouseholdModelImplToJson(
  _$HouseholdModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerName': instance.ownerName,
  'ownerPhone': instance.ownerPhone,
  'address': instance.address,
  'peopleCount': instance.peopleCount,
  'houseType': _$HouseTypeEnumMap[instance.houseType]!,
  'hasChildren': instance.hasChildren,
  'hasElderly': instance.hasElderly,
  'hasSeriouslyIll': instance.hasSeriouslyIll,
  'hasDisabled': instance.hasDisabled,
};

const _$HouseTypeEnumMap = {
  HouseType.level4: 'level4',
  HouseType.multiStory: 'multiStory',
};
