import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

/// Dio HTTP Client for the FindEasy application
/// 
/// This class provides a configured Dio instance with interceptors,
/// error handling, and proper base URL configuration.
class DioClient {
  late final Dio _dio;

  /// Initialize the Dio client with proper configuration
  DioClient() {
    _dio = Dio();
    _configureDio();
  }

  /// Get the configured Dio instance
  Dio get dio => _dio;

  /// Configure Dio with base settings, interceptors, and error handling
  void _configureDio() {
    // Base configuration
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.acceptHeader,
        'User-Agent': 'FindEasy/${AppConstants.appVersion}',
      },
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  /// Add authorization token to requests
  void setAuthToken(String token) {
    _dio.options.headers[ApiConstants.authorizationHeader] = 
        '${ApiConstants.bearerPrefix}$token';
  }

  /// Remove authorization token from requests
  void clearAuthToken() {
    _dio.options.headers.remove(ApiConstants.authorizationHeader);
  }
}

/// Logging interceptor for debugging API requests
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('🌐 API Request: ${options.method} ${options.uri}');
      print('📤 Headers: ${options.headers}');
      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
      print('📥 Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('❌ API Error: ${err.type} ${err.message}');
      print('🔗 URL: ${err.requestOptions.uri}');
      print('📊 Status: ${err.response?.statusCode}');
    }
    handler.next(err);
  }
}

/// Authentication interceptor for adding auth tokens
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    // This can be enhanced to handle token refresh logic
    handler.next(options);
  }
}

/// Error handling interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(
          error: ApiConstants.timeoutErrorMessage,
        );
        break;
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 401:
            err = err.copyWith(
              error: ApiConstants.unauthorizedErrorMessage,
            );
            break;
          case 403:
            err = err.copyWith(
              error: ApiConstants.forbiddenErrorMessage,
            );
            break;
          case 404:
            err = err.copyWith(
              error: ApiConstants.notFoundErrorMessage,
            );
            break;
          case 500:
          case 502:
          case 503:
            err = err.copyWith(
              error: ApiConstants.serverErrorMessage,
            );
            break;
        }
        break;
      case DioExceptionType.connectionError:
        err = err.copyWith(
          error: ApiConstants.networkErrorMessage,
        );
        break;
      default:
        err = err.copyWith(
          error: ApiConstants.networkErrorMessage,
        );
    }
    
    handler.next(err);
  }
}
