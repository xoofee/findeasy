// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NavigationState {
  String get voiceText => throw _privateConstructorUsedError;
  double get distance => throw _privateConstructorUsedError;
  bool get deviated => throw _privateConstructorUsedError;
  IndoorInstruction get currentInstruction =>
      throw _privateConstructorUsedError;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NavigationStateCopyWith<NavigationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NavigationStateCopyWith<$Res> {
  factory $NavigationStateCopyWith(
          NavigationState value, $Res Function(NavigationState) then) =
      _$NavigationStateCopyWithImpl<$Res, NavigationState>;
  @useResult
  $Res call(
      {String voiceText,
      double distance,
      bool deviated,
      IndoorInstruction currentInstruction});
}

/// @nodoc
class _$NavigationStateCopyWithImpl<$Res, $Val extends NavigationState>
    implements $NavigationStateCopyWith<$Res> {
  _$NavigationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voiceText = null,
    Object? distance = null,
    Object? deviated = null,
    Object? currentInstruction = null,
  }) {
    return _then(_value.copyWith(
      voiceText: null == voiceText
          ? _value.voiceText
          : voiceText // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      deviated: null == deviated
          ? _value.deviated
          : deviated // ignore: cast_nullable_to_non_nullable
              as bool,
      currentInstruction: null == currentInstruction
          ? _value.currentInstruction
          : currentInstruction // ignore: cast_nullable_to_non_nullable
              as IndoorInstruction,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NavigationStateImplCopyWith<$Res>
    implements $NavigationStateCopyWith<$Res> {
  factory _$$NavigationStateImplCopyWith(_$NavigationStateImpl value,
          $Res Function(_$NavigationStateImpl) then) =
      __$$NavigationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String voiceText,
      double distance,
      bool deviated,
      IndoorInstruction currentInstruction});
}

/// @nodoc
class __$$NavigationStateImplCopyWithImpl<$Res>
    extends _$NavigationStateCopyWithImpl<$Res, _$NavigationStateImpl>
    implements _$$NavigationStateImplCopyWith<$Res> {
  __$$NavigationStateImplCopyWithImpl(
      _$NavigationStateImpl _value, $Res Function(_$NavigationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voiceText = null,
    Object? distance = null,
    Object? deviated = null,
    Object? currentInstruction = null,
  }) {
    return _then(_$NavigationStateImpl(
      voiceText: null == voiceText
          ? _value.voiceText
          : voiceText // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      deviated: null == deviated
          ? _value.deviated
          : deviated // ignore: cast_nullable_to_non_nullable
              as bool,
      currentInstruction: null == currentInstruction
          ? _value.currentInstruction
          : currentInstruction // ignore: cast_nullable_to_non_nullable
              as IndoorInstruction,
    ));
  }
}

/// @nodoc

class _$NavigationStateImpl implements _NavigationState {
  const _$NavigationStateImpl(
      {required this.voiceText,
      required this.distance,
      required this.deviated,
      required this.currentInstruction});

  @override
  final String voiceText;
  @override
  final double distance;
  @override
  final bool deviated;
  @override
  final IndoorInstruction currentInstruction;

  @override
  String toString() {
    return 'NavigationState(voiceText: $voiceText, distance: $distance, deviated: $deviated, currentInstruction: $currentInstruction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigationStateImpl &&
            (identical(other.voiceText, voiceText) ||
                other.voiceText == voiceText) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.deviated, deviated) ||
                other.deviated == deviated) &&
            (identical(other.currentInstruction, currentInstruction) ||
                other.currentInstruction == currentInstruction));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, voiceText, distance, deviated, currentInstruction);

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigationStateImplCopyWith<_$NavigationStateImpl> get copyWith =>
      __$$NavigationStateImplCopyWithImpl<_$NavigationStateImpl>(
          this, _$identity);
}

abstract class _NavigationState implements NavigationState {
  const factory _NavigationState(
          {required final String voiceText,
          required final double distance,
          required final bool deviated,
          required final IndoorInstruction currentInstruction}) =
      _$NavigationStateImpl;

  @override
  String get voiceText;
  @override
  double get distance;
  @override
  bool get deviated;
  @override
  IndoorInstruction get currentInstruction;

  /// Create a copy of NavigationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigationStateImplCopyWith<_$NavigationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
