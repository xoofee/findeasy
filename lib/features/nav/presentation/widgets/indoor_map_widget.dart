import 'package:findeasy/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_marker_widget.dart';

/// Main indoor map widget using flutter_map
class IndoorMapWidget extends ConsumerStatefulWidget {
  const IndoorMapWidget({super.key});

  @override
  ConsumerState<IndoorMapWidget> createState() => _IndoorMapWidgetState();
}

class _IndoorMapWidgetState extends ConsumerState<IndoorMapWidget> {
  late MapController _mapController;
  late List<Marker> _poiMarkers;
  late List<Polygon> _poiPolygons;
  late List<Polyline> _routeLines;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _poiMarkers = [];
    _poiPolygons = [];
    _routeLines = [];
  }

  @override
  Widget build(BuildContext context) {
    final asyncMapResult = ref.watch(placeMapProvider).valueOrNull;   // reactive data stream rather than a single future callback.
    final placeMap = asyncMapResult?.placeMap;
    final placePosition = placeMap?.position;

    // final currentLevel = ref.watch(currentLevelProvider);


    // Build POI markers
    // _buildPoiMarkers(pois, selectedPoi);
    
    // Build POI polygons (for way-based POIs)
    
    // _buildPoiPolygons(pois);
    
    // Build route lines
    // _buildRouteLines(routes, routeGeometry);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: placePosition ?? AppConstants.defaultMapCenter,
        initialZoom: 18.0,
        maxZoom: 20.0,
        minZoom: 16.0,
        onMapReady: () => _onMapReady(placeMap),
      ),
      children: [
        // Base tile layer (outdoor map)
        TileLayer(
          urlTemplate: 'https://{s}.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=0e224c51130f44f59a53672538a958f6',
          subdomains: const ['a', 'b', 'c'],),
        // POI Markers
        MarkerLayer(markers: _poiMarkers),
        // POI Polygons
        PolygonLayer(polygons: _poiPolygons),
        // Route Lines
        PolylineLayer(polylines: _routeLines),
      ],
    );
  }

  void _buildPoiMarkers(List<Poi> pois, Poi? selectedPoi) {
    _poiMarkers = pois
        .where((poi) => poi.geometry == null) // Only point-based POIs
        .map((poi) => Marker(
              point: poi.position,
              width: 30,
              height: 30,
              child: PoiMarkerWidget(
                poi: poi,
                isSelected: selectedPoi?.id == poi.id,
                // onTap: () => _onPoiTap(poi),
                showLabel: true,
              ),
            ))
        .toList();
  }

  void _buildPoiPolygons(List<Poi> pois) {
    _poiPolygons = pois
        .where((poi) => poi.geometry != null) // Only way-based POIs
        .map((poi) => Polygon(
              points: poi.geometry!,
              color: _getPoiPolygonColor(poi.type).withOpacity(0.3),
              borderColor: _getPoiPolygonColor(poi.type),
              borderStrokeWidth: 2,
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

  void _onMapReady(PlaceMap? placeMap) {
    // Center map on the place
    if (placeMap != null) _mapController.move(placeMap.position, 18.0);
  }

  // void _onPoiTap(Poi poi) {
  //   ref.read(selectedPoiProvider.notifier).state = poi;
  // }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}