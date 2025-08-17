/*

PlacesRemoteDataSource (compared to RemotePlacesDataSource) keeps feature name first (Places) → easier to find when browsing code, since everything related to Places is grouped.

*/

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/map/data/datasources/places_data_source.dart';
import 'package:findeasy/features/map/domain/entities/place.dart';
import 'package:findeasy/features/map/domain/exceptions.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PlacesRemoteDataSource implements PlacesDataSource{
  final Dio _dio;
  final String _baseUrl; 

  PlacesRemoteDataSource({required Dio dio, required String baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  // Get nearby places
  Future<List<Place>> getPlaces(latlong2.LatLng center, {double maxDistance = 500.0, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/places_near',
        queryParameters: {
          'lat': center.latitude,
          'lon': center.longitude,
          'max_distance': maxDistance,
        },
      );
      List<Place> places = [];
      for (var place in response.data) {
        places.add(Place.fromJson(place));
      }
      return places;
    } catch (e) {
      throw PlacesException("Failed to load nearby places");
    }
  }

  Future<String> downloadMap(int placeId) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      Directory mapDir = Directory(path.join(docDir.path, AppConstants.mapStorageFolder));
      
      // Ensure the maps directory exists
      if (!await mapDir.exists()) {
        await mapDir.create(recursive: true);
      }
      
      String mapPath = path.join(mapDir.path, '$placeId${AppConstants.mapExtension}');
      String mapInfoPath = path.join(mapDir.path, '$placeId${AppConstants.mapInfoExtension}');

      // Check cache with proper async operations
      if (await File(mapPath).exists()) {
        try {
          // Load version info from file
          if (await File(mapInfoPath).exists()) {
            String mapInfoContent = await File(mapInfoPath).readAsString();
            Map<String, dynamic> mapInfo = json.decode(mapInfoContent);
            final int localVersion = mapInfo['version'] as int;
            final (serverVersion, _) = await getPlaceMapInfo(placeId);

            if (localVersion == serverVersion) {
              return mapPath;
            }
          }
        } catch (e) {
          // If map info is corrupted, continue with download
          print('Warning: Corrupted map info for place $placeId, re-downloading: $e');
        }
      }

      final url = await getPlaceMapUrl(placeId);
      
      // Download the map file
      await _dio.download(url, mapPath);
      
      // Verify the downloaded file exists and has content
      File downloadedFile = File(mapPath);
      if (!await downloadedFile.exists() || await downloadedFile.length() == 0) {
        throw PlacesException("Downloaded map file is empty or missing for place $placeId");
      }

      // Save map info for future cache checks
      try {
        final (serverVersion, updatedAt) = await getPlaceMapInfo(placeId);
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

      return mapPath;

      // TODO: decrypt map file in the future if encrypted on server.
    } catch (e) {
      throw PlacesException("Failed to download map $placeId: $e");
    }
  }

  Future<(int, DateTime)> getPlaceMapInfo(int placeId) async {
    try {
      final response = await _dio.get('$_baseUrl/places/$placeId/map_info');

      return (response.data['version'] as int, response.data['updated_at'] as DateTime);
    } catch (e) {
      throw PlacesException("Failed to load place map info $placeId: $e");
    }
  }

  Future<String> getPlaceMapUrl(int placeId) async {
    try {
      final response = await _dio.get('$_baseUrl/places/$placeId/map_url');

      return response.data['url'] as String;
    } catch (e) {
      throw PlacesException("Failed to load place map url $placeId: $e");
    }
  }

  // Get all places
  // Future<List<Place>> getAllPlaces() async {
  //   try {
  //     final response = await _dio.get('$_baseUrl/places/');
  //     List<Place> places = [];
  //     for (var place in response.data) {
  //       places.add(Place.fromJson(place));
  //     }
  //     return places;
  //   } catch (e) {
  //     throw Exception("Failed to load places");
  //   }
  // }

  // Create a new place
  // Future<Place> createPlace(Place place) async {
  //   try {
  //     final response = await _dio.post(
  //       '$_baseUrl/places/',
  //       data: json.encode(place.toJson()),
  //     );
  //     return Place.fromJson(response.data);
  //   } catch (e) {
  //     throw PlacesException("Failed to create place");
  //   }
  // }

  // Get a place by ID
  // Future<Place> getPlaceById(String placeId) async {
  //   try {
  //     final response = await _dio.get('$_baseUrl/places/$placeId');
  //     return Place.fromJson(response.data);
  //   } catch (e) {
  //     throw Exception("Failed to load place");
  //   }
  // }

  // Delete a place by ID
  // Future<void> deletePlace(String placeId) async {
  //   try {
  //     await _dio.delete('$_baseUrl/places/$placeId');
  //   } catch (e) {
  //     throw Exception("Failed to delete place");
  //   }
  // }


}
