import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:findeasy/core/services/storage_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// ===== SECURE DATA PROVIDERS =====

// Auth token provider
final authTokenProvider = StateProvider<String?>((ref) => null);

// Refresh token provider
final refreshTokenProvider = StateProvider<String?>((ref) => null);

// User ID provider
final userIdProvider = StateProvider<String?>((ref) => null);

// User email provider
final userEmailProvider = StateProvider<String?>((ref) => null);

// Encryption key provider
final encryptionKeyProvider = StateProvider<String?>((ref) => null);

// ===== NON-SENSITIVE DATA PROVIDERS =====

// Navigation history provider
final navigationHistoryProvider = StateProvider<List<String>>((ref) => []);

// Last location provider
final lastLocationProvider = StateProvider<Map<String, double>?>((ref) => null);

// App settings provider
final appSettingsProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// Recent places provider
final recentPlacesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

// Map preferences provider
final mapPreferencesProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// Voice settings provider
final voiceSettingsProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// ===== COMPOSED PROVIDERS =====

// Login state provider
final isLoggedInProvider = Provider<bool>((ref) {
  final token = ref.watch(authTokenProvider);
  return token != null && token.isNotEmpty;
});

// User info provider
final userInfoProvider = Provider<Map<String, String?>>((ref) {
  return {
    'userId': ref.watch(userIdProvider),
    'email': ref.watch(userEmailProvider),
    'token': ref.watch(authTokenProvider),
  };
});

// ===== STORAGE MANAGER PROVIDER =====

final storageManagerProvider = Provider<StorageManager>((ref) {
  return StorageManager(ref);
});

/// Manages storage operations and state synchronization
class StorageManager {
  final Ref _ref;
  
  StorageManager(this._ref);

  /// Initialize app data on startup
  Future<void> initializeAppData() async {
    final storage = _ref.read(storageServiceProvider);
    
    // Restore secure data
    final token = await storage.getAuthToken();
    if (token != null) {
      _ref.read(authTokenProvider.notifier).state = token;
    }
    
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken != null) {
      _ref.read(refreshTokenProvider.notifier).state = refreshToken;
    }
    
    final userId = await storage.getUserId();
    if (userId != null) {
      _ref.read(userIdProvider.notifier).state = userId;
    }
    
    final email = await storage.getUserEmail();
    if (email != null) {
      _ref.read(userEmailProvider.notifier).state = email;
    }
    
    final encryptionKey = await storage.getEncryptionKey();
    if (encryptionKey != null) {
      _ref.read(encryptionKeyProvider.notifier).state = encryptionKey;
    }
    
    // Restore non-sensitive data
    final history = await storage.getNavigationHistory();
    _ref.read(navigationHistoryProvider.notifier).state = history;
    
    final lastLocation = await storage.getLastLocation();
    _ref.read(lastLocationProvider.notifier).state = lastLocation;
    
    final settings = await storage.getAppSettings();
    _ref.read(appSettingsProvider.notifier).state = settings;
    
    final recentPlaces = await storage.getRecentPlaces();
    _ref.read(recentPlacesProvider.notifier).state = recentPlaces;
    
    final mapPrefs = await storage.getMapPreferences();
    _ref.read(mapPreferencesProvider.notifier).state = mapPrefs;
    
    final voiceSettings = await storage.getVoiceSettings();
    _ref.read(voiceSettingsProvider.notifier).state = voiceSettings;
  }

  /// Save login information
  Future<void> saveLoginInfo({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    final storage = _ref.read(storageServiceProvider);
    
    // Update state
    _ref.read(authTokenProvider.notifier).state = token;
    _ref.read(refreshTokenProvider.notifier).state = refreshToken;
    _ref.read(userIdProvider.notifier).state = userId;
    _ref.read(userEmailProvider.notifier).state = email;
    
    // Save to storage
    await storage.saveLoginInfo(
      token: token,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
    );
  }

  /// Add to navigation history
  Future<void> addToNavigationHistory(String destination) async {
    final storage = _ref.read(storageServiceProvider);
    final currentHistory = _ref.read(navigationHistoryProvider);
    
    // Add new destination to the beginning, keep last 10
    final newHistory = [destination, ...currentHistory.take(9)];
    
    // Update state
    _ref.read(navigationHistoryProvider.notifier).state = newHistory;
    
    // Save to storage
    await storage.saveNavigationHistory(newHistory);
  }

  /// Save app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    final storage = _ref.read(storageServiceProvider);
    
    // Update state
    _ref.read(appSettingsProvider.notifier).state = settings;
    
    // Save to storage
    await storage.saveAppSettings(settings);
  }

  /// Save map preferences
  Future<void> saveMapPreferences(Map<String, dynamic> preferences) async {
    final storage = _ref.read(storageServiceProvider);
    
    // Update state
    _ref.read(mapPreferencesProvider.notifier).state = preferences;
    
    // Save to storage
    await storage.saveMapPreferences(preferences);
  }

  /// Save voice settings
  Future<void> saveVoiceSettings(Map<String, dynamic> settings) async {
    final storage = _ref.read(storageServiceProvider);
    
    // Update state
    _ref.read(voiceSettingsProvider.notifier).state = settings;
    
    // Save to storage
    await storage.saveVoiceSettings(settings);
  }

  /// Logout - clear all data
  Future<void> logout() async {
    final storage = _ref.read(storageServiceProvider);
    
    // Clear all state
    _ref.read(authTokenProvider.notifier).state = null;
    _ref.read(refreshTokenProvider.notifier).state = null;
    _ref.read(userIdProvider.notifier).state = null;
    _ref.read(userEmailProvider.notifier).state = null;
    _ref.read(encryptionKeyProvider.notifier).state = null;
    
    // Clear storage
    await storage.clearAllData();
  }

  /// Save last location
  Future<void> saveLastLocation(double lat, double lng) async {
    final storage = _ref.read(storageServiceProvider);
    final location = {'lat': lat, 'lng': lng};
    
    // Update state
    _ref.read(lastLocationProvider.notifier).state = location;
    
    // Save to storage
    await storage.saveLastLocation(lat, lng);
  }

  /// Add recent place
  Future<void> addRecentPlace(Map<String, dynamic> place) async {
    final storage = _ref.read(storageServiceProvider);
    final currentPlaces = _ref.read(recentPlacesProvider);
    
    // Remove if already exists, add to beginning, keep last 5
    final filteredPlaces = currentPlaces.where((p) => p['id'] != place['id']).toList();
    final newPlaces = [place, ...filteredPlaces.take(4)];
    
    // Update state
    _ref.read(recentPlacesProvider.notifier).state = newPlaces;
    
    // Save to storage
    await storage.saveRecentPlaces(newPlaces);
  }
}
