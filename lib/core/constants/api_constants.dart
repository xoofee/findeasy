import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants for the FindEasy application
/// 
/// This file contains all API-related constants including base URLs,
/// endpoints, and configuration values.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // Base URLs from environment variables
  static String get _devBaseUrl => dotenv.env['DEV_API_URL'] ?? 'http://localhost:3000';
  static String get _stagingBaseUrl => dotenv.env['STAGING_API_URL'] ?? 'https://staging-api.findeasy.com';
  static String get _productionBaseUrl => dotenv.env['PRODUCTION_API_URL'] ?? 'https://api.findeasy.com';

  static String get _env => dotenv.env['ENV'] ?? 'dev';


  /// Get the base URL based on the current environment
  /// 
  /// Uses Flutter's built-in environment detection (kDebugMode, kReleaseMode)
  /// to automatically switch between development and production URLs.
  static String get baseUrl {
    if (_env == 'dev') {
      return _devBaseUrl;
    } else if (_env == 'staging') {
      return _stagingBaseUrl;
    } else {
      return _productionBaseUrl;  // production
    }
  }

  /// API Endpoints
  static const String auth = '/auth';
  static const String places = '/places';
  static const String feedback = '/feedback';
  static const String poi = '/poi';

  /// Complete API URLs
  static String get authUrl => '$baseUrl$auth';
  static String get placesUrl => '$baseUrl$places';
  static String get feedbackUrl => '$baseUrl$feedback';
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
