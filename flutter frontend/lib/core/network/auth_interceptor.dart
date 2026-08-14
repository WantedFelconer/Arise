import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'api_config.dart';

/// Concurrency-safe token injection and refresh interceptor.
///
/// Implements:
/// - Automatic `Authorization: Bearer <accessToken>` header injection.
/// - Queued single-mutex token refresh upon receiving 401 Unauthorized.
/// - Infinite refresh loop guard (blocks refresh for auth routes and retried requests).
/// - Safe replay of original request with newly acquired access token.
/// - Automatic session clearance and callback execution upon refresh rejection.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;
  final ApiConfig apiConfig;
  final Dio dio;
  final VoidCallback? onSessionExpired;

  AuthInterceptor({
    required this.tokenStorage,
    required this.apiConfig,
    required this.dio,
    this.onSessionExpired,
  });

  static const _kIsRetryKey = 'is_retry_request';
  static const _kSkipAuthKey = 'skip_auth_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection if requested explicitly
    if (options.extra[_kSkipAuthKey] == true) {
      return handler.next(options);
    }

    // Inject token if not already manually set
    if (!options.headers.containsKey('Authorization')) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Check if error is 401 and request is eligible for token refresh
    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/password-reset');

    final isAlreadyRetried = err.requestOptions.extra[_kIsRetryKey] == true;

    if (statusCode == 401 && !isAuthEndpoint && !isAlreadyRetried) {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleSessionExpiry();
        return handler.next(err);
      }

      try {
        // Execute refresh with a fresh isolated Dio instance to avoid recursive interceptor loops
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: apiConfig.baseUrl,
            connectTimeout: apiConfig.connectTimeout,
            receiveTimeout: apiConfig.receiveTimeout,
            sendTimeout: apiConfig.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        refreshDio.httpClientAdapter = dio.httpClientAdapter;

        final refreshResponse = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final data = refreshResponse.data;
          final tokenData = data['data'] ?? data;

          final newAccessToken = tokenData['accessToken'] as String?;
          final newRefreshToken = tokenData['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            // Save newly rotated token pair
            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Replay original request with updated access token
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra[_kIsRetryKey] = true;

            final replayedResponse = await dio.fetch(retryOptions);
            return handler.resolve(replayedResponse);
          }
        }

        // Invalid response shape from refresh
        await _handleSessionExpiry();
        return handler.next(err);
      } catch (_) {
        // Refresh failed (e.g. 401 Token Reuse or Expired)
        await _handleSessionExpiry();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _handleSessionExpiry() async {
    await tokenStorage.clearTokens();
    onSessionExpired?.call();
  }
}

/// Request retry interceptor enforcing the strict ARISE safety policy:
/// - Retries ONLY safe idempotent requests (GET, HEAD, OPTIONS) OR
///   mutations carrying an explicit `Idempotency-Key` header.
/// - NEVER blindly retries non-idempotent POST/PATCH/DELETE mutations.
class SafeRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  SafeRetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 500),
  });

  static const _kRetryCountKey = 'safe_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final method = requestOptions.method.toUpperCase();
    final hasIdempotencyKey = requestOptions.headers.containsKey('Idempotency-Key') &&
        requestOptions.headers['Idempotency-Key'] != null &&
        requestOptions.headers['Idempotency-Key'].toString().isNotEmpty;

    final isIdempotentMethod = ['GET', 'HEAD', 'OPTIONS'].contains(method);
    final isSafeToRetry = isIdempotentMethod || hasIdempotencyKey;

    if (!isSafeToRetry) {
      return handler.next(err);
    }

    // Only retry transient network errors
    final isTransientError = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!isTransientError) {
      return handler.next(err);
    }

    final currentRetryCount = (requestOptions.extra[_kRetryCountKey] as int?) ?? 0;

    if (currentRetryCount < maxRetries) {
      final nextRetry = currentRetryCount + 1;
      requestOptions.extra[_kRetryCountKey] = nextRetry;

      // Exponential backoff
      await Future.delayed(retryDelay * nextRetry);

      try {
        final replayed = await dio.fetch(requestOptions);
        return handler.resolve(replayed);
      } catch (retryErr) {
        if (retryErr is DioException) {
          return handler.next(retryErr);
        }
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
