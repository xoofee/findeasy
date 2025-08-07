import 'app_constants.dart';

/// API Constants for the FindEasy application
/// 
/// This file contains all API-related constants including base URLs,
/// endpoints, and configuration values.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // Base URLs for different environments
  static const String _devBaseUrl = 'http://localhost:3000';
  static const String _stagingBaseUrl = 'https://staging-api.findeasy.com';
  static const String _productionBaseUrl = 'https://api.findeasy.com';

  /// Get the base URL based on the current environment
  /// 
  /// Uses Flutter's built-in environment detection (kDebugMode, kReleaseMode)
  /// to automatically switch between development and production URLs.
  static String get baseUrl {
    if (AppConstants.isDebug) {
      return _devBaseUrl;
    } else if (AppConstants.isProfile) {
      return _stagingBaseUrl;
    } else {
      return _productionBaseUrl;
    }
  }

  /// API Endpoints
  static const String auth = '/auth';
  static const String places = '/places';
  static const String navigation = '/navigation';
  static const String feedback = '/feedback';
  static const String maps = '/maps';
  static const String poi = '/poi';

  /// Complete API URLs
  static String get authUrl => '$baseUrl$auth';
  static String get placesUrl => '$baseUrl$places';
  static String get navigationUrl => '$baseUrl$navigation';
  static String get feedbackUrl => '$baseUrl$feedback';
  static String get mapsUrl => '$baseUrl$maps';
  static String get poiUrl => '$baseUrl$poi';

  /// API Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  /// Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  /// Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String timeoutErrorMessage = 'Request timed out';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unauthorizedErrorMessage = 'Unauthorized access';
  static const String forbiddenErrorMessage = 'Access forbidden';
  static const String notFoundErrorMessage = 'Resource not found';
}
