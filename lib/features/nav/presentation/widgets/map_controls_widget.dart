import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/features/nav/presentation/providers/map_animation_provider.dart';
import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';

/// Widget that provides convenient map control buttons
/// This demonstrates how to use the map animation service
class MapControlsWidget extends ConsumerWidget {
  const MapControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        children: [
          // Animate to current place button
          FloatingActionButton.small(
            onPressed: () {
              final currentPlace = ref.read(currentPlaceProvider);
              if (currentPlace != null) {
                ref.read(mapAnimationProvider.notifier).animateToPlace(
                  currentPlace.location,
                );
              }
            },
            tooltip: 'Go to current place',
            child: const Icon(Icons.location_on),
          ),
          
          const SizedBox(height: 8),
          
          // Zoom in button
          FloatingActionButton.small(
            onPressed: () {
              final currentZoom = ref.read(mapZoomProvider);
              ref.read(mapAnimationProvider.notifier).animateZoom(currentZoom + 1);
            },
            tooltip: 'Zoom in',
            child: const Icon(Icons.zoom_in),
          ),
          
          const SizedBox(height: 8),
          
          // Zoom out button
          FloatingActionButton.small(
            onPressed: () {
              final currentZoom = ref.read(mapZoomProvider);
              ref.read(mapAnimationProvider.notifier).animateZoom(currentZoom - 1);
            },
            tooltip: 'Zoom out',
            child: const Icon(Icons.zoom_out),
          ),
          
          const SizedBox(height: 8),
          
          // Reset map button
          FloatingActionButton.small(
            onPressed: () {
              ref.read(mapAnimationProvider.notifier).resetMap();
            },
            tooltip: 'Reset map',
            child: const Icon(Icons.refresh),
          ),
          
          const SizedBox(height: 8),
          
          // Animate to specific coordinates button (example)
          FloatingActionButton.small(
            onPressed: () {
              // Example: Animate to a specific location with zoom and rotation
              ref.read(mapAnimationProvider.notifier).animateTo(
                destination: const latlong2.LatLng(51.5074, -0.1278), // London coordinates
                zoom: 15.0,
                rotation: 45.0, // 45 degree rotation
                duration: const Duration(seconds: 3),
              );
            },
            tooltip: 'Go to London (example)',
            child: const Icon(Icons.explore),
          ),
        ],
      ),
    );
  }
}
