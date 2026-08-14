import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'api_config.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Production-ready HTTP client for ARISE backed by Dio.
///
/// Features:
/// - Full CRUD methods: [get], [post], [patch], [put], [delete].
/// - Environment-aware base URL resolution via [ApiConfig].
/// - Strongly-typed [ApiException] error transformation.
/// - Unique [X-Request-Id] UUID tagging per request.
/// - Explicit [Idempotency-Key] support for state mutations.
/// - Concurrency-safe Bearer token injection and refresh.
/// - Safe retry policy protecting against accidental duplicate mutations.
class ApiClient {
  final ApiConfig config;
  final TokenStorage tokenStorage;
  final Dio _dio;
  final Uuid _uuid;

  ApiClient({
    required this.config,
    required this.tokenStorage,
    Dio? dio,
    Uuid? uuid,
    VoidCallback? onSessionExpired,
  })  : _uuid = uuid ?? const Uuid(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.baseUrl,
                connectTimeout: config.connectTimeout,
                receiveTimeout: config.receiveTimeout,
                sendTimeout: config.sendTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    // Attach standard request ID interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.headers.containsKey('X-Request-Id')) {
            options.headers['X-Request-Id'] = _uuid.v4();
          }
          return handler.next(options);
        },
      ),
    );

    // Attach token lifecycle and safe retry interceptors
    _dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        apiConfig: config,
        dio: _dio,
        onSessionExpired: onSessionExpired,
      ),
    );

    _dio.interceptors.add(
      SafeRetryInterceptor(dio: _dio),
    );
  }

  Dio get dioInstance => _dio;
  String get baseUrl => config.baseUrl;

  // ---------------------------------------------------------------------------
  // Core HTTP Methods
  // ---------------------------------------------------------------------------

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(message: e.toString());
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    try {
      final opts = _applyIdempotencyKey(options, idempotencyKey);
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(message: e.toString());
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    try {
      final opts = _applyIdempotencyKey(options, idempotencyKey);
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(message: e.toString());
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    try {
      final opts = _applyIdempotencyKey(options, idempotencyKey);
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(message: e.toString());
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    try {
      final opts = _applyIdempotencyKey(options, idempotencyKey);
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(message: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Helper methods
  // ---------------------------------------------------------------------------

  Options _applyIdempotencyKey(Options? options, String? idempotencyKey) {
    final opts = options ?? Options();
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      final headers = Map<String, dynamic>.from(opts.headers ?? {});
      headers['Idempotency-Key'] = idempotencyKey;
      return opts.copyWith(headers: headers);
    }
    return opts;
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(
    config: config,
    tokenStorage: tokenStorage,
  );
});
