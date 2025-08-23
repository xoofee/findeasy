import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:findeasy/features/nav/domain/entities/car_parking_info.dart';
import 'package:findeasy/core/providers/storage_providers.dart';

part 'car_parking_providers.g.dart';

/// Provider for car parking information
@riverpod
class CarParkingInfoNotifier extends _$CarParkingInfoNotifier {
  @override
  CarParkingInfo? build() {
    _loadCarParkingInfo();
    return null;
  }

  /// Load car parking info from storage
  Future<void> _loadCarParkingInfo() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final parkingData = await storageService.getCarParkingInfo();
      if (parkingData != null) {
        state = CarParkingInfo.fromJson(parkingData);
      }
    } catch (e) {
      // Handle error silently, state remains null
      // In production, use proper logging instead of print
    }
  }

  /// Save car parking information
  Future<void> saveCarParkingInfo(CarParkingInfo parkingInfo) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveCarParkingInfo(parkingInfo.toJson());
      state = parkingInfo;
    } catch (e) {
      // In production, use proper logging instead of print
      rethrow;
    }
  }

  /// Clear car parking information
  Future<void> clearCarParkingInfo() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      await storageService.clearCarParkingInfo();
      state = null;
    } catch (e) {
      // In production, use proper logging instead of print
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
