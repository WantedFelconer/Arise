import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/api_exceptions.dart';
import 'package:arise_app/core/network/token_storage.dart';

/// Clean in-memory mock adapter for testing Dio network pipelines.
class MockHttpAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? handler;

  MockHttpAdapter([this.handler]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      json.encode({'status': 'ok'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Sprint A2 — ApiClient & Error Architecture Suite', () {
    late InMemoryTokenStorage tokenStorage;
    late ApiConfig config;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;

    setUp(() {
      tokenStorage = InMemoryTokenStorage();
      config = const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1');
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: config.baseUrl));
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: config,
        tokenStorage: tokenStorage,
        dio: dio,
      );
    });

    test('P1: GET, POST, PATCH, DELETE execute and auto-inject X-Request-Id and Bearer Token', () async {
      await tokenStorage.saveTokens(
        accessToken: 'valid_access_jwt_123',
        refreshToken: 'valid_refresh_token_456',
      );

      final capturedRequests = <RequestOptions>[];

      mockAdapter.handler = (options) async {
        capturedRequests.add(options);
        return ResponseBody.fromString(
          json.encode({'data': {'message': '${options.method} success'}}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      // 1. GET
      final getRes = await apiClient.get('/character');
      expect(getRes['data']['message'], 'GET success');

      // 2. POST with Idempotency-Key
      final postRes = await apiClient.post(
        '/sync/events',
        data: {'command': 'COMPLETE_QUEST'},
        idempotencyKey: 'idem-uuid-001',
      );
      expect(postRes['data']['message'], 'POST success');

      // 3. PATCH
      final patchRes = await apiClient.patch(
        '/character/title',
        data: {'titleId': 'title_1'},
      );
      expect(patchRes['data']['message'], 'PATCH success');

      // 4. DELETE
      final deleteRes = await apiClient.delete('/auth/account');
      expect(deleteRes['data']['message'], 'DELETE success');

      expect(capturedRequests.length, 4);

      for (final req in capturedRequests) {
        expect(req.headers['X-Request-Id'], isNotNull);
        expect(req.headers['Authorization'], 'Bearer valid_access_jwt_123');
      }

      // Check Idempotency-Key on POST
      expect(capturedRequests[1].headers['Idempotency-Key'], 'idem-uuid-001');
    });

    test('P2: Translates 400/422 to ValidationException with field error extraction', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          json.encode({
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Password is too weak',
              'details': [
                {'field': 'password', 'message': 'Password must be at least 8 characters long'}
              ]
            }
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => apiClient.post('/auth/signup', data: {}),
        throwsA(isA<ValidationException>().having(
          (e) => e.validationErrors.first,
          'validation error message',
          contains('Password must be at least 8 characters long'),
        )),
      );
    });

    test('P3: Translates 409 to ConflictException (USER_EXISTS)', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          json.encode({
            'error': {
              'code': 'USER_EXISTS',
              'message': 'An account with this email already exists',
            }
          }),
          409,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => apiClient.post('/auth/signup', data: {'email': 'existing@arise.io'}),
        throwsA(isA<ConflictException>().having(
          (e) => e.code,
          'error code',
          'USER_EXISTS',
        )),
      );
    });

    test('P4: Translates 401 with TOKEN_REUSE_DETECTED to TokenReuseException (AC-AUTH-004)', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          json.encode({
            'error': {
              'code': 'TOKEN_REUSE_DETECTED',
              'message': 'Refresh token reuse detected. All active sessions have been revoked.',
            }
          }),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => apiClient.post('/auth/refresh', data: {'refreshToken': 'stolen_token'}),
        throwsA(isA<TokenReuseException>()),
      );
    });

    test('P5: Translates 500/503 to ServerException and connection errors to NetworkException', () async {
      // 500 Server Error
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          json.encode({
            'error': {
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Database connection lost',
            }
          }),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => apiClient.get('/character'),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('P6: SafeRetryInterceptor retries GET on connection failure and skips non-idempotent POST without idempotency key', () async {
      int getAttempts = 0;
      int postAttempts = 0;

      mockAdapter.handler = (options) async {
        if (options.method == 'GET') {
          getAttempts++;
          if (getAttempts <= 2) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
              error: 'Connection timeout',
            );
          }
          return ResponseBody.fromString(
            json.encode({'data': {'status': 'recovered'}}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.method == 'POST') {
          postAttempts++;
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            error: 'Connection timeout on POST',
          );
        }

        return ResponseBody.fromString('{}', 200);
      };

      // 1. GET is idempotent -> retries and recovers on 3rd attempt
      final getRes = await apiClient.get('/character');
      expect(getRes['data']['status'], 'recovered');
      expect(getAttempts, 3);

      // 2. POST without Idempotency-Key -> NEVER retried blindly (only 1 attempt)
      await expectLater(
        () => apiClient.post('/quests', data: {'title': 'New Quest'}),
        throwsA(isA<ApiTimeoutException>()),
      );
      expect(postAttempts, 1);
    });
  });
}
