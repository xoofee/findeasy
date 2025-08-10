I'll analyze the current architecture and folder structure to understand how the easyroute package can be integrated with the findeasy app for map and navigation features. Let me examine the relevant code and structure.

Read file: library/easyroute/lib/easyroute.dart
Read file: library/easyroute/lib/src/easyroute_api.dart
Read file: app/findeasy/lib/features/map/data/models/
Ran tool
Ran tool
Ran tool
Ran tool
Read file: app/findeasy/lib/features/nav/data/datasources/
Ran tool
Ran tool
Read file: app/findeasy/pubspec.yaml
Search files...
Search files...
Ran tool
Search files...
Ran tool
Read file: app/findeasy/lib/features/nav/presentation/pages/
Ran tool
Ran tool
Read file: app/findeasy/lib/main.dart
Read file: app/findeasy/lib/app.dart
Read file: library/easyroute/lib/src/data/models/poi.dart
Read file: library/easyroute/lib/src/data/models/osm_way.dart
Based on my analysis of the current architecture and the easyroute package capabilities, I can provide recommendations for optimizing the architecture and folder structure to better integrate easyroute with the findeasy app for map and navigation features.

## Current State Analysis

The easyroute package provides:
- **OSM parsing** (.osm.gz files)
- **Graph building** for routing
- **POI management** (points and polygons)
- **Pathfinding** with detailed geometry
- **Navigation instructions**

The findeasy app currently has:
- **flutter_map** dependency for map visualization
- **Empty map/nav feature folders** (need implementation)
- **Clean architecture structure** with domain/data/presentation layers

## Recommended Architecture Optimization

### 1. **Enhanced Data Layer Structure**

```
app/findeasy/lib/features/
├── map/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local_osm_datasource.dart      # OSM file loading
│   │   │   ├── map_cache_datasource.dart      # Cached map data
│   │   │   └── remote_map_datasource.dart     # Future: remote map data
│   │   ├── models/
│   │   │   ├── map_data.dart                  # Unified map data structure
│   │   │   ├── map_layer.dart                 # Layer definitions
│   │   │   ├── map_poi.dart                   # POI for map display
│   │   │   ├── map_polygon.dart               # Polygon features
│   │   │   └── map_route.dart                 # Route visualization
│   │   └── repositories/
│   │       └── map_repository.dart
├── nav/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── easyroute_datasource.dart      # EasyRoute integration
│   │   │   └── navigation_cache_datasource.dart
│   │   ├── models/
│   │   │   ├── navigation_request.dart
│   │   │   ├── navigation_route.dart
│   │   │   └── navigation_instruction.dart
│   │   └── repositories/
│   │       └── navigation_repository.dart
```

### 2. **Unified Map Data Structure**

Create a unified data structure that bridges easyroute's internal models with flutter_map requirements:

```dart
// app/findeasy/lib/features/map/data/models/map_data.dart
class MapData {
  final List<MapPoi> pois;
  final List<MapPolygon> polygons;
  final List<MapRoute> routes;
  final MapBounds bounds;
  final List<Level> levels;
}

class MapPoi {
  final int id;
  final String name;
  final LatLng position;
  final String type;
  final Level level;
  final Map<String, String> tags;
  final bool isGraphNode;
  final double? heading;
  
  // flutter_map specific
  final String? iconPath;
  final Color? color;
  final String? popupContent;
}

class MapPolygon {
  final int id;
  final List<LatLng> coordinates;
  final String type;
  final Level level;
  final Map<String, String> tags;
  
  // flutter_map specific
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
}
```

### 3. **Service Layer for EasyRoute Integration**

```dart
// app/findeasy/lib/features/nav/data/services/easyroute_service.dart
class EasyRouteService {
  final EasyRoute _easyRoute = EasyRoute();
  
  Future<MapData> loadMapData(String osmFilePath) async {
    await _easyRoute.loadFromOsmFile(osmFilePath: osmFilePath);
    
    return MapData(
      pois: _convertPoisToMapPois(_easyRoute.poiManager.pois),
      polygons: _extractPolygons(_easyRoute.graph),
      routes: [],
      bounds: _easyRoute.getGraphBounds(),
      levels: _easyRoute.getAvailableLevels(),
    );
  }
  
  Future<NavigationRoute> findRoute({
    required LatLng start,
    required Level startLevel,
    required LatLng end,
    required Level endLevel,
  }) async {
    final result = await _easyRoute.findPath(
      startPoint: start,
      startLevel: startLevel,
      endPoint: end,
      endLevel: endLevel,
    );
    
    return NavigationRoute.fromEasyRouteResult(result);
  }
}
```

### 4. **Map Widget Implementation**

```dart
// app/findeasy/lib/features/map/presentation/widgets/indoor_map_widget.dart
class IndoorMapWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapData = ref.watch(mapDataProvider);
    final currentLevel = ref.watch(currentLevelProvider);
    
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: mapData.bounds.center,
        zoom: 18.0,
        maxZoom: 20.0,
        minZoom: 16.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        // POI Markers
        MarkerLayer(
          markers: mapData.pois
              .where((poi) => poi.level == currentLevel)
              .map((poi) => _buildPoiMarker(poi))
              .toList(),
        ),
        // Polygon Features
        PolygonLayer(
          polygons: mapData.polygons
              .where((poly) => poly.level == currentLevel)
              .map((poly) => _buildPolygon(poly))
              .toList(),
        ),
        // Route Layer
        PolylineLayer(
          polylines: mapData.routes
              .where((route) => route.level == currentLevel)
              .map((route) => _buildRoutePolyline(route))
              .toList(),
        ),
      ],
    );
  }
}
```

### 5. **Dependency Injection Setup**

```dart
// app/findeasy/lib/di/map_injection.dart
class MapInjection {
  static void setup() {
    GetIt.instance.registerLazySingleton<EasyRouteService>(
      () => EasyRouteService(),
    );
    
    GetIt.instance.registerLazySingleton<MapRepository>(
      () => MapRepository(
        localDataSource: GetIt.instance<LocalOsmDataSource>(),
        cacheDataSource: GetIt.instance<MapCacheDataSource>(),
      ),
    );
    
    GetIt.instance.registerLazySingleton<NavigationRepository>(
      () => NavigationRepository(
        easyRouteDataSource: GetIt.instance<EasyRouteDataSource>(),
      ),
    );
  }
}
```

### 6. **State Management with Riverpod**

```dart
// app/findeasy/lib/features/map/presentation/providers/map_providers.dart
final mapDataProvider = FutureProvider<MapData>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  return await repository.loadMapData();
});

final currentLevelProvider = StateProvider<Level>((ref) => Level(0));

final selectedPoiProvider = StateProvider<Poi?>((ref) => null);

final navigationRouteProvider = FutureProvider.family<NavigationRoute, NavigationRequest>(
  (ref, request) async {
    final repository = ref.read(navigationRepositoryProvider);
    return await repository.findRoute(request);
  },
);
```

## Key Benefits of This Architecture

1. **Separation of Concerns**: Map visualization (flutter_map) is separate from navigation logic (easyroute)
2. **Reusable Components**: Map data structures can be used by both map and navigation features
3. **Testability**: Each layer can be tested independently
4. **Scalability**: Easy to add new map layers, POI types, or navigation features
5. **Performance**: Caching layer for map data and navigation results
6. **Maintainability**: Clear data flow from easyroute → service layer → repository → UI

## Implementation Priority

1. **Phase 1**: Implement basic map data structures and EasyRoute service
2. **Phase 2**: Create flutter_map integration with POI markers and polygons
3. **Phase 3**: Add navigation routing with route visualization
4. **Phase 4**: Implement caching and performance optimizations

This architecture provides a clean separation between the easyroute package's routing capabilities and the flutter_map visualization requirements, while maintaining a unified data structure that both features can use effectively.