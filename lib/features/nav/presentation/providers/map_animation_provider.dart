import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latlong2;


// TODO: the service seems to be overengineered. fixed it

/// Provider for the AnimatedMapController
/// This should be used in your map widget to provide the controller
final animatedMapControllerProvider = StateProvider<AnimatedMapController?>((ref) => null);

/// Map animation service that provides convenient methods to animate the map
class MapAnimationService {
  final AnimatedMapController _controller;
  
  MapAnimationService(this._controller);
  
  /// Animate to a specific location with optional zoom and rotation
  Future<void> animateTo({
    required latlong2.LatLng destination,
    double? zoom,
    double? rotation,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      dest: destination,
      zoom: zoom,
      rotation: rotation,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to a location with smooth zoom transition
  Future<void> animateToWithZoom({
    required latlong2.LatLng destination,
    required double targetZoom,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      dest: destination,
      zoom: targetZoom,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to a location with rotation
  Future<void> animateToWithRotation({
    required latlong2.LatLng destination,
    required double targetRotation,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      dest: destination,
      rotation: targetRotation,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to a location with both zoom and rotation
  Future<void> animateToWithZoomAndRotation({
    required latlong2.LatLng destination,
    required double targetZoom,
    required double targetRotation,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      dest: destination,
      zoom: targetZoom,
      rotation: targetRotation,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to current device position
  Future<void> animateToCurrentPosition({
    double? zoom,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    // This would need to be connected to your location provider
    // You can inject the location service here
  }
  
  /// Animate to a specific POI or place
  Future<void> animateToPlace({
    required latlong2.LatLng placeLocation,
    double? zoom,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await animateTo(
      destination: placeLocation,
      zoom: zoom ?? 18.0, // Default zoom for places
      duration: duration,
      curve: curve,
    );
  }
  
  /// Smooth zoom in/out animation
  Future<void> animateZoom({
    required double targetZoom,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      zoom: targetZoom,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Smooth rotation animation
  Future<void> animateRotation({
    required double targetRotation,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.easeInOut,
  }) async {
    await _controller.animateTo(
      rotation: targetRotation,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Reset map to default position and zoom
  Future<void> resetMap({
    latlong2.LatLng? defaultCenter,
    double defaultZoom = 18.0,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.easeInOut,
  }) async {
    final center = defaultCenter ?? latlong2.LatLng(0, 0);
    await _controller.animateTo(
      dest: center,
      zoom: defaultZoom,
      rotation: 0.0,
      duration: duration,
      curve: curve,
    );
  }
}

/// Provider for the MapAnimationService
/// This provides the service that can be used throughout the app
final mapAnimationServiceProvider = Provider<MapAnimationService?>((ref) {
  final controller = ref.watch(animatedMapControllerProvider);
  if (controller == null) return null;
  return MapAnimationService(controller);
});

/// Convenience provider for quick map animations
/// Usage: ref.read(mapAnimationProvider.notifier).animateToPlace(...)
final mapAnimationProvider = StateNotifierProvider<MapAnimationNotifier, void>((ref) {
  final service = ref.watch(mapAnimationServiceProvider);
  if (service == null) {
    throw Exception('MapAnimationService not available. Make sure to provide AnimatedMapController first.');
  }
  return MapAnimationNotifier(service);
});

/// Notifier class for map animations
class MapAnimationNotifier extends StateNotifier<void> {
  final MapAnimationService _service;
  
  MapAnimationNotifier(this._service) : super(null);
  
  /// Animate to a specific location
  Future<void> animateTo({
    required latlong2.LatLng destination,
    double? zoom,
    double? rotation,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await _service.animateTo(
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
