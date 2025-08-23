import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';
import 'package:findeasy/features/nav/domain/entities/car_parking_info.dart';

/// Utility class for car park operations
class CarParkUtils {
  /// Sets car park information and shows a confirmation snackbar
  /// 
  /// This callback is reusable across different parts of the app
  /// such as search results, dialogs, and other UI components.
  static Future<void> setCarParkInfo({
    required BuildContext context,
    required Poi parkingPoi,
    String? customMessage,
  }) async {
    // Store car park info using the CarParkingInfoNotifier
    final ref = ProviderScope.containerOf(context);

    final currentPlace = ref.read(currentPlaceProvider);
    if (currentPlace == null) {
      // show failed snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('設置停車位置失敗: 當前位置無服務'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Create CarParkingInfo from Poi data
    final parkingInfo = CarParkingInfo(
      placeId: currentPlace.id,
      levelNumber: parkingPoi.level.value,
      parkingSpaceName: parkingPoi.name,
      parkedAt: DateTime.now(),
    );
    
    // Save to the notifier
    await ref.read(carParkingInfoNotifierProvider.notifier).saveCarParkingInfo(parkingInfo);
    
    // Show confirmation snackbar
    final message = customMessage ?? 
        '您的車停在${currentPlace.name}${parkingPoi.level.displayName}${parkingPoi.name}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: '確定',
          textColor: Colors.white,
          onPressed: () {
            // Dismiss the snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Alternative method for setting car park info with more customization
  static Future<void> setCarParkInfoWithCustomization({
    required BuildContext context,
    required Poi parkingPoi,
    required String placeName,
    required int placeId,
    String? customMessage,
    Duration? snackBarDuration,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      // Store car park info using the CarParkingInfoNotifier
      final ref = ProviderScope.containerOf(context);
      
      // Create CarParkingInfo from Poi data
      final parkingInfo = CarParkingInfo(
        placeId: placeId,
        levelNumber: parkingPoi.level.value,
        parkingSpaceName: parkingPoi.name,
        parkedAt: DateTime.now(),
      );
      
      // Save to the notifier
      await ref.read(carParkingInfoNotifierProvider.notifier).saveCarParkingInfo(parkingInfo);
      
      // Show confirmation snackbar
      final message = customMessage ?? 
          '您的車停在$placeName${parkingPoi.level.value}${parkingPoi.name}';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: snackBarDuration ?? const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: '確定',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      
      // Call success callback if provided
      onSuccess?.call();
      
    } catch (e) {
      // Show error snackbar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '設置停車位置失敗: $e',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      
      // Call error callback if provided
      onError?.call();
    }
  }
  
  /// Gets the current car park location from the provider
  static CarParkingInfo? getCurrentCarParkLocation(BuildContext context) {
    final ref = ProviderScope.containerOf(context);
    return ref.read(carParkingInfoNotifierProvider);
  }
  
  /// Clears the car park location and shows a confirmation snackbar
  static Future<void> clearCarParkInfo(BuildContext context) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(carParkingInfoNotifierProvider.notifier).clearCarParkingInfo();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '已清除停車位置',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: '確定',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
