import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/data/datasources/places_fake_data_source.dart';
import 'package:findeasy/features/map/data/repositories/place_map_repository_impl.dart';
import 'package:findeasy/features/map/data/repositories/places_repository.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/repositories/place_map_repository.dart';
import 'package:findeasy/features/nav/data/datasources/fake_position_data_source.dart';
import 'package:findeasy/features/nav/data/repositories/device_position_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/data/repositories/map_repository.dart';
import 'package:findeasy/features/map/data/datasources/place_map_asset_data_source.dart';


// ======= Providers =======

// location

final fakePositionDataSourceProvider = Provider((ref) => FakePositionDataSource());
// final devicePositionDataSourceProvider = Provider((ref) => GeolocatorDevicePositionDataSource());

final devicePositionRepositoryProvider = Provider((ref) => DevicePositionRepository(devicePositionSource: ref.read(fakePositionDataSourceProvider)));

final currentPositionProvider = FutureProvider<latlong2.LatLng>((ref) async {
  final repo = ref.watch(devicePositionRepositoryProvider);
  return repo.getCurrentPosition();
});

// places

final fakePlacesDataSourceProvider = Provider<PlacesDataSource>((ref) => PlacesFakeDataSource());

final placesRepositoryProvider = Provider(
  (ref) => PlacesRepository(placesDataSource: ref.read(fakePlacesDataSourceProvider)),
);

// place map
final assetDataSourceProvider = Provider<PlaceMapAssetDataSource>((ref) => PlaceMapAssetDataSource());

final placeMapRepositoryProvider = Provider((ref) => PlaceMapRepositoryImpl(ref.read(assetDataSourceProvider)));



final currentPlaceProvider = StateProvider<Place?>((ref) => null);

// Nearby places fetched from repo
final nearbyPlacesProvider =
    FutureProvider<List<Place>>((ref) async {
  final center = await ref.watch(currentPositionProvider.future);
  final repo = ref.watch(placesRepositoryProvider);
  return repo.getPlaces(center);
});

// Map loader depends on the selected place
final mapLoaderProvider =
    FutureProvider<MapResult?>((ref) async {
  final place = ref.watch(currentPlaceProvider);
  if (place == null) return null;

  final repo = ref.watch(placeMapRepositoryProvider);
  return repo.getMap(place.id);
});

final nearestPlaceProvider = StateProvider<Place?>( (ref) => {
  final repo = ref.watch(placesRepositoryProvider);
  final places = await repo.getPlaces(center);
  return places.isNotEmpty ? places.first : null;
});

final mapLoaderProvider =
    FutureProvider.family<MapResult, int>((ref, placeId) async {
  final repo = ref.watch(placeMapRepositoryProvider);
  final mapResult = await repo.getMap(placeId);
  return mapResult;
});

// // Map initialization notifier - handles business logic
// class MapInitializationNotifier extends StateNotifier<MapLoadingState> {
//   final PlaceMapAssetDataSource _assetDataSource;
  
//   MapInitializationNotifier(this._assetDataSource) : super(MapLoadingState.initial);

//   /// Initialize the map on app startup - business logic here
//   Future<(PlaceMap, PoiManager)> initializeMap() async {
//     try {
//       state = MapLoadingState.loading;
      
//       // Load the asset map using existing PlaceMapAssetDataSource
//       final mapFilePath = await _assetDataSource.downloadMap(1); // Use placeId 1 for asset map
      
//       // Load map using EasyRoute's existing function
//       final (placeMap, poiManager) = await loadMapFromOsmFile(mapFilePath);
      
//       // Update the providers with the loaded data
//       state = MapLoadingState.loaded;
      
//       // Return the data for the UI to consume
//       return (placeMap, poiManager);
      
//     } catch (e) {
//       state = MapLoadingState.error;
//       throw Exception('Failed to initialize map: $e');
//     }
//   }

//   void updateState(MapLoadingState newState) {
//     state = newState;
//   }

//   void setLoading() => updateState(MapLoadingState.loading);
//   void setLoaded() => updateState(MapLoadingState.loaded);
//   void setError() => updateState(MapLoadingState.error);
//   void reset() => updateState(MapLoadingState.initial);
// }

// // Map loading state provider
// final mapLoadingStateProvider = StateNotifierProvider<MapInitializationNotifier, MapLoadingState>((ref) {
//   final assetDataSource = ref.watch(assetDataSourceProvider);
//   return MapInitializationNotifier(assetDataSource);
// });


// Current level provider for map display
final currentLevelProvider = StateProvider<Level>((ref) => Level(0));

// Available levels provider
final availableLevelsProvider = StateProvider<List<Level>>((ref) => []);

// PlaceMap provider (loaded from OSM file)
final placeMapProvider = StateProvider<PlaceMap?>((ref) => null);

// POI manager provider
final poiManagerProvider = StateProvider<PoiManager?>((ref) => null);

// POIs for current level provider
final poisForCurrentLevelProvider = Provider<List<Poi>>((ref) {
  final placeMap = ref.watch(placeMapProvider);
  final currentLevel = ref.watch(currentLevelProvider);
  
  if (placeMap == null) return [];
  
  final levelMap = placeMap.levelMaps[currentLevel];
  if (levelMap == null) return [];
  
  return [
    ...levelMap.parkingSpaces,
    ...levelMap.elevators,
    ...levelMap.shops,
  ];
});

// Routes for current level provider
final routesForCurrentLevelProvider = Provider<List<MapWay>>((ref) {
  final placeMap = ref.watch(placeMapProvider);
  final currentLevel = ref.watch(currentLevelProvider);
  
  if (placeMap == null) return [];
  
  final levelMap = placeMap.levelMaps[currentLevel];
  if (levelMap == null) return [];
  
  return levelMap.routes.where((route) => route.levels.contains(currentLevel)).toList();
});

// Selected POI provider
final selectedPoiProvider = StateProvider<Poi?>((ref) => null);

// Route visualization provider
final routeGeometryProvider = StateProvider<List<LatLng>>((ref) => []);

// Map loading state notifier
class MapLoadingStateNotifier extends StateNotifier<MapLoadingState> {
  MapLoadingStateNotifier() : super(MapLoadingState.initial);

  void updateState(MapLoadingState newState) {
    state = newState;
  }

  void setLoading() => updateState(MapLoadingState.loading);
  void setLoaded() => updateState(MapLoadingState.loaded);
  void setError() => updateState(MapLoadingState.error);
  void reset() => updateState(MapLoadingState.initial);
}

// Map loading state provider
final mapLoadingStateProvider = StateNotifierProvider<MapLoadingStateNotifier, MapLoadingState>((ref) {
  return MapLoadingStateNotifier();
});

// Map loading state enum
enum MapLoadingState {
  initial,
  loading,
  loaded,
  error,
}

// Level selection notifier
class LevelSelectionNotifier extends StateNotifier<Level> {
  LevelSelectionNotifier() : super(Level(0));

  void selectLevel(Level level) {
    state = level;
  }

  void goToNextLevel() {
    // This will be implemented to find the next available level
    // For now, just increment by 1
    state = Level(state.value + 1);
  }

  void goToPreviousLevel() {
    // This will be implemented to find the previous available level
    // For now, just decrement by 1
    state = Level(state.value - 1);
  }
}

// Level selection provider
final levelSelectionProvider = StateNotifierProvider<LevelSelectionNotifier, Level>((ref) {
  return LevelSelectionNotifier();
});

// POI search provider
final poiSearchProvider = StateProvider<String>((ref) => '');

// Filtered POIs provider based on search
final filteredPoisProvider = Provider<List<Poi>>((ref) {
  final searchQuery = ref.watch(poiSearchProvider);
  final pois = ref.watch(poisForCurrentLevelProvider);
  
  if (searchQuery.isEmpty) return pois;
  
  return pois.where((poi) => 
    poi.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
    poi.type.toLowerCase().contains(searchQuery.toLowerCase())
  ).toList();
});

// Map zoom level provider
final mapZoomProvider = StateProvider<double>((ref) => 18.0);

// Map center provider
final mapCenterProvider = StateProvider<LatLng>((ref) => LatLng(0, 0));

// POI visibility settings provider
final poiVisibilitySettingsProvider = StateProvider<Map<String, bool>>((ref) => {
  'parking_space': true,
  'shop': true,
  'elevator': true,
  'toilet': true,
  'crossroad': true,
});

// Route display settings provider
final routeDisplaySettingsProvider = StateProvider<Map<String, bool>>((ref) => {
  'showRoute': true,
  'showInstructions': true,
  'showDistance': true,
  'showEstimatedTime': true,
});