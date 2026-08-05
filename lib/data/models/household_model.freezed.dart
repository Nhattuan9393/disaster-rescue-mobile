// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HouseholdModel _$HouseholdModelFromJson(Map<String, dynamic> json) {
  return _HouseholdModel.fromJson(json);
}

/// @nodoc
mixin _$HouseholdModel {
  String get id => throw _privateConstructorUsedError;
  String get ownerName => throw _privateConstructorUsedError;
  String get ownerPhone => throw _privateConstructorUsedError;
  String get address =>
      throw _privateConstructorUsedError; // Tên thôn (ví dụ: Đồng Tâm, Bản Vược)
  int get peopleCount => throw _privateConstructorUsedError;
  HouseType get houseType => throw _privateConstructorUsedError;
  bool get hasChildren => throw _privateConstructorUsedError;
  bool get hasElderly => throw _privateConstructorUsedError;
  bool get hasSeriouslyIll => throw _privateConstructorUsedError;
  bool get hasDisabled => throw _privateConstructorUsedError;

  /// Serializes this HouseholdModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HouseholdModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdModelCopyWith<HouseholdModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdModelCopyWith<$Res> {
  factory $HouseholdModelCopyWith(
    HouseholdModel value,
    $Res Function(HouseholdModel) then,
  ) = _$HouseholdModelCopyWithImpl<$Res, HouseholdModel>;
  @useResult
  $Res call({
    String id,
    String ownerName,
    String ownerPhone,
    String address,
    int peopleCount,
    HouseType houseType,
    bool hasChildren,
    bool hasElderly,
    bool hasSeriouslyIll,
    bool hasDisabled,
  });
}

/// @nodoc
class _$HouseholdModelCopyWithImpl<$Res, $Val extends HouseholdModel>
    implements $HouseholdModelCopyWith<$Res> {
  _$HouseholdModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseholdModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? peopleCount = null,
    Object? houseType = null,
    Object? hasChildren = null,
    Object? hasElderly = null,
    Object? hasSeriouslyIll = null,
    Object? hasDisabled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerName: null == ownerName
                ? _value.ownerName
                : ownerName // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerPhone: null == ownerPhone
                ? _value.ownerPhone
                : ownerPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            peopleCount: null == peopleCount
                ? _value.peopleCount
                : peopleCount // ignore: cast_nullable_to_non_nullable
                      as int,
            houseType: null == houseType
                ? _value.houseType
                : houseType // ignore: cast_nullable_to_non_nullable
                      as HouseType,
            hasChildren: null == hasChildren
                ? _value.hasChildren
                : hasChildren // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasElderly: null == hasElderly
                ? _value.hasElderly
                : hasElderly // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasSeriouslyIll: null == hasSeriouslyIll
                ? _value.hasSeriouslyIll
                : hasSeriouslyIll // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasDisabled: null == hasDisabled
                ? _value.hasDisabled
                : hasDisabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HouseholdModelImplCopyWith<$Res>
    implements $HouseholdModelCopyWith<$Res> {
  factory _$$HouseholdModelImplCopyWith(
    _$HouseholdModelImpl value,
    $Res Function(_$HouseholdModelImpl) then,
  ) = __$$HouseholdModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerName,
    String ownerPhone,
    String address,
    int peopleCount,
    HouseType houseType,
    bool hasChildren,
    bool hasElderly,
    bool hasSeriouslyIll,
    bool hasDisabled,
  });
}

/// @nodoc
class __$$HouseholdModelImplCopyWithImpl<$Res>
    extends _$HouseholdModelCopyWithImpl<$Res, _$HouseholdModelImpl>
    implements _$$HouseholdModelImplCopyWith<$Res> {
  __$$HouseholdModelImplCopyWithImpl(
    _$HouseholdModelImpl _value,
    $Res Function(_$HouseholdModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HouseholdModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? peopleCount = null,
    Object? houseType = null,
    Object? hasChildren = null,
    Object? hasElderly = null,
    Object? hasSeriouslyIll = null,
    Object? hasDisabled = null,
  }) {
    return _then(
      _$HouseholdModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerName: null == ownerName
            ? _value.ownerName
            : ownerName // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerPhone: null == ownerPhone
            ? _value.ownerPhone
            : ownerPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        peopleCount: null == peopleCount
            ? _value.peopleCount
            : peopleCount // ignore: cast_nullable_to_non_nullable
                  as int,
        houseType: null == houseType
            ? _value.houseType
            : houseType // ignore: cast_nullable_to_non_nullable
                  as HouseType,
        hasChildren: null == hasChildren
            ? _value.hasChildren
            : hasChildren // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasElderly: null == hasElderly
            ? _value.hasElderly
            : hasElderly // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasSeriouslyIll: null == hasSeriouslyIll
            ? _value.hasSeriouslyIll
            : hasSeriouslyIll // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasDisabled: null == hasDisabled
            ? _value.hasDisabled
            : hasDisabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseholdModelImpl implements _HouseholdModel {
  const _$HouseholdModelImpl({
    required this.id,
    required this.ownerName,
    required this.ownerPhone,
    required this.address,
    required this.peopleCount,
    required this.houseType,
    this.hasChildren = false,
    this.hasElderly = false,
    this.hasSeriouslyIll = false,
    this.hasDisabled = false,
  });

  factory _$HouseholdModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseholdModelImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerName;
  @override
  final String ownerPhone;
  @override
  final String address;
  // Tên thôn (ví dụ: Đồng Tâm, Bản Vược)
  @override
  final int peopleCount;
  @override
  final HouseType houseType;
  @override
  @JsonKey()
  final bool hasChildren;
  @override
  @JsonKey()
  final bool hasElderly;
  @override
  @JsonKey()
  final bool hasSeriouslyIll;
  @override
  @JsonKey()
  final bool hasDisabled;

  @override
  String toString() {
    return 'HouseholdModel(id: $id, ownerName: $ownerName, ownerPhone: $ownerPhone, address: $address, peopleCount: $peopleCount, houseType: $houseType, hasChildren: $hasChildren, hasElderly: $hasElderly, hasSeriouslyIll: $hasSeriouslyIll, hasDisabled: $hasDisabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerPhone, ownerPhone) ||
                other.ownerPhone == ownerPhone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.peopleCount, peopleCount) ||
                other.peopleCount == peopleCount) &&
            (identical(other.houseType, houseType) ||
                other.houseType == houseType) &&
            (identical(other.hasChildren, hasChildren) ||
                other.hasChildren == hasChildren) &&
            (identical(other.hasElderly, hasElderly) ||
                other.hasElderly == hasElderly) &&
            (identical(other.hasSeriouslyIll, hasSeriouslyIll) ||
                other.hasSeriouslyIll == hasSeriouslyIll) &&
            (identical(other.hasDisabled, hasDisabled) ||
                other.hasDisabled == hasDisabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerName,
    ownerPhone,
    address,
    peopleCount,
    houseType,
    hasChildren,
    hasElderly,
    hasSeriouslyIll,
    hasDisabled,
  );

  /// Create a copy of HouseholdModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdModelImplCopyWith<_$HouseholdModelImpl> get copyWith =>
      __$$HouseholdModelImplCopyWithImpl<_$HouseholdModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseholdModelImplToJson(this);
  }
}

abstract class _HouseholdModel implements HouseholdModel {
  const factory _HouseholdModel({
    required final String id,
    required final String ownerName,
    required final String ownerPhone,
    required final String address,
    required final int peopleCount,
    required final HouseType houseType,
    final bool hasChildren,
    final bool hasElderly,
    final bool hasSeriouslyIll,
    final bool hasDisabled,
  }) = _$HouseholdModelImpl;

  factory _HouseholdModel.fromJson(Map<String, dynamic> json) =
      _$HouseholdModelImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerName;
  @override
  String get ownerPhone;
  @override
  String get address; // Tên thôn (ví dụ: Đồng Tâm, Bản Vược)
  @override
  int get peopleCount;
  @override
  HouseType get houseType;
  @override
  bool get hasChildren;
  @override
  bool get hasElderly;
  @override
  bool get hasSeriouslyIll;
  @override
  bool get hasDisabled;

  /// Create a copy of HouseholdModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdModelImplCopyWith<_$HouseholdModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
