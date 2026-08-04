// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relief_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReliefItemImpl _$$ReliefItemImplFromJson(Map<String, dynamic> json) =>
    _$ReliefItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$$ReliefItemImplToJson(_$ReliefItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'threshold': instance.threshold,
      'unit': instance.unit,
    };

_$PackageLineImpl _$$PackageLineImplFromJson(Map<String, dynamic> json) =>
    _$PackageLineImpl(
      rawName: json['rawName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      mappedItemId: json['mappedItemId'] as String?,
    );

Map<String, dynamic> _$$PackageLineImplToJson(_$PackageLineImpl instance) =>
    <String, dynamic>{
      'rawName': instance.rawName,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'mappedItemId': instance.mappedItemId,
    };

_$ReliefPackageImpl _$$ReliefPackageImplFromJson(Map<String, dynamic> json) =>
    _$ReliefPackageImpl(
      code: json['code'] as String,
      donorName: json['donorName'] as String,
      donorPhone: json['donorPhone'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      receivedBy: json['receivedBy'] as String,
      status: $enumDecode(_$PackageStatusEnumMap, json['status']),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => PackageLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReliefPackageImplToJson(_$ReliefPackageImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'donorName': instance.donorName,
      'donorPhone': instance.donorPhone,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'receivedBy': instance.receivedBy,
      'status': _$PackageStatusEnumMap[instance.status]!,
      'lines': instance.lines,
    };

const _$PackageStatusEnumMap = {
  PackageStatus.received: 'received',
  PackageStatus.classified: 'classified',
  PackageStatus.distributed: 'distributed',
};

_$ReliefReceiptImpl _$$ReliefReceiptImplFromJson(Map<String, dynamic> json) =>
    _$ReliefReceiptImpl(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      distributedAt: DateTime.parse(json['distributedAt'] as String),
      distributedBy: json['distributedBy'] as String,
      source: $enumDecode(_$SupplySourceEnumMap, json['source']),
      items: (json['items'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      packageCode: json['packageCode'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ReliefReceiptImplToJson(_$ReliefReceiptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'householdId': instance.householdId,
      'distributedAt': instance.distributedAt.toIso8601String(),
      'distributedBy': instance.distributedBy,
      'source': _$SupplySourceEnumMap[instance.source]!,
      'items': instance.items,
      'packageCode': instance.packageCode,
      'note': instance.note,
    };

const _$SupplySourceEnumMap = {
  SupplySource.communeWarehouse: 'communeWarehouse',
  SupplySource.teamStanding: 'teamStanding',
  SupplySource.teamBrought: 'teamBrought',
  SupplySource.packageDirect: 'packageDirect',
};
