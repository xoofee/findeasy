import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:findeasy/features/nav/presentation/widgets/indoor_map_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/level_selection_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_list_widget.dart';

/// Main navigation map page that displays the indoor map with POIs and routes
class NavigationMapPage extends ConsumerStatefulWidget {
  const NavigationMapPage({super.key});

  @override
  ConsumerState<NavigationMapPage> createState() => _NavigationMapPageState();
}

class _NavigationMapPageState extends ConsumerState<NavigationMapPage> {
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Use the business logic layer to initialize the map
      final mapInitNotifier = ref.read(mapLoadingStateProvider.notifier);
      final (placeMap, poiManager) = await mapInitNotifier.initializeMap();
      
      // Update the providers with the loaded data
      ref.read(placeMapProvider.notifier).state = placeMap;
      ref.read(poiManagerProvider.notifier).state = poiManager;
      
      // Update available levels
      final levels = placeMap.levelMaps.keys.toList()..sort();
      ref.read(availableLevelsProvider.notifier).state = levels;
      
      // Set initial level
      if (levels.isNotEmpty) {
        ref.read(currentLevelProvider.notifier).state = levels.first;
      }
      
      // Update map center
      ref.read(mapCenterProvider.notifier).state = placeMap.position;
      
    } catch (e) {
      // Error is already handled by the loading notifier
      debugPrint('Map initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapLoadingState = ref.watch(mapLoadingStateProvider);
    final placeMap = ref.watch(placeMapProvider);
    final currentLevel = ref.watch(currentLevelProvider);
    final availableLevels = ref.watch(availableLevelsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main map
          if (placeMap != null) const IndoorMapWidget(),
          
          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                ),
                const SizedBox(width: 16),
                // Level selection
                if (availableLevels.isNotEmpty)
                  Expanded(child: LevelSelectionWidget()),
              ],
            ),
          ),
          
          // Bottom POI list
          if (placeMap != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: const PoiListWidget(),
            ),
          
          // Loading overlay
          if (mapLoadingState == MapLoadingState.loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error overlay
          if (mapLoadingState == MapLoadingState.error)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
