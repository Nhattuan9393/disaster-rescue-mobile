import 'package:freezed_annotation/freezed_annotation.dart';
import 'sos_models.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

enum ReportStatus {
  @JsonValue('pending_verification') pendingVerification,
  @JsonValue('approved') approved,
  @JsonValue('rejected') rejected,
  @JsonValue('need_more_info') needMoreInfo,
}

@freezed
class ThirdPartyReport with _$ThirdPartyReport {
  const factory ThirdPartyReport({
    required String reportId,
    required String communeId,
    required String sectorId,
    required String reportedByUserId,
    // Using string for mock location, in real app it would be GeoPoint
    required String location,
    required String victimLocation,
    required String victimLocationAddress,
    required String description,
    required List<String> photoUrls,
    required String disasterType,
    required int trustScore,
    required ReportStatus status,
    required String? verifiedBy,
    required DateTime? verifiedAt,
    required String? rejectionReason,
    required DateTime createdAt,
  }) = _ThirdPartyReport;

  factory ThirdPartyReport.fromJson(Map<String, dynamic> json) =>
      _$ThirdPartyReportFromJson(json);
}
