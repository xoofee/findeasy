UI Widget → State Provider → Use Case → Repository → Data Source
   ↓              ↓           ↓          ↓           ↓
HomePage → LocationState → GetCurrentLocation → LocationRepository → GPS Hardware



```dart

// in data/repositories
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Result<Position>> getCurrentPosition() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.requestPermission();
      ...
    }
  }
}

// in domain/repositary
abstract class LocationRepository {
  Future<Result<Position>> getCurrentPosition();
  Future<Result<Position>> generateFakePosition({
    required double latitude,
    required double longitude,
    double accuracy = 5.0,
    double altitude = 0.0,
    double heading = 0.0,
    double speed = 0.0,
  });
}

// in domain/usercases
class GetCurrentLocation {
  final LocationRepository repository;

  const GetCurrentLocation(this.repository);

  Future<Result<Position>> call() async {
    try {
      return await repository.getCurrentPosition();
    } catch (e) {
      return Error(LocationFailure('Failed to get current location: $e'));
    }
  }
}



// in providers.dart prepare concrete repository (for usecase)
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepositoryImpl(),
);


// providers.dart: inject repository (locationRepositoryProvider) to use case (GetCurrentLocation)
final getCurrentLocationProvider = Provider<GetCurrentLocation>(
  (ref) => GetCurrentLocation(ref.read(locationRepositoryProvider)),
);


// State providers
final locationStateProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(ref.read(getCurrentLocationProvider)),
);

// In a widget
class LocationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the location state
    final locationState = ref.watch(locationStateProvider);
    
    // The provider automatically updates this widget when state changes
    if (locationState.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (locationState.error != null) {
      return Text('${locationState.error}');
    }
    
    if (locationState.position != null) {
      return Text('Location: ${locationState.position}');
    }
    
    return ElevatedButton(
      onPressed: () {
        // Trigger getting location
        ref.read(locationStateProvider.notifier).fetchLocation();
      },
      child: Text('Get Location'),
    );
  }
}
```

# Map

##

```dart

final loadMapUseCaseProvider = Provider((ref) {
  final repo = ref.read(mapRepositoryProvider);
  return LoadMapUseCase(repo);
});

// For UI: just expose PlaceMap
final placeMapProvider = FutureProvider<PlaceMap?>((ref) async {
  final useCase = ref.read(loadMapUseCaseProvider);
  await useCase(); // loads internally
  return ref.read(mapRepositoryProvider).placeMap;
});
```

## UI

```dart

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeMapAsync = ref.watch(placeMapProvider);

    return placeMapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (placeMap) {
        return MapWidget(placeMap: placeMap!);
      },
    );
  }
}

```

## 

```dart

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;

// ======= Domain Models =======
class Place {
  final int id;
  final String name;
  final latlong2.LatLng location;
  Place({required this.id, required this.name, required this.location});
}

class PlaceMap {
  final int placeId;
  final String name;
  PlaceMap(this.placeId, this.name);
}

class Level {
  final String id;
  final String name;
  Level(this.id, this.name);
}

class Poi {
  final int id;
  final String name;
  Poi(this.id, this.name);
}

class MapWay {
  final String id;
  MapWay(this.id);
}

class MapRoute {
  final String id;
  MapRoute(this.id);
}

// ======= Services / Data Sources =======
class PlacesDataSource {
  Future<List<Place>> getPlaces(latlong2.LatLng center,
      {double maxDistance = 500.0, int limit = 10}) async {
    // Simulate network/database
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Place(id: 1, name: "Mall A", location: latlong2.LatLng(1.307, 103.929)),
      Place(id: 2, name: "Mall B", location: latlong2.LatLng(1.308, 103.930)),
    ];
  }
}

class MapService {
  PlaceMap? placeMap;
  List<Level> availableLevels = [];
  PoiManager? poiManager;

  Future<void> loadMap(int placeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    placeMap = PlaceMap(placeId, "Mall Map");
    availableLevels = [Level("1", "Level 1"), Level("2", "Level 2")];
    poiManager = PoiManager();
  }

  List<Poi> getPoisForLevel(Level level) =>
      [Poi(1, "Restroom"), Poi(2, "Exit")];

  List<MapWay> getRoutesForLevel(Level level) =>
      [MapWay("Route-${level.id}")];

  Future<MapRoute?> findRoute(int startPoiId, int endPoiId) async =>
      MapRoute("Route-$startPoiId-$endPoiId");

  void dispose() {
    placeMap = null;
    availableLevels = [];
    poiManager = null;
  }
}

class PoiManager {}

// ======= Repositories =======
class PlacesRepository {
  final PlacesDataSource placesDataSource;
  PlacesRepository({required this.placesDataSource});

  Future<List<Place>> getPlaces(latlong2.LatLng center,
      {double maxDistance = 500.0, int limit = 10}) async {
    return await placesDataSource.getPlaces(center,
        maxDistance: maxDistance, limit: limit);
  }
}

class MapRepository {
  final MapService _mapService;
  MapRepository(this._mapService);

  Future<void> loadMap(int placeId) async {
    await _mapService.loadMap(placeId);
  }

  PlaceMap? get placeMap => _mapService.placeMap;
  PoiManager? get poiManager => _mapService.poiManager;
  List<Level> get availableLevels => _mapService.availableLevels;
  List<Poi> getPoisForLevel(Level level) => _mapService.getPoisForLevel(level);
  List<MapWay> getRoutesForLevel(Level level) =>
      _mapService.getRoutesForLevel(level);
  Future<MapRoute?> findRoute(int startPoiId, int endPoiId) =>
      _mapService.findRoute(startPoiId, endPoiId);

  void dispose() => _mapService.dispose();
}

// ======= Providers =======
final placesRepositoryProvider = Provider(
  (ref) => PlacesRepository(placesDataSource: PlacesDataSource()),
);

final mapRepositoryProvider = Provider((ref) => MapRepository(MapService()));

final nearestPlaceProvider =
    FutureProvider.family<Place?, latlong2.LatLng>((ref, center) async {
  final repo = ref.watch(placesRepositoryProvider);
  final places = await repo.getPlaces(center);
  return places.isNotEmpty ? places.first : null;
});

final mapLoaderProvider =
    FutureProvider.family<PlaceMap?, Place>((ref, place) async {
  final repo = ref.watch(mapRepositoryProvider);
  await repo.loadMap(place.id);
  return repo.placeMap;
});

// ======= App UI =======
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Nav Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simulate device position
    final userPos = latlong2.LatLng(1.307, 103.929);

    final nearestPlaceAsync = ref.watch(nearestPlaceProvider(userPos));

    return Scaffold(
      appBar: AppBar(title: const Text("Indoor Nav App")),
      body: nearestPlaceAsync.when(
        data: (place) {
          if (place == null) return const Center(child: Text("No nearby place"));
          final mapAsync = ref.watch(mapLoaderProvider(place));
          return mapAsync.when(
            data: (placeMap) {
              if (placeMap == null) {
                return const Center(child: Text("Failed to load map"));
              }
              return MapView(placeMap: placeMap);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error loading map: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error finding place: $e")),
      ),
    );
  }
}

class MapView extends ConsumerWidget {
  final PlaceMap placeMap;
  const MapView({super.key, required this.placeMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapRepo = ref.watch(mapRepositoryProvider);

    return Column(
      children: [
        Text("Map of ${placeMap.name}", style: Theme.of(context).textTheme.headline6),
        Expanded(
          child: ListView(
            children: [
              Text("Levels: ${mapRepo.availableLevels.map((l) => l.name).join(', ')}"),
              Text("POIs: ${mapRepo.getPoisForLevel(mapRepo.availableLevels.first).map((p) => p.name).join(', ')}"),
            ],
          ),
        ),
      ],
    );
  }
}


```
