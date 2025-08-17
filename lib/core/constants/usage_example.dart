import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../network/dio_client.dart';

/// Example usage of API constants in repository or service classes
/// 
/// This file demonstrates how to properly use the API constants
/// in your data layer classes.
class ExampleApiService {
  final DioClient _dioClient;

  ExampleApiService(this._dioClient);

  /// Example: Get places from API
  Future<List<Map<String, dynamic>>> getPlaces() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.places);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? ApiConstants.networkErrorMessage);
    }
  }

  /// Example: Authenticate user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.auth,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Set auth token if login successful
      final token = response.data['token'];
      if (token != null) {
        _dioClient.setAuthToken(token);
      }
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? ApiConstants.networkErrorMessage);
    }
  }

  /// Example: Get POI data
  Future<Map<String, dynamic>> getPoiData(String poiId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.poi}/$poiId',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? ApiConstants.networkErrorMessage);
    }
  }

}

/// Example: Using API constants in a repository implementation
class ExampleRepository {
  final ExampleApiService _apiService;

  ExampleRepository(this._apiService);

  /// Example: Repository method that uses the service
  Future<List<Map<String, dynamic>>> fetchPlaces() async {
    return await _apiService.getPlaces();
  }
}

/// Example: Using API constants in a provider/notifier
class ExampleProvider {
  final ExampleRepository _repository;

  ExampleProvider(this._repository);

  /// Example: Provider method that uses the repository
  Future<void> loadPlaces() async {
    try {
      final places = await _repository.fetchPlaces();
      // Handle the data
      print('Loaded ${places.length} places');
    } catch (e) {
      // Handle error
      print('Error loading places: $e');
    }
  }
}
