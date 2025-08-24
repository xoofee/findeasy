import 'package:findeasy/features/nav/presentation/widgets/search_results_widget.dart';
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
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  final TextEditingController _startTextController = TextEditingController();
  final TextEditingController _destinationTextController = TextEditingController();
  String? _lastFocusedField; // Track which field was last focused

  @override
  void initState() {
    super.initState();
    // Set initial start point if provided
    if (widget.initialStartPoint != null) {
      _startPoi = widget.initialStartPoint;
      _startTextController.text = widget.initialStartPoint!.name;
    }
    // Set initial destination if provided
    if (widget.initialDestination != null) {
      _endPoi = widget.initialDestination;
      _destinationTextController.text = widget.initialDestination!.name;
    }
    
    // Add focus listeners to track which field was last focused
    _startFocusNode.addListener(() {
      if (_startFocusNode.hasFocus) {
        _lastFocusedField = 'start';
        // print('start focused');
      }
    });
    
    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        _lastFocusedField = 'destination';
        // print('destination focused');
      }
    });
  }

  @override
  void dispose() {
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    _startTextController.dispose();
    _destinationTextController.dispose();
    super.dispose();
  }

  void _onStartPoiSelected(Poi poi) {
    setState(() {
      _startPoi = poi;
      _startTextController.text = poi.name;
    });
    widget.onStartPoiSelected?.call(poi);
  }

  void _onEndPoiSelected(Poi poi) {
    setState(() {
      _endPoi = poi;
      _destinationTextController.text = poi.name;
    });
    widget.onEndPoiSelected?.call(poi);
  }

  void _onPoiSelectedFromSearch(Poi poi) {
    // Use the last focused field to determine which input should receive the POI
    if (_lastFocusedField == 'start') {
      _onStartPoiSelected(poi);
    } else if (_lastFocusedField == 'destination') {
      _onEndPoiSelected(poi);
    } else {
      // If no field was focused, check if one field is empty and fill it
      if (_startPoi == null) {
        _onStartPoiSelected(poi);
      } else if (_endPoi == null) {
        _onEndPoiSelected(poi);
      } else {
        // Both fields have values, default to start point
        _onStartPoiSelected(poi);
      }
    }
  }

  void _swapPois() {
    setState(() {
      final temp = _startPoi;
      final tempText = _startTextController.text;
      _startPoi = _endPoi;
      _startTextController.text = _destinationTextController.text;
      _endPoi = temp;
      _destinationTextController.text = tempText;
    });
  }

  void _onVoiceInput() {
    // TODO: Implement voice input functionality
    // This could open a voice input dialog or trigger speech recognition
  }

    @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
          child: Column(
            children: [
              Row(
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
                                hintText: '輸入起點',
                                initialValue: null, // Don't use initialValue to prevent reverting
                                onPoiSelected: _onStartPoiSelected,
                                onCleared: () {
                                  setState(() {
                                    _startPoi = null;
                                    _startTextController.clear();
                                  });
                                },
                                showBorder: false,
                                focusNode: _startFocusNode,
                                textController: _startTextController, // Pass the text controller
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
                              size: 18 ,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: PoiSearchInput(
                                hintText: '輸入終點',
                                initialValue: null, // Don't use initialValue to prevent reverting
                                onPoiSelected: _onEndPoiSelected,
                                onCleared: () {
                                  setState(() {
                                    _endPoi = null;
                                    _destinationTextController.clear();
                                  });
                                },
                                showBorder: false,
                                focusNode: _destinationFocusNode,
                                textController: _destinationTextController, // Pass the text controller
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(width: 8),
              
                  // Column 3: Swap button
                  Column(
                    children: [
                      IconButton(
                        onPressed: _swapPois,
                        icon: Icon(
                          Icons.swap_vert,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        tooltip: 'Swap start and end points',
                      ),
                      _buildRoutePlanButton(),
                    ],
                  ),
              
                  const SizedBox(width: 8),
              
                  // Column 4: Voice button
                  VoiceButton(
                    onPressed: _onVoiceInput,
                    size: 24,
                  ),
                ],
              ),

            ],
          ),
        ),
        SearchResultsWidget(
          showActionButtons: false,
          onPoiSelected: _onPoiSelectedFromSearch,
        ),        
      ],
    );
  }

  Widget _buildRoutePlanButton() {
    return 
       ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 55,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {


                },
                child: Row(
                  children: [
                     Center(
                       child: SizedBox(
                         width: 26,
                         height: 26,
                         child: Icon(
                           Icons.turn_sharp_right,
                           color: Colors.grey[600],
                           size: 26,
                         ),
                       ),
                     ),
                    // const SizedBox(height: 0),
                     Text(
                      '規劃\n路線',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );    
  }
}
