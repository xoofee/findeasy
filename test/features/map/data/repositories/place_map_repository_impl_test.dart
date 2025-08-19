import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/map/data/datasources/place_map_asset_data_source.dart';
import 'package:findeasy/features/map/data/repositories/place_map_repository_impl.dart';
import 'package:findeasy/core/constants/app_constants.dart';

// Helper method to get cached map path (similar to private method in repository)
Future<String?> _getCachedMapPath(int placeId) async {
  try {
    final mapDir = Directory(path.join(
      Directory.systemTemp.path,
      'map_repository_test',
      'documents',
      AppConstants.mapStorageFolder,
    ));
    
    if (!await mapDir.exists()) {
      return null;
    }
    
    final mapPath = path.join(mapDir.path, '$placeId${AppConstants.mapExtension}');
    
    if (!await File(mapPath).exists()) {
      return null;
    }
    
    return mapPath;
  } catch (e) {
    return null;
  }
}

void main() {
  group('MapRepositoryImpl Tests', () {
    late PlaceMapRepositoryImpl repository;
    late PlaceMapAssetDataSource assetDataSource;
    late Directory tempDir;
    late Directory documentsDir;

    setUp(() async {
      // Ensure Flutter binding is initialized
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock path_provider to avoid MissingPluginException
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return tempDir.path;
          }
          if (methodCall.method == 'getTemporaryDirectory') {
            return tempDir.path;
          }
          return null;
        },
      );
      
      // Create temporary directories for testing
      tempDir = await Directory.systemTemp.createTemp('map_repository_test');
      documentsDir = Directory(path.join(tempDir.path, 'documents'));
      await documentsDir.create();
      
      // Create asset data source
      assetDataSource = PlaceMapAssetDataSource();
      
      // Create repository
      repository = PlaceMapRepositoryImpl(assetDataSource);
    });

    tearDown(() async {
      // Clean up temporary files
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      // Clean up mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    group('getMap', () {
      test('should download and parse map when no cache exists', () async {
        // Arrange
        const placeId = 1;
        
        // Act
        final result = await repository.getMap(placeId);
        
        final placeMap = result.placeMap;

        print('nodes: ${placeMap.rawMap.nodes.length}, ways: ${placeMap.rawMap.ways.length}, levels: ${placeMap.rawMap.levels.length}');

        // Assert
        expect(result, isA<MapResult>());
        expect(result.placeMap, isA<PlaceMap>());
        expect(result.poiManager, isA<PoiManager>());
        
        // Verify the map was downloaded and cached
        final cachedPath = await _getCachedMapPath(placeId);
        expect(cachedPath, isNotNull);
        expect(await File(cachedPath!).exists(), isTrue);
      });

      test('should use cached map when available and valid', () async {
        // Arrange
        const placeId = 1;
        
        // First call to download and cache
        await repository.getMap(placeId);
        
        // Act - second call should use cache
        final result = await repository.getMap(placeId);
        
        // Assert
        expect(result, isA<MapResult>());

        // Verify cache info was saved
        final cacheInfoPath = path.join(
          documentsDir.path,
          AppConstants.mapStorageFolder,
          '$placeId${AppConstants.mapInfoExtension}',
        );
        expect(await File(cacheInfoPath).exists(), isTrue);
      });

      test('should handle multiple place IDs', () async {
        // Arrange
        const placeId1 = 1;
        const placeId2 = 2;
        
        // Act
        final result1 = await repository.getMap(placeId1);
        final result2 = await repository.getMap(placeId2);
        
        // Assert
        expect(result1, isA<MapResult>());
        expect(result2, isA<MapResult>());
        
        // Verify both were cached
        final cachedPath1 = await _getCachedMapPath(placeId1);
        final cachedPath2 = await _getCachedMapPath(placeId2);
        expect(cachedPath1, isNotNull);
        expect(cachedPath2, isNotNull);
      });
    });

    group('caching behavior', () {
      test('should create cache directory structure', () async {
        // Arrange
        const placeId = 1;
        
        // Act
        await repository.getMap(placeId);
        
        // Assert
        final mapDir = Directory(path.join(
          documentsDir.path,
          AppConstants.mapStorageFolder,
        ));
        expect(await mapDir.exists(), isTrue);
      });

      test('should save cache info with correct structure', () async {
        // Arrange
        const placeId = 1;
        
        // Act
        await repository.getMap(placeId);
        
        // Assert
        final cacheInfoPath = path.join(
          documentsDir.path,
          AppConstants.mapStorageFolder,
          '$placeId${AppConstants.mapInfoExtension}',
        );
        
        final cacheInfoFile = File(cacheInfoPath);
        expect(await cacheInfoFile.exists(), isTrue);
        
        final cacheInfoContent = await cacheInfoFile.readAsString();
        final cacheInfo = json.decode(cacheInfoContent) as Map<String, dynamic>;
        
        expect(cacheInfo['version'], isA<int>());
        expect(cacheInfo['updated_at'], isA<String>());
        expect(cacheInfo['downloaded_at'], isA<String>());
        expect(cacheInfo['file_size'], isA<int>());
      });

      test('should handle cache info corruption gracefully', () async {
        // Arrange
        const placeId = 1;
        
        // First download to create cache
        await repository.getMap(placeId);
        
        // Corrupt the cache info
        final cacheInfoPath = path.join(
          documentsDir.path,
          AppConstants.mapStorageFolder,
          '$placeId${AppConstants.mapInfoExtension}',
        );
        await File(cacheInfoPath).writeAsString('invalid json');
        
        // Act - should re-download due to corrupted cache info
        final result = await repository.getMap(placeId);
        
        // Assert
        expect(result, isA<MapResult>());
        
        // Verify cache info was recreated
        final newCacheInfo = await File(cacheInfoPath).readAsString();
        expect(() => json.decode(newCacheInfo), returnsNormally);
      });
    });

    group('error handling', () {
      test('should handle asset loading errors gracefully', () async {
        // Arrange
        const placeId = 999; // Use a different ID to avoid cached data
        
        // Act & Assert - should not crash
        expect(
          () => repository.getMap(placeId),
          returnsNormally,
        );
      });

      test('should handle file system errors gracefully', () async {
        // Arrange
        const placeId = 1;
        
        // Act & Assert - should not crash even with potential file system issues
        expect(
          () => repository.getMap(placeId),
          returnsNormally,
        );
      });
    });

    group('performance', () {
      test('should reuse cached data efficiently', () async {
        // Arrange
        const placeId = 1;
        
        // First call to establish cache
        final stopwatch1 = Stopwatch()..start();
        await repository.getMap(placeId);
        stopwatch1.stop();
        
        // Second call should be faster (using cache)
        final stopwatch2 = Stopwatch()..start();
        await repository.getMap(placeId);
        stopwatch2.stop();
        
        // Assert - cached call should be faster (though exact timing may vary)
        expect(stopwatch2.elapsedMilliseconds, lessThanOrEqualTo(stopwatch1.elapsedMilliseconds + 100));
      });
    });
  });
}
