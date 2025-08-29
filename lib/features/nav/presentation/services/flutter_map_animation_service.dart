import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:findeasy/features/nav/domain/services/map_animation_service.dart';

/// Flutter-specific implementation of MapAnimationServiceBase
/// Uses AnimatedMapController for map animations
class FlutterMapAnimationService extends MapAnimationService {
  final AnimatedMapController _controller;
  
  FlutterMapAnimationService(this._controller);
  
  @override
  void animateTo(double lat, double lon, {double? zoom, double? rotation, Duration duration = const Duration(seconds: 1)}) {
    _controller.animateTo(
      dest: latlong2.LatLng(lat, lon),
      zoom: zoom,
      rotation: rotation,
      duration: duration,
    );
  }
  
  /// Animate to a specific location with optional zoom and rotation
  Future<void> animateToLocation({
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
    Duration duration = const Duration(seconds: 1),
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
    Duration duration = const Duration(seconds: 1),
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
    Duration duration = const Duration(seconds: 1),
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
  
  /// Animate to a specific POI or place
  Future<void> animateToPlace({
    required latlong2.LatLng placeLocation,
    double? zoom,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeInOut,
  }) async {
    await animateToLocation(
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
