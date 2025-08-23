# Map Animation Service

This service provides convenient methods to animate the map with smooth transitions, zoom, and rotation effects.

## Setup

### 1. Import the provider
```dart
import 'package:findeasy/features/nav/presentation/providers/map_animation_provider.dart';
```

### 2. Provide the AnimatedMapController
In your map widget, make sure to provide the controller to the provider system:

```dart
class _IndoorMapWidgetState extends ConsumerState<IndoorMapWidget> {
  late AnimatedMapController _animatedMapController;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Provide the controller to the provider system
    ref.read(animatedMapControllerProvider.notifier).state = _animatedMapController;
    
    // ... rest of your build method
  }
}
```

## Usage Examples

### Basic Animation
```dart
// Animate to a specific location
ref.read(mapAnimationProvider.notifier).animateTo(
  destination: const latlong2.LatLng(51.5074, -0.1278),
);

// Animate with zoom and rotation
ref.read(mapAnimationProvider.notifier).animateTo(
  destination: const latlong2.LatLng(51.5074, -0.1278),
  zoom: 15.0,
  rotation: 45.0,
  duration: const Duration(seconds: 3),
);
```

### Convenience Methods
```dart
// Animate to a place with default zoom
ref.read(mapAnimationProvider.notifier).animateToPlace(
  placeLocation,
);

// Animate zoom only
ref.read(mapAnimationProvider.notifier).animateZoom(20.0);

// Animate rotation only
ref.read(mapAnimationProvider.notifier).animateRotation(90.0);

// Reset map to default position
ref.read(mapAnimationProvider.notifier).resetMap();
```

### Advanced Usage
```dart
// Animate to location with custom curve
ref.read(mapAnimationProvider.notifier).animateTo(
  destination: targetLocation,
  zoom: 18.0,
  duration: const Duration(seconds: 2),
  curve: Curves.bounceOut,
);

// Animate with both zoom and rotation
ref.read(mapAnimationProvider.notifier).animateToWithZoomAndRotation(
  destination: targetLocation,
  targetZoom: 20.0,
  targetRotation: 180.0,
  duration: const Duration(seconds: 3),
);
```

## Available Methods

### Core Animation Methods
- `animateTo()` - Basic animation with optional zoom and rotation
- `animateToWithZoom()` - Animation with zoom transition
- `animateToWithRotation()` - Animation with rotation transition
- `animateToWithZoomAndRotation()` - Animation with both zoom and rotation

### Utility Methods
- `animateToPlace()` - Animate to a place with default zoom (18.0)
- `animateZoom()` - Smooth zoom transition
- `animateRotation()` - Smooth rotation transition
- `resetMap()` - Reset to default position and zoom

### Parameters
- `destination` - Target LatLng coordinates
- `zoom` - Target zoom level (optional)
- `rotation` - Target rotation in degrees (optional)
- `duration` - Animation duration (default: 2 seconds)
- `curve` - Animation curve (default: Curves.easeInOut)

## Integration with Existing Code

### Replace Direct Controller Calls
Instead of:
```dart
// Old way
_animatedMapController.animateTo(
  dest: destination,
  zoom: zoom,
  rotation: rotation,
  duration: Duration(seconds: 2),
);
```

Use:
```dart
// New way
ref.read(mapAnimationProvider.notifier).animateTo(
  destination: destination,
  zoom: zoom,
  rotation: rotation,
  duration: const Duration(seconds: 2),
);
```

### Listen for Place Changes
```dart
ref.listen<AsyncValue<MapResult?>>(placeMapProvider, (previous, next) {
  final nextPlaceMap = next.valueOrNull?.placeMap;
  
  if (nextPlaceMap != null && nextPlaceMap != previous?.valueOrNull?.placeMap) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapAnimationProvider.notifier).animateToPlace(
        nextPlaceMap.position,
      );
    });
  }
});
```

## Benefits

1. **Centralized Control** - All map animations go through one service
2. **Consistent Behavior** - Same animation parameters across the app
3. **Easy Testing** - Mock the service for testing
4. **Reusable** - Use the same service in multiple widgets
5. **Type Safe** - Compile-time checking of parameters
6. **Flexible** - Easy to add new animation methods

## Error Handling

The service includes proper error handling:
- Checks if the controller is available before use
- Provides meaningful error messages
- Gracefully handles missing dependencies

## Performance

- Uses `WidgetsBinding.instance.addPostFrameCallback` for smooth animations
- Efficient provider updates
- Minimal memory overhead
- Optimized for frequent use
