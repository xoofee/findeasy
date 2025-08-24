import 'package:findeasy/features/nav/presentation/widgets/car_parking_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/routing_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/widgets/indoor_map_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_list_widget.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

/// Main navigation map page that displays the indoor map with POIs and routes
class NavigationPage extends ConsumerWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
           
           // Search bar at top

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

                     Positioned(
             bottom: MediaQuery.of(context).padding.bottom + 16,
             right: 16,
             child: Column(
               children: [
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
        ],
      ),
    );
  }
}