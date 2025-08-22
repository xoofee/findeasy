import 'package:flutter_test/flutter_test.dart';
import 'package:findeasy/features/nav/domain/entities/car_parking_info.dart';

void main() {
  group('CarParkingInfo', () {
    test('should create CarParkingInfo with all required fields', () {
      final parkingInfo = CarParkingInfo(
        placeId: 123,
        levelNumber: -1.0,
        parkingSpaceName: 'B2-C102',
        parkedAt: DateTime(2024, 1, 1, 10, 0),
      );

      expect(parkingInfo.placeId, equals(123));
      expect(parkingInfo.levelNumber, equals(-1.0));
      expect(parkingInfo.parkingSpaceName, equals('B2-C102'));
      expect(parkingInfo.parkedAt, equals(DateTime(2024, 1, 1, 10, 0)));
    });

    test('should create CarParkingInfo with different level numbers', () {
      final parkingInfo1 = CarParkingInfo(
        placeId: 123,
        levelNumber: 0.0,
        parkingSpaceName: 'Ground Floor',
        parkedAt: DateTime.now(),
      );

      final parkingInfo2 = CarParkingInfo(
        placeId: 123,
        levelNumber: 1.0,
        parkingSpaceName: 'First Floor',
        parkedAt: DateTime.now(),
      );

      expect(parkingInfo1.levelNumber, equals(0.0));
      expect(parkingInfo2.levelNumber, equals(1.0));
      expect(parkingInfo1.levelNumber, isNot(equals(parkingInfo2.levelNumber)));
    });

    test('should create CarParkingInfo with various parking space names', () {
      final parkingSpaces = [
        'A1-15',
        'B2-C102',
        'P3-42',
        'Level 1-A',
        'Underground-B3',
      ];

      for (final spaceName in parkingSpaces) {
        final parkingInfo = CarParkingInfo(
          placeId: 123,
          levelNumber: 0.0,
          parkingSpaceName: spaceName,
          parkedAt: DateTime.now(),
        );

        expect(parkingInfo.parkingSpaceName, equals(spaceName));
      }
    });

    test('should handle different place IDs', () {
      final placeIds = [1, 100, 999, 12345];

      for (final placeId in placeIds) {
        final parkingInfo = CarParkingInfo(
          placeId: placeId,
          levelNumber: 0.0,
          parkingSpaceName: 'Test Space',
          parkedAt: DateTime.now(),
        );

        expect(parkingInfo.placeId, equals(placeId));
      }
    });
  });
}
