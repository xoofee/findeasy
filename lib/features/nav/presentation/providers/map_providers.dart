import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/data/datasources/places_fake_data_source.dart';
import 'package:findeasy/features/map/data/repositories/place_map_repository_impl.dart';
import 'package:findeasy/features/map/data/repositories/places_repository.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/repositories/place_map_repository.dart';
import 'package:findeasy/features/nav/data/datasources/fake_position_data_source.dart';
import 'package:findeasy/features/nav/data/repositories/device_position_repository.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/data/repositories/map_repository.dart';
import 'package:findeasy/features/map/data/datasources/place_map_asset_data_source.dart';
import 'package:findeasy/features/nav/presentation/providers/map_animation_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_providers.g.dart';

// ======= Dependency Providers =======

// location

final fakePositionDataSourceProvider = Provider((ref) => FakePositionDataSource());
// final devicePositionDataSourceProvider = Provider((ref) => GeolocatorDevicePositionDataSource());

final devicePositionRepositoryProvider = Provider((ref) => DevicePositionRepository(devicePositionSource: ref.read(fakePositionDataSourceProvider)));

// places

final fakePlacesDataSourceProvider = Provider<PlacesDataSource>((ref) => PlacesFakeDataSource());

final placesRepositoryProvider = Provider(
  (ref) => PlacesRepository(placesDataSource: ref.read(fakePlacesDataSourceProvider)),
);

// place map
final assetDataSourceProvider = Provider<PlaceMapAssetDataSource>((ref) => PlaceMapAssetDataSource());

final placeMapRepositoryProvider = Provider((ref) => PlaceMapRepositoryImpl(ref.read(assetDataSourceProvider)));

// ======= State Providers =======

// final currentDevicePositionProvider = StateProvider<latlong2.LatLng?>((ref) => null);

// // called when app resumes
// // do not use a provider that cause side effect: modify another provider
// Future<void> refreshDevicePosition(WidgetRef ref) async {
//   final repo = ref.watch(devicePositionRepositoryProvider);
//   ref.read(currentDevicePositionProvider.notifier).state = await repo.getCurrentPosition();
// }

/* Another async way. Use valueOrNull*/
final currentDevicePositionProvider = FutureProvider<latlong2.LatLng>((ref) async {
  final repo = ref.watch(devicePositionRepositoryProvider);
  return await repo.getCurrentPosition();
});

// Will be refreshed when currentPositionProvider is refreshed
// final nearbyPlacesProvider = FutureProvider<List<Place>>((ref) async {
//   final center = await ref.watch(currentDevicePositionProvider.future);   // valueOrNull is anti-pattern
//   final repo = ref.watch(placesRepositoryProvider);
//   return await repo.getPlaces(center);
// });

// The following is simple but will cause rebuild of placeMapProvider even if a same place is selected
// final currentPlaceProvider = Provider<Place?>((ref) {
//   final places = ref.watch(nearbyPlacesProvider);
//   return places.valueOrNull?.firstOrNull;
// });


final nearestPlaceProvider = FutureProvider<Place>((ref) async {
  final center = await ref.watch(currentDevicePositionProvider.future);
  final repo = ref.watch(placesRepositoryProvider);
  return await repo.getNearestPlace(center);
});

@riverpod
class CurrentPlace extends _$CurrentPlace {
  CurrentPlace() : super();
  
  @override
  AsyncValue<Place> build() {  // ✅ No null, just AsyncValue<Place>
    // Listen to automatic detection
    ref.listen<AsyncValue<Place>>(
      nearestPlaceProvider,
      (prev, next) {
        next.when(
          data: (place) {
            // Only auto-set if no place is currently selected
            // if (state.value == place) { if there is multiple refresh, add this
              state = AsyncValue.data(place);
            // }
          },
          loading: () { // ui will wait or do nothing if loading
            // Don't override manual selection with loading state
            if (state.valueOrNull == null) {  // if not check, the previous (maybe user selected) place will be lost
              state = const AsyncValue.loading();
            }
          },
          error: (error, stack) {   // the ui will pop out places (manual) selection list if error occurs
            // Don't override manual selection with error state
            if (state.valueOrNull == null) {  // same as above
              state = AsyncValue.error(error, stack);
            }
          },
        );
      },
    );
    return const AsyncValue.loading(); // Initial state
  }

  void setPlace(Place place) {
    state = AsyncValue.data(place);  // ✅ Set as data
  }

  void clearPlace() {
    state = const AsyncValue.loading();  // ✅ Clear as loading instead of null
  }

  Future<void> refreshAutoDetection() async {
    ref.invalidate(currentDevicePositionProvider);
  }  
}

// final currentPlaceProvider =
//     StateNotifierProvider<CurrentPlaceController, Place?>(
//   (ref) => CurrentPlaceController(ref),
// );

// final currentPlaceProvider = StateProvider<Place?>((ref) {
//   final places = ref.watch(nearbyPlacesProvider).valueOrNull;
//   if (places == null || places.isEmpty) return null;
//   return places.first;
// });

/// currentPlaceProvider may be updated by gps or manual selection
/// async-aware
final placeMapProvider = FutureProvider<MapResult>((ref) async {
  final place = await ref.watch(currentPlaceProvider.future);
  // final place = ref.watch(currentPlaceProvider.select((p) => p));
  // final placeId = ref.watch(currentPlaceProvider.select((p) => p?.id));

  final repo = ref.watch(placeMapRepositoryProvider);
  return await repo.getMap(place.id);   // will throw an exception if the levels are empty
});

/// data-only
final placeMapDataProvider = Provider<MapResult>((ref) {
  final asyncMap = ref.watch(placeMapProvider);
  return asyncMap.requireValue; // helper from Riverpod
});

// Extract levels from the fetched placeMap
final availableLevelsProvider = Provider<List<Level>>((ref) {
  final mapResult = ref.watch(placeMapDataProvider);
  return mapResult.placeMap.levels;
});

final poiManagerProvider = Provider<PoiManager>((ref) {
  final mapResult = ref.watch(placeMapDataProvider);
  return mapResult.poiManager;
});

// class CurrentLevelController extends StateNotifier<Level?> {   // StateNotifier must be provided by StateNotifierProvider
//   CurrentLevelController(Ref ref) : super(null) {
//     ref.listen<List<Level>>(availableLevelsProvider, (prev, next) {
//       if (next.isNotEmpty) state = next.getDefaultLevel();
//     });
//   }
// }

// // Current level provider for map display
// // reset when placemap fetched. Changed by tap
// final currentLevelProvider =
//     StateNotifierProvider<CurrentLevelController, Level?>(
//   (ref) => CurrentLevelController(ref),
// );

@riverpod
class CurrentLevel extends _$CurrentLevel {
  CurrentLevel() : super();

  @override
  Level build() {
    // Listen to availableLevelsProvider
    return ref.watch(availableLevelsProvider).getDefaultLevel();
  }

  void setLevel(Level? level) {
    state = level;
  }  
}

// // POI search provider
// final poiSearchProvider = StateProvider<String>((ref) => '');

// // Filtered POIs provider based on search
// final filteredPoisProvider = Provider<List<Poi>>((ref) {
//   final searchQuery = ref.watch(poiSearchProvider);
//   final pois = ref.watch(poisForCurrentLevelProvider);
  
//   if (searchQuery.isEmpty) return pois;
  
//   return pois.where((poi) => 
//     poi.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
//     poi.type.toLowerCase().contains(searchQuery.toLowerCase())
//   ).toList();
// });

// Map zoom level provider
final mapZoomProvider = StateProvider<double>((ref) => 18.0);

// Map center provider
// final mapCenterProvider = StateProvider<latlong2.LatLng>((ref) => latlong2.LatLng(0, 0));

// // POI visibility settings provider
// final poiVisibilitySettingsProvider = StateProvider<Map<String, bool>>((ref) => {
//   'parking_space': true,
//   'shop': true,
//   'elevator': true,
//   'toilet': true,
//   'crossroad': true,
// });

// // Route display settings provider
// final routeDisplaySettingsProvider = StateProvider<Map<String, bool>>((ref) => {
//   'showRoute': true,
//   'showInstructions': true,
//   'showDistance': true,
//   'showEstimatedTime': true,
// });

// Navigation mode provider - tracks whether we're in normal (home) mode or routing mode
final navigationModeProvider = StateProvider<AppNavigationMode>((ref) => AppNavigationMode.home);

// Navigation mode enum
enum AppNavigationMode {
  home,    // Normal mode with search bar
  routing,  // Routing mode with routing input, routes preview
  navigation, // navigate user to destination with instructions
}
