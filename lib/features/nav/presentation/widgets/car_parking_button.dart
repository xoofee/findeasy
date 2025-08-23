import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/presentation/widgets/car_parking_dialog.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';

class CarParkingButton extends ConsumerWidget {

  
  const CarParkingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carParkingInfo = ref.watch(carParkingInfoNotifierProvider);
    // final isCurrentlyParked = carParkingInfo != null && 
    //                           carParkingInfo.placeId == placeId && 
    //                           carParkingInfo.levelNumber == levelNumber;

    final isCurrentlyParked = false;

    return SizedBox(
      width: 42,
      height: 42,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentlyParked ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8), // Reduced corner radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showCarParkingDialog(context, ref),
            child: const Center(
              child: Icon(
                Icons.directions_car,
                color: Colors.orange,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCarParkingDialog(BuildContext context, WidgetRef ref) {
    final carParkingInfo = ref.read(carParkingInfoNotifierProvider);
    String? currentParkingSpace;
    
    showDialog(
      context: context,
      builder: (context) => CarParkingDialog(
        placeId: 0,
        levelNumber: 0,
        currentParkingSpace: currentParkingSpace,
      ),
    );
  }
}