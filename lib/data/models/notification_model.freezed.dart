// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TargetLocation _$TargetLocationFromJson(Map<String, dynamic> json) {
  return _TargetLocation.fromJson(json);
}

/// @nodoc
mixin _$TargetLocation {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;

  /// Serializes this TargetLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TargetLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TargetLocationCopyWith<TargetLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TargetLocationCopyWith<$Res> {
  factory $TargetLocationCopyWith(
    TargetLocation value,
    $Res Function(TargetLocation) then,
  ) = _$TargetLocationCopyWithImpl<$Res, TargetLocation>;
  @useResult
  $Res call({double latitude, double longitude, String address});
}

/// @nodoc
class _$TargetLocationCopyWithImpl<$Res, $Val extends TargetLocation>
    implements $TargetLocationCopyWith<$Res> {
  _$TargetLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TargetLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = null,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TargetLocationImplCopyWith<$Res>
    implements $TargetLocationCopyWith<$Res> {
  factory _$$TargetLocationImplCopyWith(
    _$TargetLocationImpl value,
    $Res Function(_$TargetLocationImpl) then,
  ) = __$$TargetLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, String address});
}

/// @nodoc
class __$$TargetLocationImplCopyWithImpl<$Res>
    extends _$TargetLocationCopyWithImpl<$Res, _$TargetLocationImpl>
    implements _$$TargetLocationImplCopyWith<$Res> {
  __$$TargetLocationImplCopyWithImpl(
    _$TargetLocationImpl _value,
    $Res Function(_$TargetLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TargetLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = null,
  }) {
    return _then(
      _$TargetLocationImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TargetLocationImpl implements _TargetLocation {
  const _$TargetLocationImpl({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory _$TargetLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TargetLocationImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String address;

  @override
  String toString() {
    return 'TargetLocation(latitude: $latitude, longitude: $longitude, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TargetLocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, address);

  /// Create a copy of TargetLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TargetLocationImplCopyWith<_$TargetLocationImpl> get copyWith =>
      __$$TargetLocationImplCopyWithImpl<_$TargetLocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TargetLocationImplToJson(this);
  }
}

abstract class _TargetLocation implements TargetLocation {
  const factory _TargetLocation({
    required final double latitude,
    required final double longitude,
    required final String address,
  }) = _$TargetLocationImpl;

  factory _TargetLocation.fromJson(Map<String, dynamic> json) =
      _$TargetLocationImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get address;

  /// Create a copy of TargetLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TargetLocationImplCopyWith<_$TargetLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShelterInfo _$ShelterInfoFromJson(Map<String, dynamic> json) {
  return _ShelterInfo.fromJson(json);
}

/// @nodoc
mixin _$ShelterInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  int get currentOccupancy => throw _privateConstructorUsedError;
  List<String> get availableSupplies => throw _privateConstructorUsedError;

  /// Serializes this ShelterInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShelterInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShelterInfoCopyWith<ShelterInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShelterInfoCopyWith<$Res> {
  factory $ShelterInfoCopyWith(
    ShelterInfo value,
    $Res Function(ShelterInfo) then,
  ) = _$ShelterInfoCopyWithImpl<$Res, ShelterInfo>;
  @useResult
  $Res call({
    String id,
    String name,
    int capacity,
    int currentOccupancy,
    List<String> availableSupplies,
  });
}

/// @nodoc
class _$ShelterInfoCopyWithImpl<$Res, $Val extends ShelterInfo>
    implements $ShelterInfoCopyWith<$Res> {
  _$ShelterInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShelterInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? capacity = null,
    Object? currentOccupancy = null,
    Object? availableSupplies = null,
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
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            currentOccupancy: null == currentOccupancy
                ? _value.currentOccupancy
                : currentOccupancy // ignore: cast_nullable_to_non_nullable
                      as int,
            availableSupplies: null == availableSupplies
                ? _value.availableSupplies
                : availableSupplies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShelterInfoImplCopyWith<$Res>
    implements $ShelterInfoCopyWith<$Res> {
  factory _$$ShelterInfoImplCopyWith(
    _$ShelterInfoImpl value,
    $Res Function(_$ShelterInfoImpl) then,
  ) = __$$ShelterInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int capacity,
    int currentOccupancy,
    List<String> availableSupplies,
  });
}

/// @nodoc
class __$$ShelterInfoImplCopyWithImpl<$Res>
    extends _$ShelterInfoCopyWithImpl<$Res, _$ShelterInfoImpl>
    implements _$$ShelterInfoImplCopyWith<$Res> {
  __$$ShelterInfoImplCopyWithImpl(
    _$ShelterInfoImpl _value,
    $Res Function(_$ShelterInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShelterInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? capacity = null,
    Object? currentOccupancy = null,
    Object? availableSupplies = null,
  }) {
    return _then(
      _$ShelterInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        currentOccupancy: null == currentOccupancy
            ? _value.currentOccupancy
            : currentOccupancy // ignore: cast_nullable_to_non_nullable
                  as int,
        availableSupplies: null == availableSupplies
            ? _value._availableSupplies
            : availableSupplies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShelterInfoImpl implements _ShelterInfo {
  const _$ShelterInfoImpl({
    required this.id,
    required this.name,
    required this.capacity,
    required this.currentOccupancy,
    required final List<String> availableSupplies,
  }) : _availableSupplies = availableSupplies;

  factory _$ShelterInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShelterInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int capacity;
  @override
  final int currentOccupancy;
  final List<String> _availableSupplies;
  @override
  List<String> get availableSupplies {
    if (_availableSupplies is EqualUnmodifiableListView)
      return _availableSupplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableSupplies);
  }

  @override
  String toString() {
    return 'ShelterInfo(id: $id, name: $name, capacity: $capacity, currentOccupancy: $currentOccupancy, availableSupplies: $availableSupplies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShelterInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.currentOccupancy, currentOccupancy) ||
                other.currentOccupancy == currentOccupancy) &&
            const DeepCollectionEquality().equals(
              other._availableSupplies,
              _availableSupplies,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    capacity,
    currentOccupancy,
    const DeepCollectionEquality().hash(_availableSupplies),
  );

  /// Create a copy of ShelterInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShelterInfoImplCopyWith<_$ShelterInfoImpl> get copyWith =>
      __$$ShelterInfoImplCopyWithImpl<_$ShelterInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShelterInfoImplToJson(this);
  }
}

abstract class _ShelterInfo implements ShelterInfo {
  const factory _ShelterInfo({
    required final String id,
    required final String name,
    required final int capacity,
    required final int currentOccupancy,
    required final List<String> availableSupplies,
  }) = _$ShelterInfoImpl;

  factory _ShelterInfo.fromJson(Map<String, dynamic> json) =
      _$ShelterInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get capacity;
  @override
  int get currentOccupancy;
  @override
  List<String> get availableSupplies;

  /// Create a copy of ShelterInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShelterInfoImplCopyWith<_$ShelterInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get bodyTay =>
      throw _privateConstructorUsedError; // Nội dung tiếng Tày (FR-15.2)
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  TargetLocation? get targetLocation => throw _privateConstructorUsedError;
  ShelterInfo? get shelterInfo => throw _privateConstructorUsedError;
  List<String>? get requiredItems => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
    NotificationModel value,
    $Res Function(NotificationModel) then,
  ) = _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String? bodyTay,
    NotificationType type,
    NotificationPriority priority,
    DateTime createdAt,
    bool isRead,
    TargetLocation? targetLocation,
    ShelterInfo? shelterInfo,
    List<String>? requiredItems,
  });

  $TargetLocationCopyWith<$Res>? get targetLocation;
  $ShelterInfoCopyWith<$Res>? get shelterInfo;
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? bodyTay = freezed,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? targetLocation = freezed,
    Object? shelterInfo = freezed,
    Object? requiredItems = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyTay: freezed == bodyTay
                ? _value.bodyTay
                : bodyTay // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            targetLocation: freezed == targetLocation
                ? _value.targetLocation
                : targetLocation // ignore: cast_nullable_to_non_nullable
                      as TargetLocation?,
            shelterInfo: freezed == shelterInfo
                ? _value.shelterInfo
                : shelterInfo // ignore: cast_nullable_to_non_nullable
                      as ShelterInfo?,
            requiredItems: freezed == requiredItems
                ? _value.requiredItems
                : requiredItems // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TargetLocationCopyWith<$Res>? get targetLocation {
    if (_value.targetLocation == null) {
      return null;
    }

    return $TargetLocationCopyWith<$Res>(_value.targetLocation!, (value) {
      return _then(_value.copyWith(targetLocation: value) as $Val);
    });
  }

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShelterInfoCopyWith<$Res>? get shelterInfo {
    if (_value.shelterInfo == null) {
      return null;
    }

    return $ShelterInfoCopyWith<$Res>(_value.shelterInfo!, (value) {
      return _then(_value.copyWith(shelterInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(
    _$NotificationModelImpl value,
    $Res Function(_$NotificationModelImpl) then,
  ) = __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String? bodyTay,
    NotificationType type,
    NotificationPriority priority,
    DateTime createdAt,
    bool isRead,
    TargetLocation? targetLocation,
    ShelterInfo? shelterInfo,
    List<String>? requiredItems,
  });

  @override
  $TargetLocationCopyWith<$Res>? get targetLocation;
  @override
  $ShelterInfoCopyWith<$Res>? get shelterInfo;
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(
    _$NotificationModelImpl _value,
    $Res Function(_$NotificationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? bodyTay = freezed,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? targetLocation = freezed,
    Object? shelterInfo = freezed,
    Object? requiredItems = freezed,
  }) {
    return _then(
      _$NotificationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyTay: freezed == bodyTay
            ? _value.bodyTay
            : bodyTay // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        targetLocation: freezed == targetLocation
            ? _value.targetLocation
            : targetLocation // ignore: cast_nullable_to_non_nullable
                  as TargetLocation?,
        shelterInfo: freezed == shelterInfo
            ? _value.shelterInfo
            : shelterInfo // ignore: cast_nullable_to_non_nullable
                  as ShelterInfo?,
        requiredItems: freezed == requiredItems
            ? _value._requiredItems
            : requiredItems // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl({
    required this.id,
    required this.title,
    required this.body,
    this.bodyTay,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.targetLocation,
    this.shelterInfo,
    final List<String>? requiredItems,
  }) : _requiredItems = requiredItems;

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? bodyTay;
  // Nội dung tiếng Tày (FR-15.2)
  @override
  final NotificationType type;
  @override
  final NotificationPriority priority;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final TargetLocation? targetLocation;
  @override
  final ShelterInfo? shelterInfo;
  final List<String>? _requiredItems;
  @override
  List<String>? get requiredItems {
    final value = _requiredItems;
    if (value == null) return null;
    if (_requiredItems is EqualUnmodifiableListView) return _requiredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, bodyTay: $bodyTay, type: $type, priority: $priority, createdAt: $createdAt, isRead: $isRead, targetLocation: $targetLocation, shelterInfo: $shelterInfo, requiredItems: $requiredItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.bodyTay, bodyTay) || other.bodyTay == bodyTay) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.targetLocation, targetLocation) ||
                other.targetLocation == targetLocation) &&
            (identical(other.shelterInfo, shelterInfo) ||
                other.shelterInfo == shelterInfo) &&
            const DeepCollectionEquality().equals(
              other._requiredItems,
              _requiredItems,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    body,
    bodyTay,
    type,
    priority,
    createdAt,
    isRead,
    targetLocation,
    shelterInfo,
    const DeepCollectionEquality().hash(_requiredItems),
  );

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(this);
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel({
    required final String id,
    required final String title,
    required final String body,
    final String? bodyTay,
    required final NotificationType type,
    required final NotificationPriority priority,
    required final DateTime createdAt,
    final bool isRead,
    final TargetLocation? targetLocation,
    final ShelterInfo? shelterInfo,
    final List<String>? requiredItems,
  }) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String? get bodyTay; // Nội dung tiếng Tày (FR-15.2)
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  TargetLocation? get targetLocation;
  @override
  ShelterInfo? get shelterInfo;
  @override
  List<String>? get requiredItems;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
