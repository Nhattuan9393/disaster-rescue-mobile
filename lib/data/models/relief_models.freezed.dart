// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relief_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReliefItem _$ReliefItemFromJson(Map<String, dynamic> json) {
  return _ReliefItem.fromJson(json);
}

/// @nodoc
mixin _$ReliefItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get threshold => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// Serializes this ReliefItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReliefItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReliefItemCopyWith<ReliefItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReliefItemCopyWith<$Res> {
  factory $ReliefItemCopyWith(
    ReliefItem value,
    $Res Function(ReliefItem) then,
  ) = _$ReliefItemCopyWithImpl<$Res, ReliefItem>;
  @useResult
  $Res call({
    String id,
    String name,
    double quantity,
    double threshold,
    String unit,
  });
}

/// @nodoc
class _$ReliefItemCopyWithImpl<$Res, $Val extends ReliefItem>
    implements $ReliefItemCopyWith<$Res> {
  _$ReliefItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReliefItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? threshold = null,
    Object? unit = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            threshold: null == threshold
                ? _value.threshold
                : threshold // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReliefItemImplCopyWith<$Res>
    implements $ReliefItemCopyWith<$Res> {
  factory _$$ReliefItemImplCopyWith(
    _$ReliefItemImpl value,
    $Res Function(_$ReliefItemImpl) then,
  ) = __$$ReliefItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double quantity,
    double threshold,
    String unit,
  });
}

/// @nodoc
class __$$ReliefItemImplCopyWithImpl<$Res>
    extends _$ReliefItemCopyWithImpl<$Res, _$ReliefItemImpl>
    implements _$$ReliefItemImplCopyWith<$Res> {
  __$$ReliefItemImplCopyWithImpl(
    _$ReliefItemImpl _value,
    $Res Function(_$ReliefItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReliefItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? threshold = null,
    Object? unit = null,
  }) {
    return _then(
      _$ReliefItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        threshold: null == threshold
            ? _value.threshold
            : threshold // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReliefItemImpl implements _ReliefItem {
  const _$ReliefItemImpl({
    required this.id,
    required this.name,
    required this.quantity,
    required this.threshold,
    required this.unit,
  });

  factory _$ReliefItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReliefItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double quantity;
  @override
  final double threshold;
  @override
  final String unit;

  @override
  String toString() {
    return 'ReliefItem(id: $id, name: $name, quantity: $quantity, threshold: $threshold, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReliefItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.threshold, threshold) ||
                other.threshold == threshold) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, quantity, threshold, unit);

  /// Create a copy of ReliefItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReliefItemImplCopyWith<_$ReliefItemImpl> get copyWith =>
      __$$ReliefItemImplCopyWithImpl<_$ReliefItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReliefItemImplToJson(this);
  }
}

abstract class _ReliefItem implements ReliefItem {
  const factory _ReliefItem({
    required final String id,
    required final String name,
    required final double quantity,
    required final double threshold,
    required final String unit,
  }) = _$ReliefItemImpl;

  factory _ReliefItem.fromJson(Map<String, dynamic> json) =
      _$ReliefItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get quantity;
  @override
  double get threshold;
  @override
  String get unit;

  /// Create a copy of ReliefItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReliefItemImplCopyWith<_$ReliefItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageLine _$PackageLineFromJson(Map<String, dynamic> json) {
  return _PackageLine.fromJson(json);
}

/// @nodoc
mixin _$PackageLine {
  String get rawName => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String? get mappedItemId => throw _privateConstructorUsedError;

  /// Serializes this PackageLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackageLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageLineCopyWith<PackageLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageLineCopyWith<$Res> {
  factory $PackageLineCopyWith(
    PackageLine value,
    $Res Function(PackageLine) then,
  ) = _$PackageLineCopyWithImpl<$Res, PackageLine>;
  @useResult
  $Res call({
    String rawName,
    double quantity,
    String unit,
    String? mappedItemId,
  });
}

/// @nodoc
class _$PackageLineCopyWithImpl<$Res, $Val extends PackageLine>
    implements $PackageLineCopyWith<$Res> {
  _$PackageLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackageLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawName = null,
    Object? quantity = null,
    Object? unit = null,
    Object? mappedItemId = freezed,
  }) {
    return _then(
      _value.copyWith(
            rawName: null == rawName
                ? _value.rawName
                : rawName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            mappedItemId: freezed == mappedItemId
                ? _value.mappedItemId
                : mappedItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PackageLineImplCopyWith<$Res>
    implements $PackageLineCopyWith<$Res> {
  factory _$$PackageLineImplCopyWith(
    _$PackageLineImpl value,
    $Res Function(_$PackageLineImpl) then,
  ) = __$$PackageLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rawName,
    double quantity,
    String unit,
    String? mappedItemId,
  });
}

/// @nodoc
class __$$PackageLineImplCopyWithImpl<$Res>
    extends _$PackageLineCopyWithImpl<$Res, _$PackageLineImpl>
    implements _$$PackageLineImplCopyWith<$Res> {
  __$$PackageLineImplCopyWithImpl(
    _$PackageLineImpl _value,
    $Res Function(_$PackageLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PackageLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawName = null,
    Object? quantity = null,
    Object? unit = null,
    Object? mappedItemId = freezed,
  }) {
    return _then(
      _$PackageLineImpl(
        rawName: null == rawName
            ? _value.rawName
            : rawName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        mappedItemId: freezed == mappedItemId
            ? _value.mappedItemId
            : mappedItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageLineImpl implements _PackageLine {
  const _$PackageLineImpl({
    required this.rawName,
    required this.quantity,
    required this.unit,
    required this.mappedItemId,
  });

  factory _$PackageLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageLineImplFromJson(json);

  @override
  final String rawName;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  final String? mappedItemId;

  @override
  String toString() {
    return 'PackageLine(rawName: $rawName, quantity: $quantity, unit: $unit, mappedItemId: $mappedItemId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageLineImpl &&
            (identical(other.rawName, rawName) || other.rawName == rawName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.mappedItemId, mappedItemId) ||
                other.mappedItemId == mappedItemId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rawName, quantity, unit, mappedItemId);

  /// Create a copy of PackageLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageLineImplCopyWith<_$PackageLineImpl> get copyWith =>
      __$$PackageLineImplCopyWithImpl<_$PackageLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageLineImplToJson(this);
  }
}

abstract class _PackageLine implements PackageLine {
  const factory _PackageLine({
    required final String rawName,
    required final double quantity,
    required final String unit,
    required final String? mappedItemId,
  }) = _$PackageLineImpl;

  factory _PackageLine.fromJson(Map<String, dynamic> json) =
      _$PackageLineImpl.fromJson;

  @override
  String get rawName;
  @override
  double get quantity;
  @override
  String get unit;
  @override
  String? get mappedItemId;

  /// Create a copy of PackageLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageLineImplCopyWith<_$PackageLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReliefPackage _$ReliefPackageFromJson(Map<String, dynamic> json) {
  return _ReliefPackage.fromJson(json);
}

/// @nodoc
mixin _$ReliefPackage {
  String get code => throw _privateConstructorUsedError;
  String get donorName => throw _privateConstructorUsedError;
  String get donorPhone => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;
  String get receivedBy => throw _privateConstructorUsedError;
  PackageStatus get status => throw _privateConstructorUsedError;
  List<PackageLine> get lines => throw _privateConstructorUsedError;

  /// Serializes this ReliefPackage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReliefPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReliefPackageCopyWith<ReliefPackage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReliefPackageCopyWith<$Res> {
  factory $ReliefPackageCopyWith(
    ReliefPackage value,
    $Res Function(ReliefPackage) then,
  ) = _$ReliefPackageCopyWithImpl<$Res, ReliefPackage>;
  @useResult
  $Res call({
    String code,
    String donorName,
    String donorPhone,
    DateTime receivedAt,
    String receivedBy,
    PackageStatus status,
    List<PackageLine> lines,
  });
}

/// @nodoc
class _$ReliefPackageCopyWithImpl<$Res, $Val extends ReliefPackage>
    implements $ReliefPackageCopyWith<$Res> {
  _$ReliefPackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReliefPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? donorName = null,
    Object? donorPhone = null,
    Object? receivedAt = null,
    Object? receivedBy = null,
    Object? status = null,
    Object? lines = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            donorName: null == donorName
                ? _value.donorName
                : donorName // ignore: cast_nullable_to_non_nullable
                      as String,
            donorPhone: null == donorPhone
                ? _value.donorPhone
                : donorPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            receivedAt: null == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            receivedBy: null == receivedBy
                ? _value.receivedBy
                : receivedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PackageStatus,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<PackageLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReliefPackageImplCopyWith<$Res>
    implements $ReliefPackageCopyWith<$Res> {
  factory _$$ReliefPackageImplCopyWith(
    _$ReliefPackageImpl value,
    $Res Function(_$ReliefPackageImpl) then,
  ) = __$$ReliefPackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String donorName,
    String donorPhone,
    DateTime receivedAt,
    String receivedBy,
    PackageStatus status,
    List<PackageLine> lines,
  });
}

/// @nodoc
class __$$ReliefPackageImplCopyWithImpl<$Res>
    extends _$ReliefPackageCopyWithImpl<$Res, _$ReliefPackageImpl>
    implements _$$ReliefPackageImplCopyWith<$Res> {
  __$$ReliefPackageImplCopyWithImpl(
    _$ReliefPackageImpl _value,
    $Res Function(_$ReliefPackageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReliefPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? donorName = null,
    Object? donorPhone = null,
    Object? receivedAt = null,
    Object? receivedBy = null,
    Object? status = null,
    Object? lines = null,
  }) {
    return _then(
      _$ReliefPackageImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        donorName: null == donorName
            ? _value.donorName
            : donorName // ignore: cast_nullable_to_non_nullable
                  as String,
        donorPhone: null == donorPhone
            ? _value.donorPhone
            : donorPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        receivedAt: null == receivedAt
            ? _value.receivedAt
            : receivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        receivedBy: null == receivedBy
            ? _value.receivedBy
            : receivedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PackageStatus,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<PackageLine>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReliefPackageImpl implements _ReliefPackage {
  const _$ReliefPackageImpl({
    required this.code,
    required this.donorName,
    required this.donorPhone,
    required this.receivedAt,
    required this.receivedBy,
    required this.status,
    required final List<PackageLine> lines,
  }) : _lines = lines;

  factory _$ReliefPackageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReliefPackageImplFromJson(json);

  @override
  final String code;
  @override
  final String donorName;
  @override
  final String donorPhone;
  @override
  final DateTime receivedAt;
  @override
  final String receivedBy;
  @override
  final PackageStatus status;
  final List<PackageLine> _lines;
  @override
  List<PackageLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'ReliefPackage(code: $code, donorName: $donorName, donorPhone: $donorPhone, receivedAt: $receivedAt, receivedBy: $receivedBy, status: $status, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReliefPackageImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.donorName, donorName) ||
                other.donorName == donorName) &&
            (identical(other.donorPhone, donorPhone) ||
                other.donorPhone == donorPhone) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.receivedBy, receivedBy) ||
                other.receivedBy == receivedBy) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    donorName,
    donorPhone,
    receivedAt,
    receivedBy,
    status,
    const DeepCollectionEquality().hash(_lines),
  );

  /// Create a copy of ReliefPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReliefPackageImplCopyWith<_$ReliefPackageImpl> get copyWith =>
      __$$ReliefPackageImplCopyWithImpl<_$ReliefPackageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReliefPackageImplToJson(this);
  }
}

abstract class _ReliefPackage implements ReliefPackage {
  const factory _ReliefPackage({
    required final String code,
    required final String donorName,
    required final String donorPhone,
    required final DateTime receivedAt,
    required final String receivedBy,
    required final PackageStatus status,
    required final List<PackageLine> lines,
  }) = _$ReliefPackageImpl;

  factory _ReliefPackage.fromJson(Map<String, dynamic> json) =
      _$ReliefPackageImpl.fromJson;

  @override
  String get code;
  @override
  String get donorName;
  @override
  String get donorPhone;
  @override
  DateTime get receivedAt;
  @override
  String get receivedBy;
  @override
  PackageStatus get status;
  @override
  List<PackageLine> get lines;

  /// Create a copy of ReliefPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReliefPackageImplCopyWith<_$ReliefPackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReliefReceipt _$ReliefReceiptFromJson(Map<String, dynamic> json) {
  return _ReliefReceipt.fromJson(json);
}

/// @nodoc
mixin _$ReliefReceipt {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  DateTime get distributedAt => throw _privateConstructorUsedError;
  String get distributedBy => throw _privateConstructorUsedError;
  SupplySource get source => throw _privateConstructorUsedError;
  Map<String, double> get items =>
      throw _privateConstructorUsedError; // Map itemId -> quantity
  String? get packageCode =>
      throw _privateConstructorUsedError; // Dùng khi phát nguyên gói (packageDirect)
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this ReliefReceipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReliefReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReliefReceiptCopyWith<ReliefReceipt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReliefReceiptCopyWith<$Res> {
  factory $ReliefReceiptCopyWith(
    ReliefReceipt value,
    $Res Function(ReliefReceipt) then,
  ) = _$ReliefReceiptCopyWithImpl<$Res, ReliefReceipt>;
  @useResult
  $Res call({
    String id,
    String householdId,
    DateTime distributedAt,
    String distributedBy,
    SupplySource source,
    Map<String, double> items,
    String? packageCode,
    String? note,
  });
}

/// @nodoc
class _$ReliefReceiptCopyWithImpl<$Res, $Val extends ReliefReceipt>
    implements $ReliefReceiptCopyWith<$Res> {
  _$ReliefReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReliefReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? distributedAt = null,
    Object? distributedBy = null,
    Object? source = null,
    Object? items = null,
    Object? packageCode = freezed,
    Object? note = freezed,
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
            distributedAt: null == distributedAt
                ? _value.distributedAt
                : distributedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            distributedBy: null == distributedBy
                ? _value.distributedBy
                : distributedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as SupplySource,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            packageCode: freezed == packageCode
                ? _value.packageCode
                : packageCode // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ReliefReceiptImplCopyWith<$Res>
    implements $ReliefReceiptCopyWith<$Res> {
  factory _$$ReliefReceiptImplCopyWith(
    _$ReliefReceiptImpl value,
    $Res Function(_$ReliefReceiptImpl) then,
  ) = __$$ReliefReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String householdId,
    DateTime distributedAt,
    String distributedBy,
    SupplySource source,
    Map<String, double> items,
    String? packageCode,
    String? note,
  });
}

/// @nodoc
class __$$ReliefReceiptImplCopyWithImpl<$Res>
    extends _$ReliefReceiptCopyWithImpl<$Res, _$ReliefReceiptImpl>
    implements _$$ReliefReceiptImplCopyWith<$Res> {
  __$$ReliefReceiptImplCopyWithImpl(
    _$ReliefReceiptImpl _value,
    $Res Function(_$ReliefReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReliefReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? distributedAt = null,
    Object? distributedBy = null,
    Object? source = null,
    Object? items = null,
    Object? packageCode = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _$ReliefReceiptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: null == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
                  as String,
        distributedAt: null == distributedAt
            ? _value.distributedAt
            : distributedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        distributedBy: null == distributedBy
            ? _value.distributedBy
            : distributedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as SupplySource,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        packageCode: freezed == packageCode
            ? _value.packageCode
            : packageCode // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$ReliefReceiptImpl implements _ReliefReceipt {
  const _$ReliefReceiptImpl({
    required this.id,
    required this.householdId,
    required this.distributedAt,
    required this.distributedBy,
    required this.source,
    required final Map<String, double> items,
    required this.packageCode,
    required this.note,
  }) : _items = items;

  factory _$ReliefReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReliefReceiptImplFromJson(json);

  @override
  final String id;
  @override
  final String householdId;
  @override
  final DateTime distributedAt;
  @override
  final String distributedBy;
  @override
  final SupplySource source;
  final Map<String, double> _items;
  @override
  Map<String, double> get items {
    if (_items is EqualUnmodifiableMapView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_items);
  }

  // Map itemId -> quantity
  @override
  final String? packageCode;
  // Dùng khi phát nguyên gói (packageDirect)
  @override
  final String? note;

  @override
  String toString() {
    return 'ReliefReceipt(id: $id, householdId: $householdId, distributedAt: $distributedAt, distributedBy: $distributedBy, source: $source, items: $items, packageCode: $packageCode, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReliefReceiptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.distributedAt, distributedAt) ||
                other.distributedAt == distributedAt) &&
            (identical(other.distributedBy, distributedBy) ||
                other.distributedBy == distributedBy) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.packageCode, packageCode) ||
                other.packageCode == packageCode) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    householdId,
    distributedAt,
    distributedBy,
    source,
    const DeepCollectionEquality().hash(_items),
    packageCode,
    note,
  );

  /// Create a copy of ReliefReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReliefReceiptImplCopyWith<_$ReliefReceiptImpl> get copyWith =>
      __$$ReliefReceiptImplCopyWithImpl<_$ReliefReceiptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReliefReceiptImplToJson(this);
  }
}

abstract class _ReliefReceipt implements ReliefReceipt {
  const factory _ReliefReceipt({
    required final String id,
    required final String householdId,
    required final DateTime distributedAt,
    required final String distributedBy,
    required final SupplySource source,
    required final Map<String, double> items,
    required final String? packageCode,
    required final String? note,
  }) = _$ReliefReceiptImpl;

  factory _ReliefReceipt.fromJson(Map<String, dynamic> json) =
      _$ReliefReceiptImpl.fromJson;

  @override
  String get id;
  @override
  String get householdId;
  @override
  DateTime get distributedAt;
  @override
  String get distributedBy;
  @override
  SupplySource get source;
  @override
  Map<String, double> get items; // Map itemId -> quantity
  @override
  String? get packageCode; // Dùng khi phát nguyên gói (packageDirect)
  @override
  String? get note;

  /// Create a copy of ReliefReceipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReliefReceiptImplCopyWith<_$ReliefReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
