# Car Parking Feature

This feature allows users to save and restore information about where they parked their car in indoor locations.

## Features

- **Save Car Location**: Users can specify where they parked their car by providing:
  - Place ID (automatically detected from current location)
  - Level number (floor number)
  - Parking space name (e.g., "B2-C102", "A1-15", "P3-42")

- **Visual Indicator**: A car icon with parking space name is displayed on the map when:
  - User is at the same place where they parked
  - User is on the same level where they parked

- **Persistent Storage**: Car parking information is saved locally and restored when the app is reopened

- **Easy Management**: Users can update or clear their car parking location through a simple dialog

## Usage

### Setting Car Location

1. Navigate to the indoor map where you parked your car
2. Make sure you're on the correct floor level
3. Tap the floating action button (car icon) on the map
4. Enter your parking space name in the dialog
5. Tap "Save" to store the location

### Updating Car Location

1. If you're at a location where you previously parked, the floating action button will show an edit icon
2. Tap it to open the dialog with your current parking space name
3. Modify the parking space name or tap "Clear Location" to remove it

### Viewing Car Location

- **When parked at current level**: A red car icon appears on the map with a label showing your parking space name
- **When parked at different level**: A transparent grey car icon appears with a label showing the level where your car is parked
- The icon is positioned at the actual parking space location (not the center of the place)
- This helps you quickly identify which floor your car is on when navigating through the building

## Technical Implementation

### Visual Indicators

The car parking feature provides different visual cues based on your current location:

1. **Red Car Icon with Parking Space Name**: 
   - Appears when you're at the same place and level where you parked
   - Indicates you're on the correct floor to find your car

2. **Transparent Grey Car Icon with Level Text**: 
   - Appears when you're at the same place but different level
   - Shows "Level X.X" to indicate which floor your car is on
   - Helps you navigate to the correct floor

### Data Model

```dart
class CarParkingInfo {
  final int placeId;           // Unique identifier for the place
  final double levelNumber;    // Floor level (e.g., 0.0, 1.0, -1.0)
  final String parkingSpaceName; // User-defined parking space name
  final DateTime parkedAt;     // Timestamp when location was saved
}
```

### Storage

- Uses `SharedPreferences` for local storage
- Data is automatically loaded when the app starts
- JSON serialization for data persistence

### State Management

- Uses Riverpod for state management
- `CarParkingInfoNotifier` handles all car parking operations
- Reactive updates across the UI when parking info changes

### UI Components

- `CarParkingDialog`: Dialog for inputting parking information
- `IndoorMapWidget`: Updated to show car icon and floating action button
- Floating action button changes icon based on current parking status

## Files

- `car_parking_info.dart`: Data model with freezed annotations
- `car_parking_providers.dart`: Riverpod providers and state management
- `car_parking_dialog.dart`: UI dialog for inputting parking information
- `indoor_map_widget.dart`: Updated map widget with car parking functionality
- `storage_service.dart`: Extended with car parking storage methods

## Future Enhancements

- Multiple car support
- Parking history
- Automatic parking detection
- Integration with navigation to find car
- Parking time tracking
- Parking fee calculation
