import 'package:flutter/foundation.dart';

/// Application Constants for the FindEasy application
/// 
/// This file contains general application constants and configuration
/// that are used throughout the app.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Environment Configuration
  static const bool isDebug = kDebugMode;
  static const bool isRelease = kReleaseMode;
  static const bool isProfile = kProfileMode;

  /// App Information
  static const String appName = 'FindEasy';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  /// API Configuration
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  /// Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String mapDataKey = 'map_data';

  /// Cache Configuration
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 30);
  static const Duration longCacheDuration = Duration(days: 7);

  /// Map Configuration
  static const double defaultZoomLevel = 15.0;
  static const double minZoomLevel = 10.0;
  static const double maxZoomLevel = 20.0;
  static const double defaultSearchRadius = 5000.0; // 5km in meters

  /// Navigation Configuration
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const Duration deviationCheckInterval = Duration(seconds: 10);
  static const double deviationThreshold = 50.0; // meters

  /// Voice Configuration
  static const String defaultLanguage = 'en-US';
  static const double defaultSpeechRate = 0.5;
  static const double defaultPitch = 1.0;

  /// UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;

  /// Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String locationErrorMessage = 'Unable to get your location. Please enable location services.';
  static const String permissionErrorMessage = 'Permission denied. Please grant the required permissions.';

  /// Success Messages
  static const String loginSuccessMessage = 'Successfully logged in';
  static const String logoutSuccessMessage = 'Successfully logged out';
  static const String dataSavedMessage = 'Data saved successfully';
  static const String routeCalculatedMessage = 'Route calculated successfully';

  /// Validation Messages
  static const String emailRequiredMessage = 'Email is required';
  static const String passwordRequiredMessage = 'Password is required';
  static const String invalidEmailMessage = 'Please enter a valid email address';
  static const String passwordTooShortMessage = 'Password must be at least 6 characters';
  static const String locationRequiredMessage = 'Location is required';

  /// Feature Flags
  static const bool enableVoiceNavigation = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
