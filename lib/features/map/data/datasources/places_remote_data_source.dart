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
      final url = await getPlaceMapUrl(placeId);
      final tempPath = await _downloadToTemp(url, placeId);
      return tempPath;
    } catch (e) {
      throw PlacesException("Failed to download map $placeId: $e");
    }
  }

  Future<String> _downloadToTemp(String url, int placeId) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = path.join(tempDir.path, 'map_$placeId${AppConstants.mapExtension}');
    
    // Download the map file to temporary location
    await _dio.download(url, tempPath);
    
    // Verify the downloaded file exists and has content
    File downloadedFile = File(tempPath);
    if (!await downloadedFile.exists() || await downloadedFile.length() == 0) {
      throw PlacesException("Downloaded map file is empty or missing for place $placeId");
    }
    
    return tempPath;
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
