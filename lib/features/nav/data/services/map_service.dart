import 'dart:io';
import 'dart:typed_data';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/map/data/datasources/place_map_data_source.dart';

/// Service for loading and managing map data using EasyRoute
class MapService {
  final PlaceMapDataSource _dataSource;
  EasyRoute? _easyRoute;
  PlaceMap? _placeMap;
  PoiManager? _poiManager;

  MapService(this._dataSource);

  /// Load map data for a specific place
  Future<void> loadMap(int placeId) async {
    try {
      // Download map file
      final mapFilePath = await _dataSource.downloadMap(placeId);
      
      // Load map using EasyRoute
      final (placeMap, poiManager) = await loadMapFromOsmFile(mapFilePath);
      
      _placeMap = placeMap;
      _poiManager = poiManager;
      
      // Initialize EasyRoute
      _easyRoute = EasyRoute();
      await _easyRoute!.init(placeMap, poiManager);
    } catch (e) {
      throw Exception('Failed to load map: $e');
    }
  }

  /// Get the loaded place map
  PlaceMap? get placeMap => _placeMap;

  /// Get the loaded POI manager
  PoiManager? get poiManager => _poiManager;

  /// Get available levels
  List<Level> get availableLevels {
    if (_placeMap == null) return [];
    return _placeMap!.levelMaps.keys.toList()..sort();
  }

  /// Get POIs for a specific level
  List<Poi> getPoisForLevel(Level level) {
    if (_placeMap == null) return [];
    
    final levelMap = _placeMap!.levelMaps[level];
    if (levelMap == null) return [];
    
    return [
      ...levelMap.parkingSpaces,
      ...levelMap.elevators,
      ...levelMap.shops,
    ];
  }

  /// Get routes for a specific level
  List<MapWay> getRoutesForLevel(Level level) {
    if (_placeMap == null) return [];
    
    final levelMap = _placeMap!.levelMaps[level];
    if (levelMap == null) return [];
    
    return levelMap.routes.where((route) => route.levels.contains(level)).toList();
  }

  /// Find a route between two POIs
  Future<MapRoute> findRoute(int startPoiId, int endPoiId) async {
    if (_easyRoute == null) throw Exception('EasyRoute not initialized');
    
    try {
      return await _easyRoute!.findPathBetweenPois(
        startPoiId: startPoiId,
        endPoiId: endPoiId,
      );
    } catch (e) {
      throw Exception('Failed to find route: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _easyRoute = null;
    _placeMap = null;
    _poiManager = null;
  }
}