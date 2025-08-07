import 'package:get_it/get_it.dart';
import '../core/network/dio_client.dart';

/// Network dependency injection configuration
/// 
/// This file handles the registration of network-related dependencies
/// including the Dio client and any network services.
class NetworkInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Initialize network dependencies
  static void init() {
    // Register Dio client as a singleton
    _getIt.registerLazySingleton<DioClient>(() => DioClient());
  }

  /// Get the Dio client instance
  static DioClient get dioClient => _getIt<DioClient>();

  /// Dispose network dependencies
  static void dispose() {
    if (_getIt.isRegistered<DioClient>()) {
      _getIt.unregister<DioClient>();
    }
  }
}
