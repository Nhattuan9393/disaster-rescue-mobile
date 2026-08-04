// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RescueTeam _$RescueTeamFromJson(Map<String, dynamic> json) {
  return _RescueTeam.fromJson(json);
}

/// @nodoc
mixin _$RescueTeam {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  TeamType get type => throw _privateConstructorUsedError;
  TeamStatus get status => throw _privateConstructorUsedError;
  List<String> get members => throw _privateConstructorUsedError;
  Map<String, double> get equipment =>
      throw _privateConstructorUsedError; // Vật tư biên chế (đội thường trực)
  Map<String, double> get supplies =>
      throw _privateConstructorUsedError; // Vật tư mang theo (đội vãng lai)
  String get qrCode => throw _privateConstructorUsedError;
  String? get restingReason => throw _privateConstructorUsedError;
  DateTime? get returnTime => throw _privateConstructorUsedError;
  DateTime get lastActive => throw _privateConstructorUsedError;

  /// Serializes this RescueTeam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RescueTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RescueTeamCopyWith<RescueTeam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RescueTeamCopyWith<$Res> {
  factory $RescueTeamCopyWith(
    RescueTeam value,
    $Res Function(RescueTeam) then,
  ) = _$RescueTeamCopyWithImpl<$Res, RescueTeam>;
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    TeamType type,
    TeamStatus status,
    List<String> members,
    Map<String, double> equipment,
    Map<String, double> supplies,
    String qrCode,
    String? restingReason,
    DateTime? returnTime,
    DateTime lastActive,
  });
}

/// @nodoc
class _$RescueTeamCopyWithImpl<$Res, $Val extends RescueTeam>
    implements $RescueTeamCopyWith<$Res> {
  _$RescueTeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RescueTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? type = null,
    Object? status = null,
    Object? members = null,
    Object? equipment = null,
    Object? supplies = null,
    Object? qrCode = null,
    Object? restingReason = freezed,
    Object? returnTime = freezed,
    Object? lastActive = null,
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
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TeamType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TeamStatus,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            equipment: null == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            supplies: null == supplies
                ? _value.supplies
                : supplies // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            qrCode: null == qrCode
                ? _value.qrCode
                : qrCode // ignore: cast_nullable_to_non_nullable
                      as String,
            restingReason: freezed == restingReason
                ? _value.restingReason
                : restingReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            returnTime: freezed == returnTime
                ? _value.returnTime
                : returnTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastActive: null == lastActive
                ? _value.lastActive
                : lastActive // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RescueTeamImplCopyWith<$Res>
    implements $RescueTeamCopyWith<$Res> {
  factory _$$RescueTeamImplCopyWith(
    _$RescueTeamImpl value,
    $Res Function(_$RescueTeamImpl) then,
  ) = __$$RescueTeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    TeamType type,
    TeamStatus status,
    List<String> members,
    Map<String, double> equipment,
    Map<String, double> supplies,
    String qrCode,
    String? restingReason,
    DateTime? returnTime,
    DateTime lastActive,
  });
}

/// @nodoc
class __$$RescueTeamImplCopyWithImpl<$Res>
    extends _$RescueTeamCopyWithImpl<$Res, _$RescueTeamImpl>
    implements _$$RescueTeamImplCopyWith<$Res> {
  __$$RescueTeamImplCopyWithImpl(
    _$RescueTeamImpl _value,
    $Res Function(_$RescueTeamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RescueTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? type = null,
    Object? status = null,
    Object? members = null,
    Object? equipment = null,
    Object? supplies = null,
    Object? qrCode = null,
    Object? restingReason = freezed,
    Object? returnTime = freezed,
    Object? lastActive = null,
  }) {
    return _then(
      _$RescueTeamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TeamType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TeamStatus,
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        equipment: null == equipment
            ? _value._equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        supplies: null == supplies
            ? _value._supplies
            : supplies // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        qrCode: null == qrCode
            ? _value.qrCode
            : qrCode // ignore: cast_nullable_to_non_nullable
                  as String,
        restingReason: freezed == restingReason
            ? _value.restingReason
            : restingReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        returnTime: freezed == returnTime
            ? _value.returnTime
            : returnTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastActive: null == lastActive
            ? _value.lastActive
            : lastActive // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RescueTeamImpl implements _RescueTeam {
  const _$RescueTeamImpl({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.status,
    required final List<String> members,
    required final Map<String, double> equipment,
    required final Map<String, double> supplies,
    required this.qrCode,
    required this.restingReason,
    required this.returnTime,
    required this.lastActive,
  }) : _members = members,
       _equipment = equipment,
       _supplies = supplies;

  factory _$RescueTeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$RescueTeamImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final TeamType type;
  @override
  final TeamStatus status;
  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  final Map<String, double> _equipment;
  @override
  Map<String, double> get equipment {
    if (_equipment is EqualUnmodifiableMapView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_equipment);
  }

  // Vật tư biên chế (đội thường trực)
  final Map<String, double> _supplies;
  // Vật tư biên chế (đội thường trực)
  @override
  Map<String, double> get supplies {
    if (_supplies is EqualUnmodifiableMapView) return _supplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_supplies);
  }

  // Vật tư mang theo (đội vãng lai)
  @override
  final String qrCode;
  @override
  final String? restingReason;
  @override
  final DateTime? returnTime;
  @override
  final DateTime lastActive;

  @override
  String toString() {
    return 'RescueTeam(id: $id, name: $name, phone: $phone, type: $type, status: $status, members: $members, equipment: $equipment, supplies: $supplies, qrCode: $qrCode, restingReason: $restingReason, returnTime: $returnTime, lastActive: $lastActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RescueTeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            const DeepCollectionEquality().equals(
              other._equipment,
              _equipment,
            ) &&
            const DeepCollectionEquality().equals(other._supplies, _supplies) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.restingReason, restingReason) ||
                other.restingReason == restingReason) &&
            (identical(other.returnTime, returnTime) ||
                other.returnTime == returnTime) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    phone,
    type,
    status,
    const DeepCollectionEquality().hash(_members),
    const DeepCollectionEquality().hash(_equipment),
    const DeepCollectionEquality().hash(_supplies),
    qrCode,
    restingReason,
    returnTime,
    lastActive,
  );

  /// Create a copy of RescueTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RescueTeamImplCopyWith<_$RescueTeamImpl> get copyWith =>
      __$$RescueTeamImplCopyWithImpl<_$RescueTeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RescueTeamImplToJson(this);
  }
}

abstract class _RescueTeam implements RescueTeam {
  const factory _RescueTeam({
    required final String id,
    required final String name,
    required final String phone,
    required final TeamType type,
    required final TeamStatus status,
    required final List<String> members,
    required final Map<String, double> equipment,
    required final Map<String, double> supplies,
    required final String qrCode,
    required final String? restingReason,
    required final DateTime? returnTime,
    required final DateTime lastActive,
  }) = _$RescueTeamImpl;

  factory _RescueTeam.fromJson(Map<String, dynamic> json) =
      _$RescueTeamImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phone;
  @override
  TeamType get type;
  @override
  TeamStatus get status;
  @override
  List<String> get members;
  @override
  Map<String, double> get equipment; // Vật tư biên chế (đội thường trực)
  @override
  Map<String, double> get supplies; // Vật tư mang theo (đội vãng lai)
  @override
  String get qrCode;
  @override
  String? get restingReason;
  @override
  DateTime? get returnTime;
  @override
  DateTime get lastActive;

  /// Create a copy of RescueTeam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RescueTeamImplCopyWith<_$RescueTeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
