// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SafetyStatus _$SafetyStatusFromJson(Map<String, dynamic> json) {
  return _SafetyStatus.fromJson(json);
}

/// @nodoc
mixin _$SafetyStatus {
  SafetyState get status => throw _privateConstructorUsedError;
  SafetySource get source => throw _privateConstructorUsedError;
  String? get verifiedBy => throw _privateConstructorUsedError;
  DateTime get verifiedAt => throw _privateConstructorUsedError;
  int get confidence => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this SafetyStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyStatusCopyWith<SafetyStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyStatusCopyWith<$Res> {
  factory $SafetyStatusCopyWith(
    SafetyStatus value,
    $Res Function(SafetyStatus) then,
  ) = _$SafetyStatusCopyWithImpl<$Res, SafetyStatus>;
  @useResult
  $Res call({
    SafetyState status,
    SafetySource source,
    String? verifiedBy,
    DateTime verifiedAt,
    int confidence,
    String? note,
  });
}

/// @nodoc
class _$SafetyStatusCopyWithImpl<$Res, $Val extends SafetyStatus>
    implements $SafetyStatusCopyWith<$Res> {
  _$SafetyStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? source = null,
    Object? verifiedBy = freezed,
    Object? verifiedAt = null,
    Object? confidence = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SafetyState,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as SafetySource,
            verifiedBy: freezed == verifiedBy
                ? _value.verifiedBy
                : verifiedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            verifiedAt: null == verifiedAt
                ? _value.verifiedAt
                : verifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as int,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SafetyStatusImplCopyWith<$Res>
    implements $SafetyStatusCopyWith<$Res> {
  factory _$$SafetyStatusImplCopyWith(
    _$SafetyStatusImpl value,
    $Res Function(_$SafetyStatusImpl) then,
  ) = __$$SafetyStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SafetyState status,
    SafetySource source,
    String? verifiedBy,
    DateTime verifiedAt,
    int confidence,
    String? note,
  });
}

/// @nodoc
class __$$SafetyStatusImplCopyWithImpl<$Res>
    extends _$SafetyStatusCopyWithImpl<$Res, _$SafetyStatusImpl>
    implements _$$SafetyStatusImplCopyWith<$Res> {
  __$$SafetyStatusImplCopyWithImpl(
    _$SafetyStatusImpl _value,
    $Res Function(_$SafetyStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? source = null,
    Object? verifiedBy = freezed,
    Object? verifiedAt = null,
    Object? confidence = null,
    Object? note = freezed,
  }) {
    return _then(
      _$SafetyStatusImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SafetyState,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as SafetySource,
        verifiedBy: freezed == verifiedBy
            ? _value.verifiedBy
            : verifiedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        verifiedAt: null == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as int,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyStatusImpl extends _SafetyStatus {
  const _$SafetyStatusImpl({
    required this.status,
    required this.source,
    this.verifiedBy,
    required this.verifiedAt,
    required this.confidence,
    this.note,
  }) : super._();

  factory _$SafetyStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyStatusImplFromJson(json);

  @override
  final SafetyState status;
  @override
  final SafetySource source;
  @override
  final String? verifiedBy;
  @override
  final DateTime verifiedAt;
  @override
  final int confidence;
  @override
  final String? note;

  @override
  String toString() {
    return 'SafetyStatus(status: $status, source: $source, verifiedBy: $verifiedBy, verifiedAt: $verifiedAt, confidence: $confidence, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyStatusImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    source,
    verifiedBy,
    verifiedAt,
    confidence,
    note,
  );

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyStatusImplCopyWith<_$SafetyStatusImpl> get copyWith =>
      __$$SafetyStatusImplCopyWithImpl<_$SafetyStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyStatusImplToJson(this);
  }
}

abstract class _SafetyStatus extends SafetyStatus {
  const factory _SafetyStatus({
    required final SafetyState status,
    required final SafetySource source,
    final String? verifiedBy,
    required final DateTime verifiedAt,
    required final int confidence,
    final String? note,
  }) = _$SafetyStatusImpl;
  const _SafetyStatus._() : super._();

  factory _SafetyStatus.fromJson(Map<String, dynamic> json) =
      _$SafetyStatusImpl.fromJson;

  @override
  SafetyState get status;
  @override
  SafetySource get source;
  @override
  String? get verifiedBy;
  @override
  DateTime get verifiedAt;
  @override
  int get confidence;
  @override
  String? get note;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyStatusImplCopyWith<_$SafetyStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
