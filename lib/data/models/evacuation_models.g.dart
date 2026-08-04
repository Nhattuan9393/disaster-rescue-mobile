// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evacuation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EvacuationPointImpl _$$EvacuationPointImplFromJson(
  Map<String, dynamic> json,
) => _$EvacuationPointImpl(
  id: json['id'] as String,
  communeId: json['communeId'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  currentOccupancy: (json['currentOccupancy'] as num).toInt(),
  status: $enumDecode(_$EvacuationPointStatusEnumMap, json['status']),
  supplies: (json['supplies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
  managerName: json['managerName'] as String,
  managerPhone: json['managerPhone'] as String,
  isPubliclyVisible: json['isPubliclyVisible'] as bool,
);

Map<String, dynamic> _$$EvacuationPointImplToJson(
  _$EvacuationPointImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'communeId': instance.communeId,
  'name': instance.name,
  'address': instance.address,
  'maxCapacity': instance.maxCapacity,
  'currentOccupancy': instance.currentOccupancy,
  'status': _$EvacuationPointStatusEnumMap[instance.status]!,
  'supplies': instance.supplies,
  'notes': instance.notes,
  'managerName': instance.managerName,
  'managerPhone': instance.managerPhone,
  'isPubliclyVisible': instance.isPubliclyVisible,
};

const _$EvacuationPointStatusEnumMap = {
  EvacuationPointStatus.open: 'open',
  EvacuationPointStatus.full: 'full',
  EvacuationPointStatus.damaged: 'damaged',
  EvacuationPointStatus.closed: 'closed',
};

_$EvacuationOrderImpl _$$EvacuationOrderImplFromJson(
  Map<String, dynamic> json,
) => _$EvacuationOrderImpl(
  id: json['id'] as String,
  communeId: json['communeId'] as String,
  targetSectorIds: (json['targetSectorIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetEvacuationPointId: json['targetEvacuationPointId'] as String,
  messageVi: json['messageVi'] as String,
  messageTay: json['messageTay'] as String?,
  targetHouseholdCount: (json['targetHouseholdCount'] as num).toInt(),
  confirmedCount: (json['confirmedCount'] as num).toInt(),
  unableCount: (json['unableCount'] as num).toInt(),
  status: $enumDecode(_$EvacuationOrderStatusEnumMap, json['status']),
  issuedBy: json['issuedBy'] as String,
  issuedAt: DateTime.parse(json['issuedAt'] as String),
);

Map<String, dynamic> _$$EvacuationOrderImplToJson(
  _$EvacuationOrderImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'communeId': instance.communeId,
  'targetSectorIds': instance.targetSectorIds,
  'targetEvacuationPointId': instance.targetEvacuationPointId,
  'messageVi': instance.messageVi,
  'messageTay': instance.messageTay,
  'targetHouseholdCount': instance.targetHouseholdCount,
  'confirmedCount': instance.confirmedCount,
  'unableCount': instance.unableCount,
  'status': _$EvacuationOrderStatusEnumMap[instance.status]!,
  'issuedBy': instance.issuedBy,
  'issuedAt': instance.issuedAt.toIso8601String(),
};

const _$EvacuationOrderStatusEnumMap = {
  EvacuationOrderStatus.draft: 'draft',
  EvacuationOrderStatus.issued: 'issued',
  EvacuationOrderStatus.inProgress: 'inProgress',
  EvacuationOrderStatus.completed: 'completed',
};

_$EvacuationCheckinImpl _$$EvacuationCheckinImplFromJson(
  Map<String, dynamic> json,
) => _$EvacuationCheckinImpl(
  id: json['id'] as String,
  householdId: json['householdId'] as String,
  householdHeadName: json['householdHeadName'] as String,
  sectorName: json['sectorName'] as String,
  presentCount: (json['presentCount'] as num).toInt(),
  totalMembers: (json['totalMembers'] as num).toInt(),
  checkInTime: DateTime.parse(json['checkInTime'] as String),
);

Map<String, dynamic> _$$EvacuationCheckinImplToJson(
  _$EvacuationCheckinImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'householdId': instance.householdId,
  'householdHeadName': instance.householdHeadName,
  'sectorName': instance.sectorName,
  'presentCount': instance.presentCount,
  'totalMembers': instance.totalMembers,
  'checkInTime': instance.checkInTime.toIso8601String(),
};
