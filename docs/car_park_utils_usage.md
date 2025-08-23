# Car Park Utility Usage Guide

## Overview

The `CarParkUtils` class provides reusable callbacks for setting car park information across different parts of the app. It automatically shows a confirmation snackbar with the format: "您的車停在{place name}{層}{poi name}".

## Basic Usage

### Simple Implementation

```dart
import 'package:findeasy/features/nav/presentation/utils/car_park_utils.dart';

// Basic usage
CarParkUtils.setCarParkInfo(
  context: context,
  parkingPoi: selectedParkingPoi,
  placeName: 'Happy Coast',
  placeId: 123, // ID of the place/building
);
```

### With Customization

```dart
// Advanced usage with custom message and callbacks
CarParkUtils.setCarParkInfoWithCustomization(
  context: context,
  parkingPoi: selectedParkingPoi,
  placeName: 'Happy Coast',
  placeId: 123, // ID of the place/building
  customMessage: '您的車已停在指定位置',
  snackBarDuration: const Duration(seconds: 6),
  onSuccess: () {
    // Handle success - e.g., update UI, navigate, etc.
    print('Car park info set successfully');
  },
  onError: () {
    // Handle error - e.g., show error dialog, retry, etc.
    print('Failed to set car park info');
  },
);
```

### Get Current Car Park Location

```dart
// Get the currently stored car park location
final currentCarPark = CarParkUtils.getCurrentCarParkLocation(context);
if (currentCarPark != null) {
  print('Car is parked at: ${currentCarPark.name}');
}
```

### Clear Car Park Info

```dart
// Clear the stored car park location
CarParkUtils.clearCarParkInfo(context);
```

## Integration Examples

### 1. Search Results Widget

```dart
// In search_results_widget.dart
onPressed: () {
  final currentPlace = ref.read(currentPlaceProvider);
  final placeName = currentPlace?.name ?? '未知地點';
  final placeId = currentPlace?.id ?? 0;
  
  CarParkUtils.setCarParkInfo(
    context: context,
    parkingPoi: poi,
    placeName: placeName,
    placeId: placeId,
  );
},
```

### 2. Dialog Widget

```dart
// In a custom dialog
ElevatedButton(
  onPressed: () {
    CarParkUtils.setCarParkInfo(
      context: context,
      parkingPoi: dialogParkingPoi,
      placeName: 'Shopping Mall',
    );
    Navigator.of(context).pop(); // Close dialog
  },
  child: const Text('確認停車位置'),
),
```

### 3. Map Marker Info Window

```dart
// In map marker info window
IconButton(
  onPressed: () {
    CarParkUtils.setCarParkInfo(
      context: context,
      parkingPoi: markerPoi,
      placeName: 'Office Building',
    );
  },
  icon: const Icon(Icons.local_parking),
),
```

### 4. Navigation Page

```dart
// In navigation/routing page
ListTile(
  leading: const Icon(Icons.directions_car),
  title: const Text('設置停車位置'),
  onTap: () {
    CarParkUtils.setCarParkInfo(
      context: context,
      parkingPoi: destinationPoi,
      placeName: 'Destination Mall',
    );
  },
),
```

## Features

### Automatic Snackbar
- **Success**: Green background with checkmark icon
- **Error**: Red background with error icon (if using customization method)
- **Duration**: 4 seconds by default, customizable
- **Action**: "確定" button to dismiss

### Message Format
Default format: `您的車停在{place name}{層}{poi name}`

Examples:
- "您的車停在Happy Coast1樓A區停車場"
- "您的車停在Shopping MallB2層P3停車位"
- "您的車停在Office BuildingG層訪客停車場"

### Error Handling
- Try-catch wrapper in customization method
- Automatic error snackbar display
- Success/error callback support

## Current Implementation

The utility is already integrated with:

1. **State Management** ✅
   ```dart
   // Updates carParkLocationProvider in navigation_providers.dart
   container.read(carParkLocationProvider.notifier).state = parkingPoi;
   ```

2. **Navigation Integration** ✅
   ```dart
   // Can be accessed from anywhere in the app via:
   final carParkLocation = ref.watch(carParkLocationProvider);
   ```

## Future Enhancements

The utility can be easily extended with:

1. **Local Storage Integration**
   ```dart
   // Store in SharedPreferences or Hive for persistence
   await _storageService.setCarParkInfo(parkingPoi);
   ```

2. **Backend Sync**
   ```dart
   // Send to backend API for cloud storage
   await _apiService.updateCarParkInfo(parkingPoi);
   ```

3. **Additional State Updates**
   ```dart
   // Update other related providers
   ref.read(navigationProvider.notifier).setParkingLocation(parkingPoi);
   ```

## Best Practices

1. **Always provide context** for proper snackbar display
2. **Use meaningful place names** for better user experience
3. **Handle errors gracefully** with the customization method
4. **Keep messages consistent** across the app
5. **Test in different contexts** (dialogs, full-screen, etc.)

## Dependencies

- `flutter/material.dart` - For BuildContext and SnackBar
- `easyroute/easyroute.dart` - For Poi model
- No external packages required
