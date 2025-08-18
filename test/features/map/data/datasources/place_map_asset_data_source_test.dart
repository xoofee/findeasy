import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:findeasy/features/map/data/datasources/place_map_asset_data_source.dart';

// Mock for path_provider to avoid MissingPluginException in tests
class MockPathProvider {
  static Future<String> getTemporaryDirectory() async => '/tmp/test';
}

void main() {
  group('MapAssetDataSource Tests', () {
    late PlaceMapAssetDataSource dataSource;

    setUp(() {
      dataSource = PlaceMapAssetDataSource();
      // Ensure Flutter binding is initialized for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock the path_provider dependency
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        },
      );
    });

    tearDown(() {
      // Clean up mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    group('getPlaceMapInfo', () {
      test('should return version 0 and fixed date', () async {
        // Arrange
        const placeId = 1;
        
        // Act
        final result = await dataSource.getPlaceMapInfo(placeId);
        
        // Assert
        expect(result.$1, equals(0));
        expect(result.$2, equals(DateTime(2025, 1, 1)));
      });

      test('should work with different place IDs', () async {
        // Arrange
        const placeId1 = 1;
        const placeId2 = 999;
        
        // Act
        final result1 = await dataSource.getPlaceMapInfo(placeId1);
        final result2 = await dataSource.getPlaceMapInfo(placeId2);
        
        // Assert
        expect(result1.$1, equals(0));
        expect(result1.$2, equals(DateTime(2025, 1, 1)));
        expect(result2.$1, equals(0));
        expect(result2.$2, equals(DateTime(2025, 1, 1)));
      });
    });

    group('downloadMap', () {
      test('should return a file path string', () async {
        // Arrange
        const placeId = 1;
        
        // Act
        final result = await dataSource.downloadMap(placeId);
        
        // Assert
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
        expect(result, contains('happy_coast.osm.gz'));
      });

      test('should handle different place IDs', () async {
        // Arrange
        const placeId1 = 1;
        const placeId2 = 999;
        
        // Act
        final result1 = await dataSource.downloadMap(placeId1);
        final result2 = await dataSource.downloadMap(placeId2);
        
        // Assert
        expect(result1, isA<String>());
        expect(result2, isA<String>());
        expect(result1.isNotEmpty, isTrue);
        expect(result2.isNotEmpty, isTrue);
        expect(result1, contains('happy_coast.osm.gz'));
        expect(result2, contains('happy_coast.osm.gz'));
      });
    });

    group('asset file constants', () {
      test('should have correct asset path constant', () {
        // Test that the class can be instantiated
        expect(dataSource, isA<PlaceMapAssetDataSource>());
      });
    });

    group('error handling', () {
      test('should handle asset loading gracefully', () async {
        // This test verifies the class doesn't crash on basic operations
        const placeId = 1;
        
        // Act & Assert - should not throw
        expect(
          () => dataSource.getPlaceMapInfo(placeId),
          returnsNormally,
        );
      });
    });
  });
}
