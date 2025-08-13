UI Widget → State Provider → Use Case → Repository → Data Source
   ↓              ↓           ↓          ↓           ↓
HomePage → LocationState → GetCurrentLocation → LocationRepository → GPS Hardware



```dart

// in data/repositories
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Result<Position>> getCurrentPosition() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.requestPermission();
      ...
    }
  }
}

// in domain/repositary
abstract class LocationRepository {
  Future<Result<Position>> getCurrentPosition();
  Future<Result<Position>> generateFakePosition({
    required double latitude,
    required double longitude,
    double accuracy = 5.0,
    double altitude = 0.0,
    double heading = 0.0,
    double speed = 0.0,
  });
}

// in domain/usercases
class GetCurrentLocation {
  final LocationRepository repository;

  const GetCurrentLocation(this.repository);

  Future<Result<Position>> call() async {
    try {
      return await repository.getCurrentPosition();
    } catch (e) {
      return Error(LocationFailure('Failed to get current location: $e'));
    }
  }
}



// in providers.dart prepare concrete repository (for usecase)
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepositoryImpl(),
);


// providers.dart: inject repository (locationRepositoryProvider) to use case (GetCurrentLocation)
final getCurrentLocationProvider = Provider<GetCurrentLocation>(
  (ref) => GetCurrentLocation(ref.read(locationRepositoryProvider)),
);


// State providers
final locationStateProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(ref.read(getCurrentLocationProvider)),
);

// In a widget
class LocationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the location state
    final locationState = ref.watch(locationStateProvider);
    
    // The provider automatically updates this widget when state changes
    if (locationState.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (locationState.error != null) {
      return Text('Error: ${locationState.error}');
    }
    
    if (locationState.position != null) {
      return Text('Location: ${locationState.position}');
    }
    
    return ElevatedButton(
      onPressed: () {
        // Trigger getting location
        ref.read(locationStateProvider.notifier).fetchLocation();
      },
      child: Text('Get Location'),
    );
  }
}
```

