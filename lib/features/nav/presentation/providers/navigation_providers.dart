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

Future<void> refreshDevicePosition(WidgetRef ref) async {
  ref.invalidate(currentDevicePositionProvider);
}

// Will be refreshed when currentPositionProvider is refreshed
final nearbyPlacesProvider = FutureProvider<List<Place>?>((ref) async {
  final center = ref.watch(currentDevicePositionProvider).valueOrNull;
  if (center == null) return null;  // device position is not ready yet
  final repo = ref.watch(placesRepositoryProvider);
  return await repo.getPlaces(center);  // should await or not?
});

// final nearestPlaceProvider = StateProvider<Place?>( (ref) {
//   ref.watch(nearbyPlacesProvider).when(
//     data: (places) {
//         if (places.isEmpty) return null;
//         ref.watch(currentPlaceProvider.notifier).state = places.first;
//         return places.first;
//       },
//     loading: () => null,
//     error: (error, stack) => null,
//   );
// });

class CurrentPlaceController extends StateNotifier<Place?> {
  CurrentPlaceController(Ref ref) : super(null) {
    ref.listen<AsyncValue<List<Place>?>>(nearbyPlacesProvider, (prev, next) {
      next.whenData((places) {
        // without compare state, the assignment will cause placeMapProvider
        // to rebuild without select magic
        if (places == null) return;   // error in get places
        if (places.isEmpty) state = null; // get empty list: no place matched
        if (state != places.first) state = places.first;
      });
    });
  }
}

final currentPlaceProvider =
    StateNotifierProvider<CurrentPlaceController, Place?>(
  (ref) => CurrentPlaceController(ref),
);

// final currentPlaceProvider = StateProvider<Place?>((ref) {
//   final places = ref.watch(nearbyPlacesProvider).valueOrNull;
//   if (places == null || places.isEmpty) return null;
//   return places.first;
// });

final placeMatchedProvider = StateProvider<bool>((ref) {
  final place = ref.watch(currentPlaceProvider);
  return place != null;
});

// currentPlaceProvider may be updated by gps or manual selection
final placeMapProvider = FutureProvider<MapResult?>((ref) async {
  final place = ref.watch(currentPlaceProvider);
  // final place = ref.watch(currentPlaceProvider.select((p) => p));
  // final placeId = ref.watch(currentPlaceProvider.select((p) => p?.id));

  if (place == null) return null;

  final repo = ref.watch(placeMapRepositoryProvider);
  return await repo.getMap(place.id);

});

// Extract levels from the fetched placeMap
final availableLevelsProvider = Provider<List<Level>>((ref) {
  final mapResult = ref.watch(placeMapProvider).valueOrNull;    // TODO: how to do with error?
  if (mapResult == null) return [];

  return mapResult.placeMap.levels;
});

final poiManagerProvider = Provider<PoiManager?>((ref) {
  final mapResult = ref.watch(placeMapProvider).valueOrNull;    // TODO: how to do with error?
  if (mapResult == null) return null;

  return mapResult.poiManager;
});

class CurrentLevelController extends StateNotifier<Level?> {   // StateNotifier must be provided by StateNotifierProvider
  CurrentLevelController(Ref ref) : super(null) {
    ref.listen<List<Level>>(availableLevelsProvider, (prev, next) {
      if (next.isNotEmpty) state = next.getDefaultLevel();
    });
  }
}

// Current level provider for map display
// reset when placemap fetched. Changed by tap
final currentLevelProvider =
    StateNotifierProvider<CurrentLevelController, Level?>(
  (ref) => CurrentLevelController(ref),
);

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
  routing  // Routing mode with routing input
}
