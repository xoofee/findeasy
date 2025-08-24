import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_search_input.dart';

/// Simple widget for routing input with start and end POI selection
/// 
/// This widget provides a clean interface for route planning with:
/// - Start point selection (can be pre-filled with initialStartPoint)
/// - End point selection (can be pre-filled with initialDestination)
/// - Swap button to exchange start and end points
/// - Route calculation button
/// 
/// The widget automatically handles the case where start or destination is pre-selected,
/// making it perfect for both "到這去" (Go Here) and "從這里出發" (Depart from Here) functionality.
class RoutingInputWidget extends ConsumerStatefulWidget {
  final ValueChanged<Poi>? onStartPoiSelected;
  final ValueChanged<Poi>? onEndPoiSelected;
  final VoidCallback? onRouteRequested;
  final Poi? initialStartPoint;
  final Poi? initialDestination;

  const RoutingInputWidget({
    super.key,
    this.onStartPoiSelected,
    this.onEndPoiSelected,
    this.onRouteRequested,
    this.initialStartPoint,
    this.initialDestination,
  });

  @override
  ConsumerState<RoutingInputWidget> createState() => _RoutingInputWidgetState();
}

class _RoutingInputWidgetState extends ConsumerState<RoutingInputWidget> {
  Poi? _startPoi;
  Poi? _endPoi;

  @override
  void initState() {
    super.initState();
    // Set initial start point if provided
    if (widget.initialStartPoint != null) {
      _startPoi = widget.initialStartPoint;
    }
    // Set initial destination if provided
    if (widget.initialDestination != null) {
      _endPoi = widget.initialDestination;
    }
  }

  void _onStartPoiSelected(Poi poi) {
    setState(() {
      _startPoi = poi;
    });
    widget.onStartPoiSelected?.call(poi);
  }

  void _onEndPoiSelected(Poi poi) {
    setState(() {
      _endPoi = poi;
    });
    widget.onEndPoiSelected?.call(poi);
  }

  void _onRouteRequested() {
    if (_startPoi != null && _endPoi != null) {
      widget.onRouteRequested?.call();
    }
  }

  void _swapPois() {
    setState(() {
      final temp = _startPoi;
      _startPoi = _endPoi;
      _endPoi = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canRoute = _startPoi != null && _endPoi != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start POI input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trip_origin,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Start Point',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PoiSearchInput(
                hintText: 'Search start point...',
                initialValue: _startPoi?.name,
                onPoiSelected: _onStartPoiSelected,
                onCleared: () {
                  setState(() {
                    _startPoi = null;
                  });
                },
                maxResults: 5,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Swap button
          Center(
            child: IconButton(
              onPressed: _swapPois,
              icon: Icon(
                Icons.swap_vert,
                color: Colors.grey[600],
                size: 24,
              ),
              tooltip: 'Swap start and end points',
            ),
          ),

          // End POI input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Destination',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PoiSearchInput(
                hintText: 'Search destination...',
                initialValue: _endPoi?.name,
                onPoiSelected: _onEndPoiSelected,
                onCleared: () {
                  setState(() {
                    _endPoi = null;
                  });
                },
                maxResults: 5,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Route button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRoute ? _onRouteRequested : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    canRoute ? 'Find Route' : 'Select Start & End Points',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
