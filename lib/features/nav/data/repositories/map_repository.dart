import 'package:findeasy/features/nav/data/services/map_service.dart';
import 'package:easyroute/easyroute.dart';

/// Repository for map operations
class MapRepository {
  final MapService _mapService;

  MapRepository(this._mapService);

  /// Load map for a specific place
  Future<void> loadMap(int placeId) async {
    await _mapService.loadMap(placeId);
  }

  /// Get the loaded place map
  PlaceMap? get placeMap => _mapService.placeMap;

  /// Get the loaded POI manager
  PoiManager? get poiManager => _mapService.poiManager;

  /// Get available levels
  List<Level> get availableLevels => _mapService.availableLevels;

  /// Get POIs for a specific level
  List<Poi> getPoisForLevel(Level level) => _mapService.getPoisForLevel(level);

  /// Get routes for a specific level
  List<MapWay> getRoutesForLevel(Level level) => _mapService.getRoutesForLevel(level);

  /// Find a route between two POIs
  Future<MapRoute?> findRoute(int startPoiId, int endPoiId) => _mapService.findRoute(startPoiId, endPoiId);

  /// Dispose resources
  void dispose() {
    _mapService.dispose();
  }
}