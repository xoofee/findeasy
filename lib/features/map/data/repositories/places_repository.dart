import 'dart:convert';
import 'dart:io';
import 'package:findeasy/features/map/data/datasources/places_remote_data_source.dart';
import 'package:findeasy/features/map/data/services/map_parser_service.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/exceptions.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:easyroute/easyroute.dart';

class PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;
  final MapParserService mapParserService;

  PlacesRepository({
    required this.remoteDataSource,
    required this.mapParserService,
  });

  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    return await remoteDataSource.getPlaces(center, maxDistance: maxDistance, limit: limit);
  }

  Future<String> downloadMap(int placeId) async {
    // Check cache first
    final cachedPath = await _checkCache(placeId);
    if (cachedPath != null) {
      return cachedPath;
    }
    
    // Download and cache
    final tempPath = await remoteDataSource.downloadMap(placeId);
    final finalPath = await _moveToCache(placeId, tempPath);
    await _saveCacheInfo(placeId, finalPath);
    
    return finalPath;
  }

  /// Download and parse map into PlaceMap object
  Future<PlaceMap> downloadAndParseMap(int placeId) async {
    // Download the map file
    final mapFilePath = await downloadMap(placeId);
    
      final rawMap = await loadOsmMap(mapFilePath);
      
      // Build PlaceMap from RawMap
      final (placeMap, _) = buildPlaceMap(rawMap);
    
    // Parse the .osm.gz file into PlaceMap object
    return await mapParserService.parseOsmGzFile(mapFilePath, placeId);
  }

  /// Get cached PlaceMap if available, otherwise download and parse
  Future<PlaceMap> getMap(int placeId) async {
    // Check if we have a cached PlaceMap
    final cachedPath = await _checkCache(placeId);
    if (cachedPath != null) {
      try {
        // Parse the cached file
        return await mapParserService.parseOsmGzFile(cachedPath, placeId);
      } catch (e) {
        print('Warning: Failed to parse cached map for place $placeId: $e');
        // Continue to download if parsing fails
      }
    }
    
    // Download and parse if not cached or parsing failed
    return await downloadAndParseMap(placeId);
  }

  Future<String?> _checkCache(int placeId) async {
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
          final (serverVersion, _) = await remoteDataSource.getPlaceMapInfo(placeId);

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
    await File(tempPath).copy(finalPath);
    await File(tempPath).delete(); // Clean up temp file
    
    return finalPath;
  }

  Future<void> _saveCacheInfo(int placeId, String mapPath) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      Directory mapDir = Directory(path.join(docDir.path, AppConstants.mapStorageFolder));
      String mapInfoPath = path.join(mapDir.path, '$placeId${AppConstants.mapInfoExtension}');
      
      final (serverVersion, updatedAt) = await remoteDataSource.getPlaceMapInfo(placeId);
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

  /// Get map info for a specific place
  Future<(int, DateTime)> getPlaceMapInfo(int placeId) async {
    return await remoteDataSource.getPlaceMapInfo(placeId);
  }

  /// Check if a map is cached for a specific place
  Future<bool> isMapCached(int placeId) async {
    final cachedPath = await _checkCache(placeId);
    return cachedPath != null;
  }

  /// Get the cached map path if it exists
  Future<String?> getCachedMapPath(int placeId) async {
    return await _checkCache(placeId);
  }
}