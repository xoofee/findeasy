import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling storage operations using SharedPreferences
class StorageService {
  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _encryptionKeyKey = 'encryption_key';
  
  // Non-sensitive data keys
  static const String _navigationHistoryKey = 'navigation_history';
  static const String _lastLocationKey = 'last_location';
  static const String _appSettingsKey = 'app_settings';
  static const String _recentPlacesKey = 'recent_places';
  static const String _mapPreferencesKey = 'map_preferences';
  static const String _voiceSettingsKey = 'voice_settings';
  static const String _carParkingInfoKey = 'car_parking_info';

  // ===== SHARED PREFERENCES STORAGE =====

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Save encryption key
  Future<void> saveEncryptionKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_encryptionKeyKey, key);
  }

  /// Get encryption key
  Future<String?> getEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_encryptionKeyKey);
  }

  /// Save navigation history
  Future<void> saveNavigationHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_navigationHistoryKey, history);
  }

  /// Get navigation history
  Future<List<String>> getNavigationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_navigationHistoryKey) ?? [];
  }

  /// Save last known location
  Future<void> saveLastLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final locationData = {'lat': lat, 'lng': lng};
    await prefs.setString(_lastLocationKey, jsonEncode(locationData));
  }

  /// Get last known location
  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationString = prefs.getString(_lastLocationKey);
    if (locationString != null) {
      final decoded = jsonDecode(locationString) as Map<String, dynamic>;
      return {
        'lat': decoded['lat'] as double,
        'lng': decoded['lng'] as double,
      };
    }
    return null;
  }

  /// Save app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appSettingsKey, jsonEncode(settings));
  }

  /// Get app settings
  Future<Map<String, dynamic>> getAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_appSettingsKey);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return {};
  }

  /// Save recent places
  Future<void> saveRecentPlaces(List<Map<String, dynamic>> places) async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = places.map((place) => jsonEncode(place)).toList();
    await prefs.setStringList(_recentPlacesKey, placesJson);
  }

  /// Get recent places
  Future<List<Map<String, dynamic>>> getRecentPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = prefs.getStringList(_recentPlacesKey) ?? [];
    return placesJson
        .map((placeString) => jsonDecode(placeString) as Map<String, dynamic>)
        .toList();
  }

  /// Save map preferences
  Future<void> saveMapPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mapPreferencesKey, jsonEncode(preferences));
  }

  /// Get map preferences
  Future<Map<String, dynamic>> getMapPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsString = prefs.getString(_mapPreferencesKey);
    if (prefsString != null) {
      return jsonDecode(prefsString) as Map<String, dynamic>;
    }
    return {};
  }

  /// Save voice settings
  Future<void> saveVoiceSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voiceSettingsKey, jsonEncode(settings));
  }

  /// Get voice settings
  Future<Map<String, dynamic>> getVoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_voiceSettingsKey);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return {};
  }

  /// Save car parking information
  Future<void> saveCarParkingInfo(Map<String, dynamic> parkingInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_carParkingInfoKey, jsonEncode(parkingInfo));
  }

  /// Get car parking information
  Future<Map<String, dynamic>?> getCarParkingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final parkingInfoString = prefs.getString(_carParkingInfoKey);
    if (parkingInfoString != null) {
      return jsonDecode(parkingInfoString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear car parking information
  Future<void> clearCarParkingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_carParkingInfoKey);
  }

  // ===== UTILITY METHODS =====

  /// Save complete login information
  Future<void> saveLoginInfo({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      saveAuthToken(token),
      saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(email),
    ]);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all secure data (logout)
  Future<void> clearSecureData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_encryptionKeyKey);
  }

  /// Clear all non-sensitive data
  Future<void> clearNonSensitiveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_navigationHistoryKey);
    await prefs.remove(_lastLocationKey);
    await prefs.remove(_appSettingsKey);
    await prefs.remove(_recentPlacesKey);
    await prefs.remove(_mapPreferencesKey);
    await prefs.remove(_voiceSettingsKey);
    await prefs.remove(_carParkingInfoKey);
  }

  /// Clear all data (complete reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get all stored data for debugging
  Future<Map<String, dynamic>> getAllStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsData = prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
      map[key] = prefs.get(key);
      return map;
    });

    return {
      'preferences': prefsData,
    };
  }
}
