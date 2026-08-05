// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evacuation_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EvacuationPoint _$EvacuationPointFromJson(Map<String, dynamic> json) {
  return _EvacuationPoint.fromJson(json);
}

/// @nodoc
mixin _$EvacuationPoint {
  String get id => throw _privateConstructorUsedError;
  String get communeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  int get maxCapacity => throw _privateConstructorUsedError;
  int get currentOccupancy => throw _privateConstructorUsedError;
  EvacuationPointStatus get status => throw _privateConstructorUsedError;
  List<String> get supplies => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get managerName => throw _privateConstructorUsedError;
  String get managerPhone => throw _privateConstructorUsedError;
  bool get isPubliclyVisible => throw _privateConstructorUsedError;

  /// Serializes this EvacuationPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EvacuationPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvacuationPointCopyWith<EvacuationPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvacuationPointCopyWith<$Res> {
  factory $EvacuationPointCopyWith(
    EvacuationPoint value,
    $Res Function(EvacuationPoint) then,
  ) = _$EvacuationPointCopyWithImpl<$Res, EvacuationPoint>;
  @useResult
  $Res call({
    String id,
    String communeId,
    String name,
    String address,
    int maxCapacity,
    int currentOccupancy,
    EvacuationPointStatus status,
    List<String> supplies,
    String? notes,
    String managerName,
    String managerPhone,
    bool isPubliclyVisible,
  });
}

/// @nodoc
class _$EvacuationPointCopyWithImpl<$Res, $Val extends EvacuationPoint>
    implements $EvacuationPointCopyWith<$Res> {
  _$EvacuationPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EvacuationPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communeId = null,
    Object? name = null,
    Object? address = null,
    Object? maxCapacity = null,
    Object? currentOccupancy = null,
    Object? status = null,
    Object? supplies = null,
    Object? notes = freezed,
    Object? managerName = null,
    Object? managerPhone = null,
    Object? isPubliclyVisible = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            communeId: null == communeId
                ? _value.communeId
                : communeId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            maxCapacity: null == maxCapacity
                ? _value.maxCapacity
                : maxCapacity // ignore: cast_nullable_to_non_nullable
                      as int,
            currentOccupancy: null == currentOccupancy
                ? _value.currentOccupancy
                : currentOccupancy // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EvacuationPointStatus,
            supplies: null == supplies
                ? _value.supplies
                : supplies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            managerName: null == managerName
                ? _value.managerName
                : managerName // ignore: cast_nullable_to_non_nullable
                      as String,
            managerPhone: null == managerPhone
                ? _value.managerPhone
                : managerPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            isPubliclyVisible: null == isPubliclyVisible
                ? _value.isPubliclyVisible
                : isPubliclyVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EvacuationPointImplCopyWith<$Res>
    implements $EvacuationPointCopyWith<$Res> {
  factory _$$EvacuationPointImplCopyWith(
    _$EvacuationPointImpl value,
    $Res Function(_$EvacuationPointImpl) then,
  ) = __$$EvacuationPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String communeId,
    String name,
    String address,
    int maxCapacity,
    int currentOccupancy,
    EvacuationPointStatus status,
    List<String> supplies,
    String? notes,
    String managerName,
    String managerPhone,
    bool isPubliclyVisible,
  });
}

/// @nodoc
class __$$EvacuationPointImplCopyWithImpl<$Res>
    extends _$EvacuationPointCopyWithImpl<$Res, _$EvacuationPointImpl>
    implements _$$EvacuationPointImplCopyWith<$Res> {
  __$$EvacuationPointImplCopyWithImpl(
    _$EvacuationPointImpl _value,
    $Res Function(_$EvacuationPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EvacuationPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communeId = null,
    Object? name = null,
    Object? address = null,
    Object? maxCapacity = null,
    Object? currentOccupancy = null,
    Object? status = null,
    Object? supplies = null,
    Object? notes = freezed,
    Object? managerName = null,
    Object? managerPhone = null,
    Object? isPubliclyVisible = null,
  }) {
    return _then(
      _$EvacuationPointImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        communeId: null == communeId
            ? _value.communeId
            : communeId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        maxCapacity: null == maxCapacity
            ? _value.maxCapacity
            : maxCapacity // ignore: cast_nullable_to_non_nullable
                  as int,
        currentOccupancy: null == currentOccupancy
            ? _value.currentOccupancy
            : currentOccupancy // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EvacuationPointStatus,
        supplies: null == supplies
            ? _value._supplies
            : supplies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        managerName: null == managerName
            ? _value.managerName
            : managerName // ignore: cast_nullable_to_non_nullable
                  as String,
        managerPhone: null == managerPhone
            ? _value.managerPhone
            : managerPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        isPubliclyVisible: null == isPubliclyVisible
            ? _value.isPubliclyVisible
            : isPubliclyVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EvacuationPointImpl extends _EvacuationPoint {
  const _$EvacuationPointImpl({
    required this.id,
    required this.communeId,
    required this.name,
    required this.address,
    required this.maxCapacity,
    required this.currentOccupancy,
    required this.status,
    required final List<String> supplies,
    required this.notes,
    required this.managerName,
    required this.managerPhone,
    required this.isPubliclyVisible,
  }) : _supplies = supplies,
       super._();

  factory _$EvacuationPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$EvacuationPointImplFromJson(json);

  @override
  final String id;
  @override
  final String communeId;
  @override
  final String name;
  @override
  final String address;
  @override
  final int maxCapacity;
  @override
  final int currentOccupancy;
  @override
  final EvacuationPointStatus status;
  final List<String> _supplies;
  @override
  List<String> get supplies {
    if (_supplies is EqualUnmodifiableListView) return _supplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supplies);
  }

  @override
  final String? notes;
  @override
  final String managerName;
  @override
  final String managerPhone;
  @override
  final bool isPubliclyVisible;

  @override
  String toString() {
    return 'EvacuationPoint(id: $id, communeId: $communeId, name: $name, address: $address, maxCapacity: $maxCapacity, currentOccupancy: $currentOccupancy, status: $status, supplies: $supplies, notes: $notes, managerName: $managerName, managerPhone: $managerPhone, isPubliclyVisible: $isPubliclyVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvacuationPointImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communeId, communeId) ||
                other.communeId == communeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.currentOccupancy, currentOccupancy) ||
                other.currentOccupancy == currentOccupancy) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._supplies, _supplies) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.managerName, managerName) ||
                other.managerName == managerName) &&
            (identical(other.managerPhone, managerPhone) ||
                other.managerPhone == managerPhone) &&
            (identical(other.isPubliclyVisible, isPubliclyVisible) ||
                other.isPubliclyVisible == isPubliclyVisible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    communeId,
    name,
    address,
    maxCapacity,
    currentOccupancy,
    status,
    const DeepCollectionEquality().hash(_supplies),
    notes,
    managerName,
    managerPhone,
    isPubliclyVisible,
  );

  /// Create a copy of EvacuationPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvacuationPointImplCopyWith<_$EvacuationPointImpl> get copyWith =>
      __$$EvacuationPointImplCopyWithImpl<_$EvacuationPointImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EvacuationPointImplToJson(this);
  }
}

abstract class _EvacuationPoint extends EvacuationPoint {
  const factory _EvacuationPoint({
    required final String id,
    required final String communeId,
    required final String name,
    required final String address,
    required final int maxCapacity,
    required final int currentOccupancy,
    required final EvacuationPointStatus status,
    required final List<String> supplies,
    required final String? notes,
    required final String managerName,
    required final String managerPhone,
    required final bool isPubliclyVisible,
  }) = _$EvacuationPointImpl;
  const _EvacuationPoint._() : super._();

  factory _EvacuationPoint.fromJson(Map<String, dynamic> json) =
      _$EvacuationPointImpl.fromJson;

  @override
  String get id;
  @override
  String get communeId;
  @override
  String get name;
  @override
  String get address;
  @override
  int get maxCapacity;
  @override
  int get currentOccupancy;
  @override
  EvacuationPointStatus get status;
  @override
  List<String> get supplies;
  @override
  String? get notes;
  @override
  String get managerName;
  @override
  String get managerPhone;
  @override
  bool get isPubliclyVisible;

  /// Create a copy of EvacuationPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvacuationPointImplCopyWith<_$EvacuationPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EvacuationOrder _$EvacuationOrderFromJson(Map<String, dynamic> json) {
  return _EvacuationOrder.fromJson(json);
}

/// @nodoc
mixin _$EvacuationOrder {
  String get id => throw _privateConstructorUsedError;
  String get communeId => throw _privateConstructorUsedError;
  List<String> get targetSectorIds => throw _privateConstructorUsedError;
  String get targetEvacuationPointId => throw _privateConstructorUsedError;
  String get messageVi => throw _privateConstructorUsedError;
  String? get messageTay => throw _privateConstructorUsedError;
  int get targetHouseholdCount => throw _privateConstructorUsedError;
  int get confirmedCount => throw _privateConstructorUsedError;
  int get unableCount => throw _privateConstructorUsedError;
  EvacuationOrderStatus get status => throw _privateConstructorUsedError;
  String get issuedBy => throw _privateConstructorUsedError;
  DateTime get issuedAt => throw _privateConstructorUsedError;

  /// Serializes this EvacuationOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EvacuationOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvacuationOrderCopyWith<EvacuationOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvacuationOrderCopyWith<$Res> {
  factory $EvacuationOrderCopyWith(
    EvacuationOrder value,
    $Res Function(EvacuationOrder) then,
  ) = _$EvacuationOrderCopyWithImpl<$Res, EvacuationOrder>;
  @useResult
  $Res call({
    String id,
    String communeId,
    List<String> targetSectorIds,
    String targetEvacuationPointId,
    String messageVi,
    String? messageTay,
    int targetHouseholdCount,
    int confirmedCount,
    int unableCount,
    EvacuationOrderStatus status,
    String issuedBy,
    DateTime issuedAt,
  });
}

/// @nodoc
class _$EvacuationOrderCopyWithImpl<$Res, $Val extends EvacuationOrder>
    implements $EvacuationOrderCopyWith<$Res> {
  _$EvacuationOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EvacuationOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communeId = null,
    Object? targetSectorIds = null,
    Object? targetEvacuationPointId = null,
    Object? messageVi = null,
    Object? messageTay = freezed,
    Object? targetHouseholdCount = null,
    Object? confirmedCount = null,
    Object? unableCount = null,
    Object? status = null,
    Object? issuedBy = null,
    Object? issuedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            communeId: null == communeId
                ? _value.communeId
                : communeId // ignore: cast_nullable_to_non_nullable
                      as String,
            targetSectorIds: null == targetSectorIds
                ? _value.targetSectorIds
                : targetSectorIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            targetEvacuationPointId: null == targetEvacuationPointId
                ? _value.targetEvacuationPointId
                : targetEvacuationPointId // ignore: cast_nullable_to_non_nullable
                      as String,
            messageVi: null == messageVi
                ? _value.messageVi
                : messageVi // ignore: cast_nullable_to_non_nullable
                      as String,
            messageTay: freezed == messageTay
                ? _value.messageTay
                : messageTay // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetHouseholdCount: null == targetHouseholdCount
                ? _value.targetHouseholdCount
                : targetHouseholdCount // ignore: cast_nullable_to_non_nullable
                      as int,
            confirmedCount: null == confirmedCount
                ? _value.confirmedCount
                : confirmedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            unableCount: null == unableCount
                ? _value.unableCount
                : unableCount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EvacuationOrderStatus,
            issuedBy: null == issuedBy
                ? _value.issuedBy
                : issuedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            issuedAt: null == issuedAt
                ? _value.issuedAt
                : issuedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EvacuationOrderImplCopyWith<$Res>
    implements $EvacuationOrderCopyWith<$Res> {
  factory _$$EvacuationOrderImplCopyWith(
    _$EvacuationOrderImpl value,
    $Res Function(_$EvacuationOrderImpl) then,
  ) = __$$EvacuationOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String communeId,
    List<String> targetSectorIds,
    String targetEvacuationPointId,
    String messageVi,
    String? messageTay,
    int targetHouseholdCount,
    int confirmedCount,
    int unableCount,
    EvacuationOrderStatus status,
    String issuedBy,
    DateTime issuedAt,
  });
}

/// @nodoc
class __$$EvacuationOrderImplCopyWithImpl<$Res>
    extends _$EvacuationOrderCopyWithImpl<$Res, _$EvacuationOrderImpl>
    implements _$$EvacuationOrderImplCopyWith<$Res> {
  __$$EvacuationOrderImplCopyWithImpl(
    _$EvacuationOrderImpl _value,
    $Res Function(_$EvacuationOrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EvacuationOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communeId = null,
    Object? targetSectorIds = null,
    Object? targetEvacuationPointId = null,
    Object? messageVi = null,
    Object? messageTay = freezed,
    Object? targetHouseholdCount = null,
    Object? confirmedCount = null,
    Object? unableCount = null,
    Object? status = null,
    Object? issuedBy = null,
    Object? issuedAt = null,
  }) {
    return _then(
      _$EvacuationOrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        communeId: null == communeId
            ? _value.communeId
            : communeId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetSectorIds: null == targetSectorIds
            ? _value._targetSectorIds
            : targetSectorIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        targetEvacuationPointId: null == targetEvacuationPointId
            ? _value.targetEvacuationPointId
            : targetEvacuationPointId // ignore: cast_nullable_to_non_nullable
                  as String,
        messageVi: null == messageVi
            ? _value.messageVi
            : messageVi // ignore: cast_nullable_to_non_nullable
                  as String,
        messageTay: freezed == messageTay
            ? _value.messageTay
            : messageTay // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetHouseholdCount: null == targetHouseholdCount
            ? _value.targetHouseholdCount
            : targetHouseholdCount // ignore: cast_nullable_to_non_nullable
                  as int,
        confirmedCount: null == confirmedCount
            ? _value.confirmedCount
            : confirmedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        unableCount: null == unableCount
            ? _value.unableCount
            : unableCount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EvacuationOrderStatus,
        issuedBy: null == issuedBy
            ? _value.issuedBy
            : issuedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        issuedAt: null == issuedAt
            ? _value.issuedAt
            : issuedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EvacuationOrderImpl extends _EvacuationOrder {
  const _$EvacuationOrderImpl({
    required this.id,
    required this.communeId,
    required final List<String> targetSectorIds,
    required this.targetEvacuationPointId,
    required this.messageVi,
    required this.messageTay,
    required this.targetHouseholdCount,
    required this.confirmedCount,
    required this.unableCount,
    required this.status,
    required this.issuedBy,
    required this.issuedAt,
  }) : _targetSectorIds = targetSectorIds,
       super._();

  factory _$EvacuationOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$EvacuationOrderImplFromJson(json);

  @override
  final String id;
  @override
  final String communeId;
  final List<String> _targetSectorIds;
  @override
  List<String> get targetSectorIds {
    if (_targetSectorIds is EqualUnmodifiableListView) return _targetSectorIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetSectorIds);
  }

  @override
  final String targetEvacuationPointId;
  @override
  final String messageVi;
  @override
  final String? messageTay;
  @override
  final int targetHouseholdCount;
  @override
  final int confirmedCount;
  @override
  final int unableCount;
  @override
  final EvacuationOrderStatus status;
  @override
  final String issuedBy;
  @override
  final DateTime issuedAt;

  @override
  String toString() {
    return 'EvacuationOrder(id: $id, communeId: $communeId, targetSectorIds: $targetSectorIds, targetEvacuationPointId: $targetEvacuationPointId, messageVi: $messageVi, messageTay: $messageTay, targetHouseholdCount: $targetHouseholdCount, confirmedCount: $confirmedCount, unableCount: $unableCount, status: $status, issuedBy: $issuedBy, issuedAt: $issuedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvacuationOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communeId, communeId) ||
                other.communeId == communeId) &&
            const DeepCollectionEquality().equals(
              other._targetSectorIds,
              _targetSectorIds,
            ) &&
            (identical(
                  other.targetEvacuationPointId,
                  targetEvacuationPointId,
                ) ||
                other.targetEvacuationPointId == targetEvacuationPointId) &&
            (identical(other.messageVi, messageVi) ||
                other.messageVi == messageVi) &&
            (identical(other.messageTay, messageTay) ||
                other.messageTay == messageTay) &&
            (identical(other.targetHouseholdCount, targetHouseholdCount) ||
                other.targetHouseholdCount == targetHouseholdCount) &&
            (identical(other.confirmedCount, confirmedCount) ||
                other.confirmedCount == confirmedCount) &&
            (identical(other.unableCount, unableCount) ||
                other.unableCount == unableCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.issuedBy, issuedBy) ||
                other.issuedBy == issuedBy) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    communeId,
    const DeepCollectionEquality().hash(_targetSectorIds),
    targetEvacuationPointId,
    messageVi,
    messageTay,
    targetHouseholdCount,
    confirmedCount,
    unableCount,
    status,
    issuedBy,
    issuedAt,
  );

  /// Create a copy of EvacuationOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvacuationOrderImplCopyWith<_$EvacuationOrderImpl> get copyWith =>
      __$$EvacuationOrderImplCopyWithImpl<_$EvacuationOrderImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EvacuationOrderImplToJson(this);
  }
}

abstract class _EvacuationOrder extends EvacuationOrder {
  const factory _EvacuationOrder({
    required final String id,
    required final String communeId,
    required final List<String> targetSectorIds,
    required final String targetEvacuationPointId,
    required final String messageVi,
    required final String? messageTay,
    required final int targetHouseholdCount,
    required final int confirmedCount,
    required final int unableCount,
    required final EvacuationOrderStatus status,
    required final String issuedBy,
    required final DateTime issuedAt,
  }) = _$EvacuationOrderImpl;
  const _EvacuationOrder._() : super._();

  factory _EvacuationOrder.fromJson(Map<String, dynamic> json) =
      _$EvacuationOrderImpl.fromJson;

  @override
  String get id;
  @override
  String get communeId;
  @override
  List<String> get targetSectorIds;
  @override
  String get targetEvacuationPointId;
  @override
  String get messageVi;
  @override
  String? get messageTay;
  @override
  int get targetHouseholdCount;
  @override
  int get confirmedCount;
  @override
  int get unableCount;
  @override
  EvacuationOrderStatus get status;
  @override
  String get issuedBy;
  @override
  DateTime get issuedAt;

  /// Create a copy of EvacuationOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvacuationOrderImplCopyWith<_$EvacuationOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EvacuationCheckin _$EvacuationCheckinFromJson(Map<String, dynamic> json) {
  return _EvacuationCheckin.fromJson(json);
}

/// @nodoc
mixin _$EvacuationCheckin {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String get householdHeadName => throw _privateConstructorUsedError;
  String get sectorName => throw _privateConstructorUsedError;
  int get presentCount => throw _privateConstructorUsedError;
  int get totalMembers => throw _privateConstructorUsedError;
  DateTime get checkInTime => throw _privateConstructorUsedError;

  /// Serializes this EvacuationCheckin to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EvacuationCheckin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvacuationCheckinCopyWith<EvacuationCheckin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvacuationCheckinCopyWith<$Res> {
  factory $EvacuationCheckinCopyWith(
    EvacuationCheckin value,
    $Res Function(EvacuationCheckin) then,
  ) = _$EvacuationCheckinCopyWithImpl<$Res, EvacuationCheckin>;
  @useResult
  $Res call({
    String id,
    String householdId,
    String householdHeadName,
    String sectorName,
    int presentCount,
    int totalMembers,
    DateTime checkInTime,
  });
}

/// @nodoc
class _$EvacuationCheckinCopyWithImpl<$Res, $Val extends EvacuationCheckin>
    implements $EvacuationCheckinCopyWith<$Res> {
  _$EvacuationCheckinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EvacuationCheckin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? householdHeadName = null,
    Object? sectorName = null,
    Object? presentCount = null,
    Object? totalMembers = null,
    Object? checkInTime = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            householdId: null == householdId
                ? _value.householdId
                : householdId // ignore: cast_nullable_to_non_nullable
                      as String,
            householdHeadName: null == householdHeadName
                ? _value.householdHeadName
                : householdHeadName // ignore: cast_nullable_to_non_nullable
                      as String,
            sectorName: null == sectorName
                ? _value.sectorName
                : sectorName // ignore: cast_nullable_to_non_nullable
                      as String,
            presentCount: null == presentCount
                ? _value.presentCount
                : presentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalMembers: null == totalMembers
                ? _value.totalMembers
                : totalMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            checkInTime: null == checkInTime
                ? _value.checkInTime
                : checkInTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EvacuationCheckinImplCopyWith<$Res>
    implements $EvacuationCheckinCopyWith<$Res> {
  factory _$$EvacuationCheckinImplCopyWith(
    _$EvacuationCheckinImpl value,
    $Res Function(_$EvacuationCheckinImpl) then,
  ) = __$$EvacuationCheckinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String householdId,
    String householdHeadName,
    String sectorName,
    int presentCount,
    int totalMembers,
    DateTime checkInTime,
  });
}

/// @nodoc
class __$$EvacuationCheckinImplCopyWithImpl<$Res>
    extends _$EvacuationCheckinCopyWithImpl<$Res, _$EvacuationCheckinImpl>
    implements _$$EvacuationCheckinImplCopyWith<$Res> {
  __$$EvacuationCheckinImplCopyWithImpl(
    _$EvacuationCheckinImpl _value,
    $Res Function(_$EvacuationCheckinImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EvacuationCheckin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? householdHeadName = null,
    Object? sectorName = null,
    Object? presentCount = null,
    Object? totalMembers = null,
    Object? checkInTime = null,
  }) {
    return _then(
      _$EvacuationCheckinImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: null == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
                  as String,
        householdHeadName: null == householdHeadName
            ? _value.householdHeadName
            : householdHeadName // ignore: cast_nullable_to_non_nullable
                  as String,
        sectorName: null == sectorName
            ? _value.sectorName
            : sectorName // ignore: cast_nullable_to_non_nullable
                  as String,
        presentCount: null == presentCount
            ? _value.presentCount
            : presentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalMembers: null == totalMembers
            ? _value.totalMembers
            : totalMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        checkInTime: null == checkInTime
            ? _value.checkInTime
            : checkInTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EvacuationCheckinImpl implements _EvacuationCheckin {
  const _$EvacuationCheckinImpl({
    required this.id,
    required this.householdId,
    required this.householdHeadName,
    required this.sectorName,
    required this.presentCount,
    required this.totalMembers,
    required this.checkInTime,
  });

  factory _$EvacuationCheckinImpl.fromJson(Map<String, dynamic> json) =>
      _$$EvacuationCheckinImplFromJson(json);

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String householdHeadName;
  @override
  final String sectorName;
  @override
  final int presentCount;
  @override
  final int totalMembers;
  @override
  final DateTime checkInTime;

  @override
  String toString() {
    return 'EvacuationCheckin(id: $id, householdId: $householdId, householdHeadName: $householdHeadName, sectorName: $sectorName, presentCount: $presentCount, totalMembers: $totalMembers, checkInTime: $checkInTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvacuationCheckinImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.householdHeadName, householdHeadName) ||
                other.householdHeadName == householdHeadName) &&
            (identical(other.sectorName, sectorName) ||
                other.sectorName == sectorName) &&
            (identical(other.presentCount, presentCount) ||
                other.presentCount == presentCount) &&
            (identical(other.totalMembers, totalMembers) ||
                other.totalMembers == totalMembers) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    householdId,
    householdHeadName,
    sectorName,
    presentCount,
    totalMembers,
    checkInTime,
  );

  /// Create a copy of EvacuationCheckin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvacuationCheckinImplCopyWith<_$EvacuationCheckinImpl> get copyWith =>
      __$$EvacuationCheckinImplCopyWithImpl<_$EvacuationCheckinImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EvacuationCheckinImplToJson(this);
  }
}

abstract class _EvacuationCheckin implements EvacuationCheckin {
  const factory _EvacuationCheckin({
    required final String id,
    required final String householdId,
    required final String householdHeadName,
    required final String sectorName,
    required final int presentCount,
    required final int totalMembers,
    required final DateTime checkInTime,
  }) = _$EvacuationCheckinImpl;

  factory _EvacuationCheckin.fromJson(Map<String, dynamic> json) =
      _$EvacuationCheckinImpl.fromJson;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String get householdHeadName;
  @override
  String get sectorName;
  @override
  int get presentCount;
  @override
  int get totalMembers;
  @override
  DateTime get checkInTime;

  /// Create a copy of EvacuationCheckin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvacuationCheckinImplCopyWith<_$EvacuationCheckinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
