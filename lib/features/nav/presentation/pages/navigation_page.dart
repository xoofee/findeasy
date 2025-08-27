import 'package:findeasy/features/nav/presentation/widgets/car_parking_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_summary_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/search_bar_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/widgets/indoor_map_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing/level_transition_widget.dart';

import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';
import 'package:easyroute/easyroute.dart';

/// Main navigation map page that displays the indoor map with POIs and routes
/// 
/// This page can operate in two modes:
/// 1. Normal (home) mode: Shows search bar for finding POIs
/// 2. Routing mode: Shows routing input for planning routes
/// 
/// The mode can be changed by:
/// - Tapping the routing button (switches to routing mode)
/// - Tapping the back button in routing mode (returns to home mode)
/// - Programmatically setting initialStartPoi or initialDestinationPoi (automatically switches to routing mode)
class NavigationPage extends ConsumerWidget {
  final Poi? initialStartPoi;
  final Poi? initialDestinationPoi;

  const NavigationPage({
    super.key, 
    this.initialStartPoi, 
    this.initialDestinationPoi
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the navigation mode
    final navigationMode = ref.watch(navigationModeProvider);
    
    // If initial POIs are provided, automatically switch to routing mode
    if ((initialStartPoi != null || initialDestinationPoi != null) && 
        navigationMode == AppNavigationMode.home) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationModeProvider.notifier).state = AppNavigationMode.routing;
      });
    }

    // final mapLoadingState = ref.watch(mapLoaderProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main map
          const IndoorMapWidget(),
          
          // Top controls
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 16,
          //   left: 16,
          //   right: 16,
          //   child: Row(
          //     children: [
          //       // Back button
          //       Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(25),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withOpacity(0.1),
          //               blurRadius: 8,
          //               offset: const Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: IconButton(
          //           icon: const Icon(Icons.arrow_back),
          //           onPressed: () => Navigator.of(context).pop(),
          //           tooltip: 'Back',
          //         ),
          //       ),
          //       const SizedBox(width: 16),

          //     ],
          //   ),
          // ),
          
          // Top controls - conditionally show search bar or routing input
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: navigationMode == AppNavigationMode.home
                ? const SearchBarWidget()
                : RoutingInputWidget(
                    initialStartPoint: initialStartPoi,
                    initialDestination: initialDestinationPoi,
                    onGoBack: () {
                      // Return to home mode
                      ref.read(navigationModeProvider.notifier).state = AppNavigationMode.home;
                    },
                  ),
          ),          


          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + (navigationMode == AppNavigationMode.routing ? 80 :  16),
            left: 8,
            child: Column(
              children: [
                if (navigationMode == AppNavigationMode.home)
                  const CarParkingButton(),
                const SizedBox(height: 4),
                // Show level transition widget in routing mode when there's a route
                if (navigationMode == AppNavigationMode.routing)
                  const LevelTransitionWidget()
                else
                  const LevelSelectionWidget(),
              ],
            ),
          ),

          // Right side controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: 16,
            child: Column(
              children: [
                // Show routing button only in home mode
                if (navigationMode == AppNavigationMode.home)
                  const RoutingButton(),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // Bottom POI list
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: const PoiListWidget(),
          // ),
          
          // Loading overlay
          // if (mapLoadingState == MapLoadingState.loading)
          //   Container(
          //     color: Colors.black.withOpacity(0.5),
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   ),

          if (navigationMode == AppNavigationMode.routing)

            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RoutingSummaryWidget(),
            ),
        ],
      ),
    );
  }
}