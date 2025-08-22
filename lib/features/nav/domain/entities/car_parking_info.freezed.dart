// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_parking_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CarParkingInfo _$CarParkingInfoFromJson(Map<String, dynamic> json) {
  return _CarParkingInfo.fromJson(json);
}

/// @nodoc
mixin _$CarParkingInfo {
  int get placeId => throw _privateConstructorUsedError;
  double get levelNumber => throw _privateConstructorUsedError;
  String get parkingSpaceName => throw _privateConstructorUsedError;
  DateTime get parkedAt => throw _privateConstructorUsedError;

  /// Serializes this CarParkingInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarParkingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarParkingInfoCopyWith<CarParkingInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarParkingInfoCopyWith<$Res> {
  factory $CarParkingInfoCopyWith(
          CarParkingInfo value, $Res Function(CarParkingInfo) then) =
      _$CarParkingInfoCopyWithImpl<$Res, CarParkingInfo>;
  @useResult
  $Res call(
      {int placeId,
      double levelNumber,
      String parkingSpaceName,
      DateTime parkedAt});
}

/// @nodoc
class _$CarParkingInfoCopyWithImpl<$Res, $Val extends CarParkingInfo>
    implements $CarParkingInfoCopyWith<$Res> {
  _$CarParkingInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarParkingInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? levelNumber = null,
    Object? parkingSpaceName = null,
    Object? parkedAt = null,
  }) {
    return _then(_value.copyWith(
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as int,
      levelNumber: null == levelNumber
          ? _value.levelNumber
          : levelNumber // ignore: cast_nullable_to_non_nullable
              as double,
      parkingSpaceName: null == parkingSpaceName
          ? _value.parkingSpaceName
          : parkingSpaceName // ignore: cast_nullable_to_non_nullable
              as String,
      parkedAt: null == parkedAt
          ? _value.parkedAt
          : parkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarParkingInfoImplCopyWith<$Res>
    implements $CarParkingInfoCopyWith<$Res> {
  factory _$$CarParkingInfoImplCopyWith(_$CarParkingInfoImpl value,
          $Res Function(_$CarParkingInfoImpl) then) =
      __$$CarParkingInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int placeId,
      double levelNumber,
      String parkingSpaceName,
      DateTime parkedAt});
}

/// @nodoc
class __$$CarParkingInfoImplCopyWithImpl<$Res>
    extends _$CarParkingInfoCopyWithImpl<$Res, _$CarParkingInfoImpl>
    implements _$$CarParkingInfoImplCopyWith<$Res> {
  __$$CarParkingInfoImplCopyWithImpl(
      _$CarParkingInfoImpl _value, $Res Function(_$CarParkingInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarParkingInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? levelNumber = null,
    Object? parkingSpaceName = null,
    Object? parkedAt = null,
  }) {
    return _then(_$CarParkingInfoImpl(
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as int,
      levelNumber: null == levelNumber
          ? _value.levelNumber
          : levelNumber // ignore: cast_nullable_to_non_nullable
              as double,
      parkingSpaceName: null == parkingSpaceName
          ? _value.parkingSpaceName
          : parkingSpaceName // ignore: cast_nullable_to_non_nullable
              as String,
      parkedAt: null == parkedAt
          ? _value.parkedAt
          : parkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarParkingInfoImpl implements _CarParkingInfo {
  const _$CarParkingInfoImpl(
      {required this.placeId,
      required this.levelNumber,
      required this.parkingSpaceName,
      required this.parkedAt});

  factory _$CarParkingInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarParkingInfoImplFromJson(json);

  @override
  final int placeId;
  @override
  final double levelNumber;
  @override
  final String parkingSpaceName;
  @override
  final DateTime parkedAt;

  @override
  String toString() {
    return 'CarParkingInfo(placeId: $placeId, levelNumber: $levelNumber, parkingSpaceName: $parkingSpaceName, parkedAt: $parkedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarParkingInfoImpl &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.levelNumber, levelNumber) ||
                other.levelNumber == levelNumber) &&
            (identical(other.parkingSpaceName, parkingSpaceName) ||
                other.parkingSpaceName == parkingSpaceName) &&
            (identical(other.parkedAt, parkedAt) ||
                other.parkedAt == parkedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, placeId, levelNumber, parkingSpaceName, parkedAt);

  /// Create a copy of CarParkingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarParkingInfoImplCopyWith<_$CarParkingInfoImpl> get copyWith =>
      __$$CarParkingInfoImplCopyWithImpl<_$CarParkingInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarParkingInfoImplToJson(
      this,
    );
  }
}

abstract class _CarParkingInfo implements CarParkingInfo {
  const factory _CarParkingInfo(
      {required final int placeId,
      required final double levelNumber,
      required final String parkingSpaceName,
      required final DateTime parkedAt}) = _$CarParkingInfoImpl;

  factory _CarParkingInfo.fromJson(Map<String, dynamic> json) =
      _$CarParkingInfoImpl.fromJson;

  @override
  int get placeId;
  @override
  double get levelNumber;
  @override
  String get parkingSpaceName;
  @override
  DateTime get parkedAt;

  /// Create a copy of CarParkingInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarParkingInfoImplCopyWith<_$CarParkingInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
