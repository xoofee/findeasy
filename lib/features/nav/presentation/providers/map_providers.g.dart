// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentPlaceHash() => r'4ea81718451a2e57fa94bb2d0431386c83d5bcaf';

/// See also [CurrentPlace].
@ProviderFor(CurrentPlace)
final currentPlaceProvider =
    AutoDisposeNotifierProvider<CurrentPlace, AsyncValue<Place>>.internal(
  CurrentPlace.new,
  name: r'currentPlaceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentPlaceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentPlace = AutoDisposeNotifier<AsyncValue<Place>>;
String _$currentLevelHash() => r'06ebe9866e1b4e8111d91d47922eeb82dd7cc225';

/// See also [CurrentLevel].
@ProviderFor(CurrentLevel)
final currentLevelProvider =
    AutoDisposeNotifierProvider<CurrentLevel, Level?>.internal(
  CurrentLevel.new,
  name: r'currentLevelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentLevelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentLevel = AutoDisposeNotifier<Level?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
