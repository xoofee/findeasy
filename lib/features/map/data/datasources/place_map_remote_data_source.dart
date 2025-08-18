import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findeasy/core/constants/app_constants.dart';
import 'package:findeasy/features/map/data/datasources/place_map_data_source.dart';
import 'package:findeasy/features/map/domain/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PlaceMapRemoteDataSource implements PlaceMapDataSource {
  final Dio _dio;
  final String _baseUrl;

  PlaceMapRemoteDataSource({required Dio dio, required String baseUrl}) : _dio = dio, _baseUrl = baseUrl;


  @override
  Future<(int, DateTime)> getPlaceMapInfo(int placeId) async {
    try {
      final response = await _dio.get('$_baseUrl/places/$placeId/map_info');

      return (response.data['version'] as int, response.data['updated_at'] as DateTime);
    } catch (e) {
      throw PlacesException("Failed to load place map info $placeId: $e");
    }
  }


  /// Returns path to the downloaded map file
  @override
  Future<String> downloadMap(int placeId) async {
    try {
      final url = await _getPlaceMapUrl(placeId);
      final tempPath = await _downloadToTemp(url, placeId);
      return tempPath;
    } catch (e) {
      throw PlacesException("Failed to download map $placeId: $e");
    }
  }

  Future<String> _getPlaceMapUrl(int placeId) async {
    try {
      final response = await _dio.get('$_baseUrl/places/$placeId/map_url');

      return response.data['url'] as String;
    } catch (e) {
      throw PlacesException("Failed to load place map url $placeId: $e");
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

}