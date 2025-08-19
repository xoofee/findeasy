import 'dart:convert';
import 'dart:io';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/map/data/datasources/place_map_data_source.dart';
import 'package:findeasy/features/map/domain/repositories/place_map_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PlaceMapRepositoryImpl implements PlaceMapRepository {
  final PlaceMapDataSource placeMapDataSource;

  PlaceMapRepositoryImpl(this.placeMapDataSource);

  /// Get cached PlaceMap if available, otherwise download and parse
  @override
  Future<MapResult> getMap(int placeId) async {
    // Check if we have a cached PlaceMap
    final cachedPath = await _getCachedMapPath(placeId);
    if (cachedPath != null) {
      try {
            // Parse the cached file
        final mapResult = await loadMapFromOsmFile(cachedPath);
        
        return mapResult;
      } catch (e) {
        print('Warning: Failed to parse cached map for place $placeId: $e');
        // Continue to download if parsing fails
      }
    }
    
    // Download and parse if not cached or parsing failed
    final mapResult = await _downloadAndParseMap(placeId);
    return mapResult;
  }

  Future<String> _downloadMap(int placeId) async {
    // Check cache first
    final cachedPath = await _getCachedMapPath(placeId);
    if (cachedPath != null) {
      return cachedPath;
    }
    
    // Download and cache
    final tempPath = await placeMapDataSource.downloadMap(placeId);
    final finalPath = await _moveToCache(placeId, tempPath);
    await _saveCacheInfo(placeId, finalPath);
    
    return finalPath;
  }

  /// Download and parse map into PlaceMap object
  Future<MapResult> _downloadAndParseMap(int placeId) async {
    // Download the map file
    final mapFilePath = await _downloadMap(placeId);
    
    final mapResult = await loadMapFromOsmFile(mapFilePath);
    
    return mapResult;
  }

  Future<String?> _getCachedMapPath(int placeId) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      Directory mapDir = Directory(path.join(docDir.path, AppConstants.mapStorageFolder));
      
      if (!await mapDir.exists()) {
        return null;
      }
      
      String mapPath = path.join(mapDir.path, '$placeId${AppConstants.mapExtension}');
      String mapInfoPath = path.join(mapDir.path, '$placeId${AppConstants.mapInfoExtension}');

      // Check if map file exists
      if (!await File(mapPath).exists()) {
        return null;
      }

      // Check if map info exists and is valid
      if (await File(mapInfoPath).exists()) {
        try {
          String mapInfoContent = await File(mapInfoPath).readAsString();
          Map<String, dynamic> mapInfo = json.decode(mapInfoContent);
          final int localVersion = mapInfo['version'] as int;
          final (serverVersion, _) = await placeMapDataSource.getPlaceMapInfo(placeId);

          if (localVersion == serverVersion) {
            return mapPath;
          }
        } catch (e) {
          print('Warning: Corrupted map info for place $placeId, re-downloading: $e');
        }
      }
      
      return null;
    } catch (e) {
      print('Warning: Cache check failed for place $placeId: $e');
      return null;
    }
  }

  Future<String> _moveToCache(int placeId, String tempPath) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory(path.join(docDir.path, AppConstants.mapStorageFolder));
    
    // Ensure the maps directory exists
    if (!await mapDir.exists()) {
      await mapDir.create(recursive: true);
    }
    
    String finalPath = path.join(mapDir.path, '$placeId${AppConstants.mapExtension}');
    
    // Move from temp to final location
    await File(tempPath).rename(finalPath);
    
    return finalPath;
  }

  Future<void> _saveCacheInfo(int placeId, String mapPath) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      Directory mapDir = Directory(path.join(docDir.path, AppConstants.mapStorageFolder));
      String mapInfoPath = path.join(mapDir.path, '$placeId${AppConstants.mapInfoExtension}');
      
      final (serverVersion, updatedAt) = await placeMapDataSource.getPlaceMapInfo(placeId);
      File downloadedFile = File(mapPath);
      
      Map<String, dynamic> mapInfo = {
        'version': serverVersion,
        'updated_at': updatedAt.toIso8601String(),
        'downloaded_at': DateTime.now().toIso8601String(),
        'file_size': await downloadedFile.length(),
      };
      
      await File(mapInfoPath).writeAsString(json.encode(mapInfo));
    } catch (e) {
      print('Warning: Could not save map info for place $placeId: $e');
      // Don't fail the download if we can't save metadata
    }
  }



}