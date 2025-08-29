import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/nav/presentation/providers/routing_providers.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';
import 'package:findeasy/features/nav/presentation/widgets/car_parking_dialog.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:findeasy/features/nav/presentation/providers/map_animation_provider.dart';
import 'package:latlong2/latlong.dart' as latlong2;
// import 'package:findeasy/features/nav/presentation/widgets/map_controls_widget.dart';

final mapResult = ref.watch(placeMapProvider.select((async) => async.value!));

/// Main indoor map widget using flutter_map
class IndoorMapWidget extends ConsumerStatefulWidget {
  const IndoorMapWidget({super.key});

  @override
  ConsumerState<IndoorMapWidget> createState() => _IndoorMapWidgetState();
}

class _IndoorMapWidgetState extends ConsumerState<IndoorMapWidget> with TickerProviderStateMixin{
  late AnimatedMapController _animatedMapController;

  // late MapController _mapController;
  late List<Marker> _parkingSpaceNameMarkers;
  late List<Polygon> _poiPolygons;
  late List<Polyline> _routeLines;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);

    // _mapController = MapController();
    _parkingSpaceNameMarkers = [];
    _poiPolygons = [];
    _routeLines = [];
  }

  @override
  Widget build(BuildContext context) {
    // Provide the AnimatedMapController to the provider system
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the map animation service instead of direct controller access
        ref.read(animatedMapControllerProvider.notifier).state = _animatedMapController;
    });
    
    final asyncMapResult = ref.watch(placeMapProvider).valueOrNull;   // reactive data stream rather than a single future callback.

    final placeMap = asyncMapResult?.placeMap;
    final placePosition = placeMap?.position;
    final poiManager = asyncMapResult?.poiManager;

    final placeMatched = ref.watch(placeMatchedProvider.notifier).state;


    // Listen for placeMap changes and animate to new position using the service
    ref.listen<AsyncValue<MapResult?>>(placeMapProvider, (previous, next) {
      final previousPlaceMap = previous?.valueOrNull?.placeMap;
      final nextPlaceMap = next.valueOrNull?.placeMap;
      
      if (nextPlaceMap != null && nextPlaceMap != previousPlaceMap) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Use the map animation service instead of direct controller access
          ref.read(mapAnimationProvider.notifier).animateToPlace(
            nextPlaceMap.position,
          );
        });
      }
    });

    // Build POI markers
    // _buildPoiMarkers(pois, selectedPoi);

    
    // Build route lines
    // _buildRouteLines(routes, routeGeometry);

    return 
        FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: placePosition ?? AppConstants.defaultMapCenter,
            initialZoom: 18.0,
            maxZoom: 22.0,
            minZoom: 16.0,
            onPositionChanged: (MapCamera camera, bool hasGesture) {
              ref.read(mapZoomProvider.notifier).state = camera.zoom;
            },           

        // onMapReady: () => _onMapReady(placeMap),
      ),
      children: [
        // Base tile layer (outdoor map)
        TileLayer(
          urlTemplate: 'https://{s}.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=0e224c51130f44f59a53672538a958f6',
          subdomains: const ['a', 'b', 'c'],),


        // POI Polygons: parking spaces

        // if (placeMatched) ...[PolygonLayer(polygons: _poiPolygons),
        // // Route Lines
        // // PolylineLayer(polylines: _routeLines),

        // _buildCarParkingMarker(placeMap, poiManager, currentLevel),
        // ],

        Consumer( builder: (context, ref, child) {
          final routeKeyPoints = ref.watch(routeKeyPointsProvider);
          return MarkerLayer(markers: routeKeyPoints.toPointMarkers());
        }),

        if (placeMatched && placeMap != null) ...[
          Consumer( builder: (context, ref, child) {

            final currentLevel = ref.watch(currentLevelProvider);
            final poiLandMarks = ref.watch(poiLandMarksProvider);

            // Build POI polygons (for way-based POIs)
            if (currentLevel != null && placeMap.levelMaps.containsKey(currentLevel)) {
              _poiPolygons.clear();
              // _parkingSpaceNameMarkers.clear();
              final parkingSpaces = placeMap.levelMaps[currentLevel]!.parkingSpaces;
              _poiPolygons.addAll(parkingSpaces.toPolygons(Colors.blue, Colors.blue, poiLandMarks: poiLandMarks));

              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   _animatedMapController.animateTo(
              //     dest: placeMap.position, 
              //   );
              // });
              return PolygonLayer(polygons: _poiPolygons);
            } else {
              return const SizedBox.shrink();
            }
          }),
          Consumer( builder: (context, ref, child) {
            final currentLevel = ref.watch(currentLevelProvider);
            return _buildCarParkingMarker(placeMap, poiManager, currentLevel);
          }),
        ],
        // a hack to set the current level to the origin level of the route
        Consumer( builder: (context, ref, child) {  // avoid writing a separate ConsumerWidget for this
          final route = ref.watch(routeProvider);
          if (route == null) return const SizedBox.shrink();
          WidgetsBinding.instance.addPostFrameCallback((_) {  // without this will cause error
            ref.read(currentLevelProvider.notifier).setLevel(route.originLevel);
          });
          return const SizedBox.shrink();
        }),

        Consumer( builder: (context, ref, child) {  // avoid writing a separate ConsumerWidget for this
          final route = ref.watch(routeProvider);
          if (route == null) return const SizedBox.shrink();

          // do not consider multiple level changes: only change once at most, for now.
          if (route.hasLevelChange) {
            final currentLevel = ref.watch(currentLevelProvider);
            final highlightOriginLevel = currentLevel == route.originLevel;

            final highlightGeometry = highlightOriginLevel ? route.geometryAtOriginLevel : route.geometryAtDestinationLevel;
            final nonHighlightGeometry = highlightOriginLevel ? route.geometryAtDestinationLevel : route.geometryAtOriginLevel;
                        
            return PolylineLayer(polylines: [
              Polyline(points: highlightGeometry!.toLatLngList(), color: Colors.orange, strokeWidth: 4),
              Polyline(points: nonHighlightGeometry!.toLatLngList(), color:  Colors.orange.withOpacity(0.6), strokeWidth: 3, pattern: StrokePattern.dashed(segments: [4, 6])),
            ]);
          }

          return PolylineLayer(polylines: [Polyline(points: route.geometry.toLatLngList(), color: Colors.orange, strokeWidth: 4)]);
        }),

        // POI Markers - only show at high zoom levels
        // ZoomDependentMarkers(
        //   markers: _parkingSpaceNameMarkers,
        // ),
        if (placeMatched && placeMap != null) 
          Consumer( builder: (context, ref, child) {  // avoid writing a separate ConsumerWidget for this
            final mapZoom = ref.watch(mapZoomProvider);
            final currentLevel = ref.watch(currentLevelProvider);

            final parkingSpaces = placeMap.levelMaps[currentLevel]!.parkingSpaces;

            final poiLandMarks = ref.watch(poiLandMarksProvider);

            
            if (mapZoom > 20.0) {
              _parkingSpaceNameMarkers = parkingSpaces.toTextMarkers(poiLandMarks);
              return MarkerLayer(markers: _parkingSpaceNameMarkers, rotate: true);
            } else {
              return MarkerLayer(markers: poiLandMarks.toLandMarkTexts(), rotate: true);

            }
          }),        
      ],
    );

  }

  // void _onMapReady(PlaceMap? placeMap) {
  //   // Center map on the place
  //   if (placeMap != null) _mapController.move(placeMap.position, 18.0);
  // }

  // void _onPoiTap(Poi poi) {
  //   ref.read(selectedPoiProvider.notifier).state = poi;
  // }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }
}

Widget _buildCarParkingMarker(PlaceMap? placeMap, PoiManager? poiManager, Level? currentLevel) {

  // Car parking marker
  return Consumer( builder: (context, ref, child) {  // avoid writing a separate ConsumerWidget for this
    final carParkingInfo = ref.watch(carParkingInfoNotifierProvider);

    if (placeMap == null || poiManager == null || currentLevel == null || carParkingInfo == null) return const SizedBox.shrink();

    final carParkingPoi = poiManager.findPoiByName(carParkingInfo.parkingSpaceName);
    
    if (carParkingPoi == null) return const SizedBox.shrink();
    
    // Check if car is parked at current place and level
    final isCarParkedHere =  carParkingInfo.placeId == placeMap.id &&
                            carParkingInfo.parkingSpaceName == carParkingPoi.name;

    final isCarParkedAtCurrentLevel = carParkingInfo.levelNumber == currentLevel.value && 
                                    carParkingPoi.level == currentLevel;

    if (!isCarParkedHere) return const SizedBox.shrink();
                                      
    return MarkerLayer(markers: [
      Marker(
        point: carParkingPoi.position,
        alignment: Alignment.center,
        height: isCarParkedAtCurrentLevel? 32 : 46,
        // child:                   Icon(
        //       Icons.directions_car,
        //       color: isCarParkedAtCurrentLevel 
        //           ? Colors.red.withOpacity(0.8) 
        //           : Colors.red.withOpacity(0.3),
        //       size: 32,
        //     ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car,
              color: isCarParkedAtCurrentLevel 
                  ? Colors.red.withOpacity(1.0) 
                  : Colors.red.withOpacity(0.5),
              size: 32,
            ),
            if (!isCarParkedAtCurrentLevel)  Text(
                  'at ${currentLevel.displayName}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

          ],
        ),
        rotate: true,
      ),
    ], rotate: true);
  });  
}


extension on List<Poi> {
  List<Polygon> toPolygons(Color color, Color borderColor, {double borderStrokeWidth = 1.5, required List<Poi> poiLandMarks}) {
    return where((poi) => poi.geometry != null)
      .map((poi) {
        if (poiLandMarks.contains(poi)) {
          return Polygon(
            points: poi.geometry!,
            color: Colors.red.withOpacity(0.5),
            borderColor: Colors.red,
            borderStrokeWidth: 2.0,
            // make it dashed
            // pattern: StrokePattern.dashed(segments: [2, 4]),
          );
        } else {
        return Polygon(
            points: poi.geometry!,
            // color: color.withOpacity(0.3),
            color: Colors.transparent,
            borderColor: borderColor,
            borderStrokeWidth: borderStrokeWidth,
          );
        }
      })
      .toList();
  }

  List<Marker> toLandMarkTexts() {

    return map((poi) => Marker(
          point: poi.center,
          child: Text(poi.name, textAlign: TextAlign.center, style: AppConstants.landmarkTextStyle),
          width: 60,
        ))
    .toList();
  }    

  List<Marker> toTextMarkers(List<Poi> poiLandMarks) {
    return map((poi) {
      if (poiLandMarks.contains(poi)) {
        return Marker(
          point: poi.center,
          child: Text(poi.name, textAlign: TextAlign.center, style: AppConstants.landmarkTextStyle),
          width: 60,
        );
      } else {
        return Marker(
          point: poi.center,
          child: Text(poi.name, textAlign: TextAlign.center),
          width: 60,
        );
      }
    }).toList();
  }  
}

extension on List<latlong2.LatLng> {
  List<Marker> toPointMarkers({double size = 12}) {
    // circle marker
    return map(
      (point) => Marker(
        point: point,
        width: size,   // control dot size
        height: size,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ).toList();
  }
}

// void _buildPoiMarkers(List<Poi> pois) {
//   _poiMarkers = pois
//     .where((poi) => poi.geometry == null) // Only point-based POIs
//     .map((poi) => Marker(
//             point: poi.center,
//             child: Text(poi.name, textAlign: TextAlign.center),
//             width: 60,
//         ))
//     .toList();
// }



/*




  void _buildPoiMarkers(List<Poi> pois) {
    _poiMarkers = pois
      .where((poi) => poi.geometry == null) // Only point-based POIs
      .map((poi) => Marker(
            point: poi.position,
            width: 30,
            height: 30,
            child: PoiMarkerWidget(
              poi: poi,
              // onTap: () => _onPoiTap(poi),
              showLabel: true,
            ),
          ))
      .toList();
  }

  void _buildRouteLines(List<MapWay> routes, List<LatLng> routeGeometry) {
    _routeLines = [];
    
    // Add route geometry if available
    if (routeGeometry.isNotEmpty) {
      _routeLines.add(Polyline(
        points: routeGeometry,
        color: Colors.blue,
        strokeWidth: 4,
      ));
    }
    
    // Add building routes
    for (final route in routes) {
      if (route.nodes.isNotEmpty) {
        final points = route.nodes.map((node) => node.position).toList();
        _routeLines.add(Polyline(
          points: points,
          color: Colors.grey.withOpacity(0.5),
          strokeWidth: 2,
        ));
      }
    }
  }

  Color _getPoiPolygonColor(String type) {
    if (type.contains('parking_space')) return Colors.blue;
    if (type.contains('shop')) return Colors.purple;
    if (type.contains('restaurant')) return Colors.red;
    if (type.contains('cafe')) return Colors.brown;
    return Colors.grey;
  }


*/