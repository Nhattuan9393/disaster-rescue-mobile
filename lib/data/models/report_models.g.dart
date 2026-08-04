// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThirdPartyReportImpl _$$ThirdPartyReportImplFromJson(
  Map<String, dynamic> json,
) => _$ThirdPartyReportImpl(
  reportId: json['reportId'] as String,
  communeId: json['communeId'] as String,
  sectorId: json['sectorId'] as String,
  reportedByUserId: json['reportedByUserId'] as String,
  location: json['location'] as String,
  victimLocation: json['victimLocation'] as String,
  victimLocationAddress: json['victimLocationAddress'] as String,
  description: json['description'] as String,
  photoUrls: (json['photoUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  disasterType: json['disasterType'] as String,
  trustScore: (json['trustScore'] as num).toInt(),
  status: $enumDecode(_$ReportStatusEnumMap, json['status']),
  verifiedBy: json['verifiedBy'] as String?,
  verifiedAt: json['verifiedAt'] == null
      ? null
      : DateTime.parse(json['verifiedAt'] as String),
  rejectionReason: json['rejectionReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ThirdPartyReportImplToJson(
  _$ThirdPartyReportImpl instance,
) => <String, dynamic>{
  'reportId': instance.reportId,
  'communeId': instance.communeId,
  'sectorId': instance.sectorId,
  'reportedByUserId': instance.reportedByUserId,
  'location': instance.location,
  'victimLocation': instance.victimLocation,
  'victimLocationAddress': instance.victimLocationAddress,
  'description': instance.description,
  'photoUrls': instance.photoUrls,
  'disasterType': instance.disasterType,
  'trustScore': instance.trustScore,
  'status': _$ReportStatusEnumMap[instance.status]!,
  'verifiedBy': instance.verifiedBy,
  'verifiedAt': instance.verifiedAt?.toIso8601String(),
  'rejectionReason': instance.rejectionReason,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ReportStatusEnumMap = {
  ReportStatus.pendingVerification: 'pending_verification',
  ReportStatus.approved: 'approved',
  ReportStatus.rejected: 'rejected',
  ReportStatus.needMoreInfo: 'need_more_info',
};
