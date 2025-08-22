import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/features/nav/domain/entities/car_parking_info.dart';
import 'package:findeasy/features/nav/presentation/providers/car_parking_providers.dart';

/// Dialog for setting car parking information
class CarParkingDialog extends ConsumerStatefulWidget {
  final int placeId;
  final double levelNumber;
  final String? currentParkingSpace;

  const CarParkingDialog({
    super.key,
    required this.placeId,
    required this.levelNumber,
    this.currentParkingSpace,
  });

  @override
  ConsumerState<CarParkingDialog> createState() => _CarParkingDialogState();
}

class _CarParkingDialogState extends ConsumerState<CarParkingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _parkingSpaceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentParkingSpace != null) {
      _parkingSpaceController.text = widget.currentParkingSpace!;
    }
  }

  @override
  void dispose() {
    _parkingSpaceController.dispose();
    super.dispose();
  }

  Future<void> _saveParkingInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final parkingInfo = CarParkingInfo(
        placeId: widget.placeId,
        levelNumber: widget.levelNumber,
        parkingSpaceName: _parkingSpaceController.text.trim(),
        parkedAt: DateTime.now(),
      );

      await ref.read(carParkingInfoProvider.notifier).saveCarParkingInfo(parkingInfo);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car parking location saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving parking info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearParkingInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(carParkingInfoProvider.notifier).clearCarParkingInfo();
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car parking location cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing parking info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentParkingInfo = ref.watch(carParkingInfoProvider);
    final isCurrentlyParked = currentParkingInfo != null && 
                              currentParkingInfo.placeId == widget.placeId && 
                              currentParkingInfo.levelNumber == widget.levelNumber;

    return AlertDialog(
      title: Text(isCurrentlyParked ? 'Update Car Location' : 'Set Car Location'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Where did you park your car?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parkingSpaceController,
              decoration: const InputDecoration(
                labelText: 'Parking Space',
                hintText: 'e.g., B2-C102, A1-15, P3-42',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a parking space name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Place: ${widget.placeId}, Level: ${widget.levelNumber}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isCurrentlyParked)
          TextButton(
            onPressed: _isLoading ? null : _clearParkingInfo,
            child: const Text('Clear Location'),
          ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveParkingInfo,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isCurrentlyParked ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
