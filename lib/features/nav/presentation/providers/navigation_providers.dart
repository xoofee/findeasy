import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:easyroute/easyroute.dart';

// Current location provider
final currentLocationProvider = StreamProvider<LatLng>((ref) {
  // This will be implemented with the existing device position repository
  throw UnimplementedError('Current location provider not implemented yet');
});

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

// Map loading state provider
final mapLoadingStateProvider = StateProvider<MapLoadingState>((ref) => MapLoadingState.initial);

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
    state = Level(state.value + 1);
  }

  void goToPreviousLevel() {
    // This will be implemented to find the previous available level
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