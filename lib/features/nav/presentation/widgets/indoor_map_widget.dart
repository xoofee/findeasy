import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';
import 'package:findeasy/features/nav/presentation/widgets/car_parking_dialog.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

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
    final asyncMapResult = ref.watch(placeMapProvider).valueOrNull;   // reactive data stream rather than a single future callback.

    final placeMap = asyncMapResult?.placeMap;
    final placePosition = placeMap?.position;
    final poiManager = asyncMapResult?.poiManager;

    final currentLevel = ref.watch(currentLevelProvider);


    // Listen for placeMap changes and animate to new position
    ref.listen<AsyncValue<MapResult?>>(placeMapProvider, (previous, next) {
      final previousPlaceMap = previous?.valueOrNull?.placeMap;
      final nextPlaceMap = next.valueOrNull?.placeMap;
      
      if (nextPlaceMap != null && nextPlaceMap != previousPlaceMap) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animatedMapController.animateTo(
            dest: nextPlaceMap.position, 
          );
        });
      }
    });

    // Build POI markers
    // _buildPoiMarkers(pois, selectedPoi);
    
    // Build POI polygons (for way-based POIs)
    if (currentLevel != null && placeMap != null && placeMap.levelMaps.containsKey(currentLevel)) {
      _poiPolygons.clear();
      // _parkingSpaceNameMarkers.clear();
      final parkingSpaces = placeMap.levelMaps[currentLevel]!.parkingSpaces;
      _poiPolygons.addAll(parkingSpaces.toPolygons(Colors.blue, Colors.blue));
      _parkingSpaceNameMarkers = parkingSpaces.toTextMarkers();

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   _animatedMapController.animateTo(
      //     dest: placeMap.position, 
      //   );
      // });
    }
    
    // Build route lines
    // _buildRouteLines(routes, routeGeometry);

    return FlutterMap(
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
        // POI Markers - only show at high zoom levels
        // ZoomDependentMarkers(
        //   markers: _parkingSpaceNameMarkers,
        // ),

        Consumer( builder: (context, ref, child) {  // avoid writing a separate ConsumerWidget for this
          final mapZoom = ref.watch(mapZoomProvider);
          if (mapZoom > 20.0) return MarkerLayer(markers: _parkingSpaceNameMarkers, rotate: true);
          return const SizedBox.shrink();
        }),

        // POI Polygons: parking spaces
        PolygonLayer(polygons: _poiPolygons),
        // Route Lines
        PolylineLayer(polylines: _routeLines),

        // Car parking marker
        Consumer( builder: (context, ref, child) {
          final carParkingInfo = ref.watch(carParkingInfoProvider);

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car,
                    color: isCarParkedAtCurrentLevel 
                        ? Colors.red.withOpacity(0.8) 
                        : Colors.red.withOpacity(0.3),
                    size: 32,
                  ),
                  if (!isCarParkedAtCurrentLevel)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      ),
                      child: Text(
                        'at ${currentLevel.displayName}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              rotate: true,
            ),
          ], rotate: true);
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

extension on List<Poi> {
  List<Polygon> toPolygons(Color color, Color borderColor, {double borderStrokeWidth = 2}) {
    return where((poi) => poi.geometry != null)
      .map((poi) => Polygon(
            points: poi.geometry!,
            color: color.withOpacity(0.3),
            borderColor: borderColor,
            borderStrokeWidth: borderStrokeWidth,
          ))
      .toList();
  }

  List<Marker> toTextMarkers() {
    return map((poi) => Marker(
            point: poi.center,
            child: Text(poi.name, textAlign: TextAlign.center),
            width: 60,
          ))
      .toList();
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