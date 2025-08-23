import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_input_widget.dart';

/// Page for route planning that wraps the RoutingInputWidget
class RoutingPage extends ConsumerStatefulWidget {
  const RoutingPage({super.key});

  @override
  ConsumerState<RoutingPage> createState() => _RoutingPageState();
}

class _RoutingPageState extends ConsumerState<RoutingPage> {
  Poi? _startPoi;
  Poi? _endPoi;

  void _onStartPoiSelected(Poi poi) {
    setState(() {
      _startPoi = poi;
    });
  }

  void _onEndPoiSelected(Poi poi) {
    setState(() {
      _endPoi = poi;
    });
  }

  void _onRouteRequested() {
    if (_startPoi != null && _endPoi != null) {
      // TODO: Implement route calculation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculating route from ${_startPoi!.name} to ${_endPoi!.name}'),
          backgroundColor: Colors.blue[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planning'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[600]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Welcome message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Plan Your Route',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your start point and destination to find the best route',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Routing input widget
                RoutingInputWidget(
                  onStartPoiSelected: _onStartPoiSelected,
                  onEndPoiSelected: _onEndPoiSelected,
                  onRouteRequested: _onRouteRequested,
                ),
                
                const SizedBox(height: 24),
                
                // Additional info or tips
                if (_startPoi != null && _endPoi != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ready to Route',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Both start and end points are selected. Tap "Find Route" to calculate your route.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
