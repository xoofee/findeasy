// /*
// Service = low-level implementation (engine/library).
// Repository = app-facing abstraction (stable API for presentation).

// Presentation layer should call the repository — the service is called inside the repo.
// */

// import 'package:easyroute/easyroute.dart';

// /// Repository for map operations
// class MapRepository {
//   final PlaceMapDataSource _dataSource;
//   EasyRoute? _easyRoute;
//   PlaceMap? _placeMap;
//   PoiManager? _poiManager;

//   MapRepository(this._dataSource);


//   /// Load map data for a specific place
//   Future<void> loadMap(int placeId) async {
//     try {
//       // Download map file
//       final mapFilePath = await _dataSource.downloadMap(placeId);
      
//       // Load map using EasyRoute
//       final mapResult = await loadMapFromOsmFile(mapFilePath);
      
//       _placeMap = mapResult.placeMap;
//       _poiManager = mapResult.poiManager;
      
//       // Initialize EasyRoute
//       _easyRoute = EasyRoute();
//       await _easyRoute!.init(mapResult);
//     } catch (e) {
//       throw Exception('Failed to load map: $e');
//     }
//   }

//   /// Get the loaded place map
//   PlaceMap? get placeMap => _placeMap;

//   /// Get the loaded POI manager
//   PoiManager? get poiManager => _poiManager;

//   /// Find a route between two POIs
//   Future<MapRoute> findRoute(int startPoiId, int endPoiId) async {
//     if (_easyRoute == null) throw Exception('EasyRoute not initialized');
    
//     try {
//       return await _easyRoute!.findPathBetweenPois(
//         startPoiId: startPoiId,
//         endPoiId: endPoiId,
//       );
//     } catch (e) {
//       throw Exception('Failed to find route: $e');
//     }
//   }

//   /// Dispose resources
//   void dispose() {
//     _easyRoute = null;
//     _placeMap = null;
//     _poiManager = null;
//   }

// }