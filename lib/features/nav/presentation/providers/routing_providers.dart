import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

// ======= Route Planning Providers =======

final easyRouteProvider = Provider<EasyRoute?>((ref) {
  final mapResult = ref.watch(placeMapProvider).valueOrNull;    // TODO: how to do with error?

  if (mapResult == null) return null;  
  
  final easyRoute = EasyRoute();
  try {
    easyRoute.init(mapResult);
    return easyRoute;
  } catch (e) {
    // Log initialization failures
    if (e is EasyRouteException) {
      print('Failed to initialize routing: ${e.message}');
    } else {
      print('Unexpected error during routing initialization: $e');
    }
    return null;
  }
});

final originPoiProvider = StateProvider<Poi?>((ref) => null);
final destinationPoiProvider = StateProvider<Poi?>((ref) => null);

/// Provider that computes the route between origin and destination POIs.
/// Returns null when:
/// - Origin or destination POI is not selected
/// - EasyRoute is not initialized
/// - No valid route exists between the POIs
/// - An unexpected error occurs during routing
final routeProvider = Provider<MapRoute?>((ref) {
  final originPoi = ref.watch(originPoiProvider);
  final destinationPoi = ref.watch(destinationPoiProvider);
  if (originPoi == null || destinationPoi == null) return null;

  final easyRoute = ref.read(easyRouteProvider);
  if (easyRoute == null) return null;

  try {
    return easyRoute.findPathBetweenPois(originPoi: originPoi, destinationPoi: destinationPoi);
  } catch (e) {
    // Distinguish between expected routing failures and unexpected errors
    if (e is EasyRouteException) {
      // Expected routing failures (e.g., no path found, POIs too far apart)
      // Log as info/warning, not error
      print('Routing failed: ${e.message}');
      return null;
    } else {
      // Unexpected errors (e.g., system failures, bugs)
      // Log as error and potentially re-throw for debugging
      print('Unexpected error during routing: $e');
      // TODO: Add proper error logging service
      // TODO: Consider re-throwing unexpected errors in debug mode
      return null;
    }
  }
});

final poiLandMarksProvider = Provider<List<Poi>>((ref) {
  final route = ref.watch(routeProvider);
  if (route == null) return [];
  final currentLevel = ref.watch(currentLevelProvider);

  final poiLandMarks = route.instructions.map((instruction) => instruction.poiLandmarks).where((poi) => poi != null && poi.level == currentLevel).cast<Poi>().toList();
  return poiLandMarks;
});

// /// Provider for the MapRepository
// final mapRepositoryProvider = Provider<MapRepository>((ref) {
//   final dataSource = ref.read(assetDataSourceProvider);
//   return MapRepository(dataSource);
// });

// /// Provider for finding routes between POIs
// final routeBetweenPoisProvider = FutureProvider.family<MapRoute, ({
//   Poi startPoi,
//   Poi endPoi,
//   double maxProjectionDistance,
// })>((ref, params) async {
//   final repository = ref.read(mapRepositoryProvider);
  
//   // Ensure the repository is initialized (you might want to handle this differently)
//   if (!repository.isRoutingAvailable) {
//     throw Exception('Map repository not initialized. Load a map first.');
//   }
  
//   return await repository.findRouteBetweenPois(
//     startPoi: params.startPoi,
//     endPoi: params.endPoi,
//     maxProjectionDistance: params.maxProjectionDistance,
//   );
// });

// /// Provider for finding routes between POI IDs
// final routeByPoiIdsProvider = FutureProvider.family<MapRoute, ({
//   int startPoiId,
//   int endPoiId,
//   double maxProjectionDistance,
// })>((ref, params) async {
//   final repository = ref.read(mapRepositoryProvider);
  
//   if (!repository.isRoutingAvailable) {
//     throw Exception('Map repository not initialized. Load a map first.');
//   }
  
//   return await repository.findRouteByPoiIds(
//     params.startPoiId,
//     params.endPoiId,
//     maxProjectionDistance: params.maxProjectionDistance,
//   );
// });

// /// Provider for finding routes between arbitrary points
// final routeBetweenPointsProvider = FutureProvider.family<MapRoute, ({
//   latlong2.LatLng startPoint,
//   double startLevel,
//   latlong2.LatLng endPoint,
//   double endLevel,
//   double maxProjectionDistance,
// })>((ref, params) async {
//   final repository = ref.read(mapRepositoryProvider);
  
//   if (!repository.isRoutingAvailable) {
//     throw Exception('Map repository not initialized. Load a map first.');
//   }
  
//   return await repository.findRouteBetweenPoints(
//     startPoint: params.startPoint,
//     startLevel: params.startLevel,
//     endPoint: params.endPoint,
//     endLevel: params.endLevel,
//     maxProjectionDistance: params.maxProjectionDistance,
//   );
// });

// /// Provider to check if routing is available
// final isRoutingAvailableProvider = Provider<bool>((ref) {
//   final repository = ref.read(mapRepositoryProvider);
//   return repository.isRoutingAvailable;
// });

// // ======= Helper Functions =======

// /// Find route between two POIs
// Future<MapRoute> findRouteBetweenPois(
//   WidgetRef ref, {
//   required Poi startPoi,
//   required Poi endPoi,
//   double maxProjectionDistance = 50.0,
// }) async {
//   final repository = ref.read(mapRepositoryProvider);
//   return await repository.findRouteBetweenPois(
//     startPoi: startPoi,
//     endPoi: endPoi,
//     maxProjectionDistance: maxProjectionDistance,
//   );
// }

// /// Find route between two POI IDs
// Future<MapRoute> findRouteByPoiIds(
//   WidgetRef ref, {
//   required int startPoiId,
//   required int endPoiId,
//   double maxProjectionDistance = 50.0,
// }) async {
//   final repository = ref.read(mapRepositoryProvider);
//   return await repository.findRouteByPoiIds(
//     startPoiId,
//     endPoiId,
//     maxProjectionDistance: maxProjectionDistance,
//   );
// }

// /// Find route between arbitrary points
// Future<MapRoute> findRouteBetweenPoints(
//   WidgetRef ref, {
//   required latlong2.LatLng startPoint,
//   required double startLevel,
//   required latlong2.LatLng endPoint,
//   required double endLevel,
//   double maxProjectionDistance = 50.0,
// }) async {
//   final repository = ref.read(mapRepositoryProvider);
//   return await repository.findRouteBetweenPoints(
//     startPoint: startPoint,
//     startLevel: startLevel,
//     endPoint: endPoint,
//     endLevel: endLevel,
//     maxProjectionDistance: maxProjectionDistance,
//   );
// }
