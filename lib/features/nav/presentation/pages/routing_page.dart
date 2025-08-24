import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_input_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/car_parking_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/indoor_map_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';


/// Page for route planning that wraps the RoutingInputWidget
/// 
/// This page can be opened in three ways:
/// 1. Without start/destination: User manually selects both start and end points
/// 2. With destination: User jumps in with a pre-selected destination (e.g., from "到這去" button)
/// 3. With start point: User jumps in with a pre-selected start point (e.g., from "從這里出發" button)
/// 
/// When initialDestination is provided, the page automatically sets the end point
/// and updates the UI to reflect that the user only needs to select a start point.
/// When initialStartPoint is provided, the page automatically sets the start point
/// and updates the UI to reflect that the user only needs to select a destination.


class RoutingPage extends ConsumerWidget {
  final Poi? initialStartPoi;
  final Poi? initialDestinationPoi;

  const RoutingPage({super.key, this.initialStartPoi, this.initialDestinationPoi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Main map
          const IndoorMapWidget(),
          
          // Simplified routing input at top
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: RoutingInputWidget(
              initialStartPoint: initialStartPoi,
              initialDestination: initialDestinationPoi,
            ),
          ),          

          // Left side controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 8,
            child: Column(
              children: [
                const CarParkingButton(),
                const SizedBox(height: 4),
                const LevelSelectionWidget(),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

