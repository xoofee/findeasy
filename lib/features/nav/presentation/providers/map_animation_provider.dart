import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/features/nav/presentation/services/flutter_map_animation_service.dart';

// TODO: the service seems to be overengineered. fixed it
// TODO: save the zoom, rotation, and center from camera callback in widget

/// Provider for the AnimatedMapController
/// This should be used in your map widget to provide the controller
final animatedMapControllerProvider = StateProvider<AnimatedMapController?>((ref) => null);

/// Provider for the FlutterMapAnimationService
/// This provides the service that can be used throughout the app
final mapAnimationServiceProvider = Provider<FlutterMapAnimationService?>((ref) {
  final controller = ref.watch(animatedMapControllerProvider);
  if (controller == null) return null;
  return FlutterMapAnimationService(controller);
});

/// Convenience provider for quick map animations
/// Usage: ref.read(mapAnimationProvider.notifier).animateToPlace(...)
final mapAnimationProvider = StateNotifierProvider<MapAnimationNotifier, void>((ref) {
  final service = ref.watch(mapAnimationServiceProvider);
  if (service == null) {
    throw Exception('FlutterMapAnimationService not available. Make sure to provide AnimatedMapController first.');
  }
  return MapAnimationNotifier(service);
});

/// Notifier class for map animations
class MapAnimationNotifier extends StateNotifier<void> {
  final FlutterMapAnimationService _service;
  
  MapAnimationNotifier(this._service) : super(null);
  
  /// Animate to a specific location
  Future<void> animateTo({
    required latlong2.LatLng destination,
    double? zoom,
    double? rotation,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await _service.animateToLocation(
      destination: destination,
      zoom: zoom,
      rotation: rotation,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to a place with default zoom
  Future<void> animateToPlace(latlong2.LatLng placeLocation) async {
    await _service.animateToPlace(placeLocation: placeLocation);
  }
  
  /// Animate zoom
  Future<void> animateZoom(double targetZoom) async {
    await _service.animateZoom(targetZoom: targetZoom);
  }
  
  /// Animate rotation
  Future<void> animateRotation(double targetRotation) async {
    await _service.animateRotation(targetRotation: targetRotation);
  }
  
  /// Reset map
  Future<void> resetMap({latlong2.LatLng? defaultCenter, double defaultZoom = 18.0}) async {
    await _service.resetMap(defaultCenter: defaultCenter, defaultZoom: defaultZoom);
  }
}
