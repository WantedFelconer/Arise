import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/api_exceptions.dart';
import 'package:arise_app/core/network/token_storage.dart';

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
  group('Sprint A2 — Token Lifecycle & Refresh Mutex Interceptor Suite', () {
    late InMemoryTokenStorage tokenStorage;
    late ApiConfig config;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    bool sessionExpiredTriggered = false;

    setUp(() {
      tokenStorage = InMemoryTokenStorage();
      config = const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1');
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: config.baseUrl));
      dio.httpClientAdapter = mockAdapter;
      sessionExpiredTriggered = false;

      apiClient = ApiClient(
        config: config,
        tokenStorage: tokenStorage,
        dio: dio,
        onSessionExpired: () {
          sessionExpiredTriggered = true;
        },
      );
    });

    test('P1: 401 triggers /auth/refresh, stores rotated tokens, and replays original request with new access token', () async {
      await tokenStorage.saveTokens(
        accessToken: 'expired_access_token_1',
        refreshToken: 'valid_refresh_token_1',
      );

      int characterCallCount = 0;
      int refreshCallCount = 0;
      String? lastAuthHeaderUsedForCharacter;

      mockAdapter.handler = (options) async {
        if (options.path.contains('/character')) {
          characterCallCount++;
          lastAuthHeaderUsedForCharacter = options.headers['Authorization'];

          // First call returns 401 expired
          if (characterCallCount == 1) {
            return ResponseBody.fromString(
              json.encode({
                'error': {
                  'code': 'UNAUTHORIZED',
                  'message': 'Access token has expired',
                }
              }),
              401,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }

          // Replayed call succeeds with refreshed token
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_uuid_99',
                'level': 5,
                'totalXp': 2500,
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.contains('/auth/refresh')) {
          refreshCallCount++;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'accessToken': 'newly_issued_access_token_2',
                'refreshToken': 'newly_issued_refresh_token_2',
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return ResponseBody.fromString('{}', 200);
      };

      final response = await apiClient.get('/character');

      expect(response['data']['level'], 5);
      expect(characterCallCount, 2);
      expect(refreshCallCount, 1);
      expect(lastAuthHeaderUsedForCharacter, 'Bearer newly_issued_access_token_2');

      // Verify tokens updated in storage
      expect(await tokenStorage.getAccessToken(), 'newly_issued_access_token_2');
      expect(await tokenStorage.getRefreshToken(), 'newly_issued_refresh_token_2');
      expect(sessionExpiredTriggered, false);
    });

    test('P2: Failed token refresh clears storage and triggers session expiry callback', () async {
      await tokenStorage.saveTokens(
        accessToken: 'expired_access_token_1',
        refreshToken: 'revoked_refresh_token_1',
      );

      mockAdapter.handler = (options) async {
        if (options.path.contains('/character')) {
          return ResponseBody.fromString(
            json.encode({
              'error': {
                'code': 'UNAUTHORIZED',
                'message': 'Token expired',
              }
            }),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.contains('/auth/refresh')) {
          // Refresh itself is rejected with 401
          return ResponseBody.fromString(
            json.encode({
              'error': {
                'code': 'INVALID_REFRESH_TOKEN',
                'message': 'Refresh token has been revoked',
              }
            }),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return ResponseBody.fromString('{}', 200);
      };

      await expectLater(
        () => apiClient.get('/character'),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
      expect(sessionExpiredTriggered, true);
    });

    test('P3: 401 on /auth/login or /auth/signup NEVER triggers refresh loop', () async {
      int refreshCallCount = 0;

      mockAdapter.handler = (options) async {
        if (options.path.contains('/auth/login')) {
          return ResponseBody.fromString(
            json.encode({
              'error': {
                'code': 'INVALID_CREDENTIALS',
                'message': 'Invalid email or password',
              }
            }),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.contains('/auth/refresh')) {
          refreshCallCount++;
          return ResponseBody.fromString('{}', 200);
        }
        return ResponseBody.fromString('{}', 200);
      };

      await expectLater(
        () => apiClient.post('/auth/login', data: {'email': 'test@arise.io', 'password': 'wrong'}),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(refreshCallCount, 0);
    });
  });
}
