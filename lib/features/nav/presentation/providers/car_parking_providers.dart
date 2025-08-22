import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/domain/entities/car_parking_info.dart';
import 'package:findeasy/core/services/storage_service.dart';

/// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

/// Provider for car parking information
final carParkingInfoProvider = StateNotifierProvider<CarParkingInfoNotifier, CarParkingInfo?>(
  (ref) => CarParkingInfoNotifier(ref.read(storageServiceProvider)),
);

/// Notifier for managing car parking information
class CarParkingInfoNotifier extends StateNotifier<CarParkingInfo?> {
  final StorageService _storageService;

  CarParkingInfoNotifier(this._storageService) : super(null) {
    _loadCarParkingInfo();
  }

  /// Load car parking info from storage
  Future<void> _loadCarParkingInfo() async {
    try {
      final parkingData = await _storageService.getCarParkingInfo();
      if (parkingData != null) {
        state = CarParkingInfo.fromJson(parkingData);
      }
    } catch (e) {
      // Handle error silently, state remains null
      print('Error loading car parking info: $e');
    }
  }

  /// Save car parking information
  Future<void> saveCarParkingInfo(CarParkingInfo parkingInfo) async {
    try {
      await _storageService.saveCarParkingInfo(parkingInfo.toJson());
      state = parkingInfo;
    } catch (e) {
      print('Error saving car parking info: $e');
      rethrow;
    }
  }

  /// Clear car parking information
  Future<void> clearCarParkingInfo() async {
    try {
      await _storageService.clearCarParkingInfo();
      state = null;
    } catch (e) {
      print('Error clearing car parking info: $e');
      rethrow;
    }
  }

  /// Check if car is parked at a specific place and level
  bool isCarParkedAt(int placeId, double levelNumber) {
    return state != null && 
           state!.placeId == placeId && 
           state!.levelNumber == levelNumber;
  }

  /// Get parking space name if car is parked at current location
  String? getParkingSpaceName(int placeId, double levelNumber) {
    if (isCarParkedAt(placeId, levelNumber)) {
      return state!.parkingSpaceName;
    }
    return null;
  }
}
