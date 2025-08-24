import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_search_input.dart';
import 'package:findeasy/features/nav/presentation/widgets/voice_button.dart';

/// Simplified routing input widget with 4-column row layout
/// 
/// Layout:
/// 1. Go back button
/// 2. Start/Destination inputs (column with 2 rows)
/// 3. Swap button
/// 4. Voice button
class RoutingInputWidget extends ConsumerStatefulWidget {
  final ValueChanged<Poi>? onStartPoiSelected;
  final ValueChanged<Poi>? onEndPoiSelected;
  final VoidCallback? onRouteRequested;
  final Poi? initialStartPoint;
  final Poi? initialDestination;
  final VoidCallback? onGoBack;

  const RoutingInputWidget({
    super.key,
    this.onStartPoiSelected,
    this.onEndPoiSelected,
    this.onRouteRequested,
    this.initialStartPoint,
    this.initialDestination,
    this.onGoBack,
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

  void _swapPois() {
    setState(() {
      final temp = _startPoi;
      _startPoi = _endPoi;
      _endPoi = temp;
    });
  }

  void _onVoiceInput() {
    // TODO: Implement voice input functionality
    // This could open a voice input dialog or trigger speech recognition
  }

    @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Column 1: Go back button
          IconButton(
            onPressed: widget.onGoBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            tooltip: 'Go Back',
          ),

          const SizedBox(width: 8),

          // Column 2: Start and Destination inputs
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Start POI input row
                Row(
                  children: [
                    Icon(
                      Icons.trip_origin,
                      color: Colors.green[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PoiSearchInput(
                        hintText: 'Start point...',
                        initialValue: _startPoi?.name,
                        onPoiSelected: _onStartPoiSelected,
                        onCleared: () {
                          setState(() {
                            _startPoi = null;
                          });
                        },
                        maxResults: 3,
                        showBorder: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height:0),

                // Destination POI input row
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PoiSearchInput(
                        hintText: 'Destination...',
                        initialValue: _endPoi?.name,
                        onPoiSelected: _onEndPoiSelected,
                        onCleared: () {
                          setState(() {
                            _endPoi = null;
                          });
                        },
                        maxResults: 3,
                        showBorder: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Column 3: Swap button
          IconButton(
            onPressed: _swapPois,
            icon: Icon(
              Icons.swap_vert,
              color: Colors.grey[600],
              size: 24,
            ),
            tooltip: 'Swap start and end points',
          ),

          const SizedBox(width: 8),

          // Column 4: Voice button
          VoiceButton(
            onPressed: _onVoiceInput,
            size: 24,
          ),
        ],
      ),
    );
  }
}
