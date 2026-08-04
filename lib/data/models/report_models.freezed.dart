// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ThirdPartyReport _$ThirdPartyReportFromJson(Map<String, dynamic> json) {
  return _ThirdPartyReport.fromJson(json);
}

/// @nodoc
mixin _$ThirdPartyReport {
  String get reportId => throw _privateConstructorUsedError;
  String get communeId => throw _privateConstructorUsedError;
  String get sectorId => throw _privateConstructorUsedError;
  String get reportedByUserId =>
      throw _privateConstructorUsedError; // Using string for mock location, in real app it would be GeoPoint
  String get location => throw _privateConstructorUsedError;
  String get victimLocation => throw _privateConstructorUsedError;
  String get victimLocationAddress => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;
  String get disasterType => throw _privateConstructorUsedError;
  int get trustScore => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;
  String? get verifiedBy => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ThirdPartyReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThirdPartyReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThirdPartyReportCopyWith<ThirdPartyReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThirdPartyReportCopyWith<$Res> {
  factory $ThirdPartyReportCopyWith(
    ThirdPartyReport value,
    $Res Function(ThirdPartyReport) then,
  ) = _$ThirdPartyReportCopyWithImpl<$Res, ThirdPartyReport>;
  @useResult
  $Res call({
    String reportId,
    String communeId,
    String sectorId,
    String reportedByUserId,
    String location,
    String victimLocation,
    String victimLocationAddress,
    String description,
    List<String> photoUrls,
    String disasterType,
    int trustScore,
    ReportStatus status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ThirdPartyReportCopyWithImpl<$Res, $Val extends ThirdPartyReport>
    implements $ThirdPartyReportCopyWith<$Res> {
  _$ThirdPartyReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThirdPartyReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportId = null,
    Object? communeId = null,
    Object? sectorId = null,
    Object? reportedByUserId = null,
    Object? location = null,
    Object? victimLocation = null,
    Object? victimLocationAddress = null,
    Object? description = null,
    Object? photoUrls = null,
    Object? disasterType = null,
    Object? trustScore = null,
    Object? status = null,
    Object? verifiedBy = freezed,
    Object? verifiedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            reportId: null == reportId
                ? _value.reportId
                : reportId // ignore: cast_nullable_to_non_nullable
                      as String,
            communeId: null == communeId
                ? _value.communeId
                : communeId // ignore: cast_nullable_to_non_nullable
                      as String,
            sectorId: null == sectorId
                ? _value.sectorId
                : sectorId // ignore: cast_nullable_to_non_nullable
                      as String,
            reportedByUserId: null == reportedByUserId
                ? _value.reportedByUserId
                : reportedByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            victimLocation: null == victimLocation
                ? _value.victimLocation
                : victimLocation // ignore: cast_nullable_to_non_nullable
                      as String,
            victimLocationAddress: null == victimLocationAddress
                ? _value.victimLocationAddress
                : victimLocationAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            disasterType: null == disasterType
                ? _value.disasterType
                : disasterType // ignore: cast_nullable_to_non_nullable
                      as String,
            trustScore: null == trustScore
                ? _value.trustScore
                : trustScore // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            verifiedBy: freezed == verifiedBy
                ? _value.verifiedBy
                : verifiedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            verifiedAt: freezed == verifiedAt
                ? _value.verifiedAt
                : verifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThirdPartyReportImplCopyWith<$Res>
    implements $ThirdPartyReportCopyWith<$Res> {
  factory _$$ThirdPartyReportImplCopyWith(
    _$ThirdPartyReportImpl value,
    $Res Function(_$ThirdPartyReportImpl) then,
  ) = __$$ThirdPartyReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String reportId,
    String communeId,
    String sectorId,
    String reportedByUserId,
    String location,
    String victimLocation,
    String victimLocationAddress,
    String description,
    List<String> photoUrls,
    String disasterType,
    int trustScore,
    ReportStatus status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ThirdPartyReportImplCopyWithImpl<$Res>
    extends _$ThirdPartyReportCopyWithImpl<$Res, _$ThirdPartyReportImpl>
    implements _$$ThirdPartyReportImplCopyWith<$Res> {
  __$$ThirdPartyReportImplCopyWithImpl(
    _$ThirdPartyReportImpl _value,
    $Res Function(_$ThirdPartyReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThirdPartyReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportId = null,
    Object? communeId = null,
    Object? sectorId = null,
    Object? reportedByUserId = null,
    Object? location = null,
    Object? victimLocation = null,
    Object? victimLocationAddress = null,
    Object? description = null,
    Object? photoUrls = null,
    Object? disasterType = null,
    Object? trustScore = null,
    Object? status = null,
    Object? verifiedBy = freezed,
    Object? verifiedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ThirdPartyReportImpl(
        reportId: null == reportId
            ? _value.reportId
            : reportId // ignore: cast_nullable_to_non_nullable
                  as String,
        communeId: null == communeId
            ? _value.communeId
            : communeId // ignore: cast_nullable_to_non_nullable
                  as String,
        sectorId: null == sectorId
            ? _value.sectorId
            : sectorId // ignore: cast_nullable_to_non_nullable
                  as String,
        reportedByUserId: null == reportedByUserId
            ? _value.reportedByUserId
            : reportedByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        victimLocation: null == victimLocation
            ? _value.victimLocation
            : victimLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        victimLocationAddress: null == victimLocationAddress
            ? _value.victimLocationAddress
            : victimLocationAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        disasterType: null == disasterType
            ? _value.disasterType
            : disasterType // ignore: cast_nullable_to_non_nullable
                  as String,
        trustScore: null == trustScore
            ? _value.trustScore
            : trustScore // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        verifiedBy: freezed == verifiedBy
            ? _value.verifiedBy
            : verifiedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThirdPartyReportImpl implements _ThirdPartyReport {
  const _$ThirdPartyReportImpl({
    required this.reportId,
    required this.communeId,
    required this.sectorId,
    required this.reportedByUserId,
    required this.location,
    required this.victimLocation,
    required this.victimLocationAddress,
    required this.description,
    required final List<String> photoUrls,
    required this.disasterType,
    required this.trustScore,
    required this.status,
    required this.verifiedBy,
    required this.verifiedAt,
    required this.rejectionReason,
    required this.createdAt,
  }) : _photoUrls = photoUrls;

  factory _$ThirdPartyReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThirdPartyReportImplFromJson(json);

  @override
  final String reportId;
  @override
  final String communeId;
  @override
  final String sectorId;
  @override
  final String reportedByUserId;
  // Using string for mock location, in real app it would be GeoPoint
  @override
  final String location;
  @override
  final String victimLocation;
  @override
  final String victimLocationAddress;
  @override
  final String description;
  final List<String> _photoUrls;
  @override
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  final String disasterType;
  @override
  final int trustScore;
  @override
  final ReportStatus status;
  @override
  final String? verifiedBy;
  @override
  final DateTime? verifiedAt;
  @override
  final String? rejectionReason;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ThirdPartyReport(reportId: $reportId, communeId: $communeId, sectorId: $sectorId, reportedByUserId: $reportedByUserId, location: $location, victimLocation: $victimLocation, victimLocationAddress: $victimLocationAddress, description: $description, photoUrls: $photoUrls, disasterType: $disasterType, trustScore: $trustScore, status: $status, verifiedBy: $verifiedBy, verifiedAt: $verifiedAt, rejectionReason: $rejectionReason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThirdPartyReportImpl &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.communeId, communeId) ||
                other.communeId == communeId) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.reportedByUserId, reportedByUserId) ||
                other.reportedByUserId == reportedByUserId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.victimLocation, victimLocation) ||
                other.victimLocation == victimLocation) &&
            (identical(other.victimLocationAddress, victimLocationAddress) ||
                other.victimLocationAddress == victimLocationAddress) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.disasterType, disasterType) ||
                other.disasterType == disasterType) &&
            (identical(other.trustScore, trustScore) ||
                other.trustScore == trustScore) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    reportId,
    communeId,
    sectorId,
    reportedByUserId,
    location,
    victimLocation,
    victimLocationAddress,
    description,
    const DeepCollectionEquality().hash(_photoUrls),
    disasterType,
    trustScore,
    status,
    verifiedBy,
    verifiedAt,
    rejectionReason,
    createdAt,
  );

  /// Create a copy of ThirdPartyReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThirdPartyReportImplCopyWith<_$ThirdPartyReportImpl> get copyWith =>
      __$$ThirdPartyReportImplCopyWithImpl<_$ThirdPartyReportImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ThirdPartyReportImplToJson(this);
  }
}

abstract class _ThirdPartyReport implements ThirdPartyReport {
  const factory _ThirdPartyReport({
    required final String reportId,
    required final String communeId,
    required final String sectorId,
    required final String reportedByUserId,
    required final String location,
    required final String victimLocation,
    required final String victimLocationAddress,
    required final String description,
    required final List<String> photoUrls,
    required final String disasterType,
    required final int trustScore,
    required final ReportStatus status,
    required final String? verifiedBy,
    required final DateTime? verifiedAt,
    required final String? rejectionReason,
    required final DateTime createdAt,
  }) = _$ThirdPartyReportImpl;

  factory _ThirdPartyReport.fromJson(Map<String, dynamic> json) =
      _$ThirdPartyReportImpl.fromJson;

  @override
  String get reportId;
  @override
  String get communeId;
  @override
  String get sectorId;
  @override
  String get reportedByUserId; // Using string for mock location, in real app it would be GeoPoint
  @override
  String get location;
  @override
  String get victimLocation;
  @override
  String get victimLocationAddress;
  @override
  String get description;
  @override
  List<String> get photoUrls;
  @override
  String get disasterType;
  @override
  int get trustScore;
  @override
  ReportStatus get status;
  @override
  String? get verifiedBy;
  @override
  DateTime? get verifiedAt;
  @override
  String? get rejectionReason;
  @override
  DateTime get createdAt;

  /// Create a copy of ThirdPartyReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThirdPartyReportImplCopyWith<_$ThirdPartyReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
