import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/token_storage.dart';
import 'package:arise_app/core/providers/navigation_provider.dart';
import 'package:arise_app/core/providers/player_provider.dart';
import 'package:arise_app/features/auth/application/auth_notifier.dart';
import 'package:arise_app/features/auth/infrastructure/auth_remote_data_source.dart';
import 'package:arise_app/features/character/infrastructure/local_player_repository.dart';

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
  group('Sprint A2 — Auth Notifier & Flow Integration Suite', () {
    late AriseDatabase db;
    late InMemoryTokenStorage tokenStorage;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    late ProviderContainer container;

    setUp(() {
      db = AriseDatabase.forTesting(NativeDatabase.memory());
      tokenStorage = InMemoryTokenStorage();
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://test.arise.sys/api/v1'));
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1'),
        tokenStorage: tokenStorage,
        dio: dio,
      );

      container = ProviderContainer(
        overrides: [
          ariseDatabaseProvider.overrideWithValue(db),
          playerRepositoryProvider.overrideWithValue(LocalPlayerRepository(db)),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          apiClientProvider.overrideWithValue(apiClient),
          authRemoteDataSourceProvider.overrideWithValue(
            AuthRemoteDataSource(apiClient: apiClient),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('P1: Full Register Flow: POST /auth/signup -> tokens persisted -> character saved in Drift SQLite -> AppPhase.onboarding', () async {
      mockAdapter.handler = (options) async {
        if (options.path.contains('/auth/signup')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'user': {
                  'id': 'user_uuid_101',
                  'email': 'new_hunter@arise.io',
                  'difficultyMode': 'casual',
                },
                'character': {
                  'id': 'char_uuid_202',
                  'level': 1,
                  'totalXp': 0,
                  'currentMana': 100,
                  'maxMana': 100,
                  'rank': 'E',
                  'stats': {
                    'intelligence': 10,
                    'discipline': 10,
                    'fitness': 10,
                    'creativity': 10,
                    'coding': 10,
                    'business': 10,
                    'health': 10,
                  }
                },
                'tokens': {
                  'accessToken': 'jwt_access_signup_001',
                  'refreshToken': 'jwt_refresh_signup_002',
                }
              }
            }),
            201,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      final authNotifier = container.read(authNotifierProvider.notifier);

      final success = await authNotifier.signup(
        email: 'new_hunter@arise.io',
        password: 'Password123!',
        difficultyMode: 'casual',
      );

      expect(success, true);

      // Verify tokens stored
      expect(await tokenStorage.getAccessToken(), 'jwt_access_signup_001');
      expect(await tokenStorage.getRefreshToken(), 'jwt_refresh_signup_002');

      // Verify player state in Riverpod
      final playerState = container.read(playerProvider);
      expect(playerState.id, 'char_uuid_202');
      expect(playerState.email, 'new_hunter@arise.io');
      expect(playerState.level, 1);
      expect(playerState.syncStatus, 'verified');

      // Verify character snapshot in Drift SQLite
      final dbSnapshot = await db.getCharacterSnapshot('char_uuid_202');
      expect(dbSnapshot, isNotNull);
      expect(dbSnapshot!.level, 1);
      expect(dbSnapshot.rank, 'E');

      // Verify navigation phase transitioned to onboarding
      final navState = container.read(navigationProvider);
      expect(navState.phase, AppPhase.onboarding);
    });

    test('P2: Full Login Flow: POST /auth/login -> tokens persisted -> character saved in Drift -> AppPhase.main', () async {
      mockAdapter.handler = (options) async {
        if (options.path.contains('/auth/login')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'user': {
                  'id': 'user_uuid_505',
                  'email': 'veteran_hunter@arise.io',
                  'difficultyMode': 'hardcore',
                },
                'character': {
                  'id': 'char_uuid_606',
                  'level': 12,
                  'totalXp': 14400,
                  'currentMana': 150,
                  'maxMana': 150,
                  'rank': 'D',
                  'stats': {
                    'fitness': 25,
                    'discipline': 20,
                    'intelligence': 18,
                  }
                },
                'tokens': {
                  'accessToken': 'jwt_access_login_101',
                  'refreshToken': 'jwt_refresh_login_202',
                }
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

      final authNotifier = container.read(authNotifierProvider.notifier);

      final success = await authNotifier.login(
        email: 'veteran_hunter@arise.io',
        password: 'Password123!',
      );

      expect(success, true);
      expect(await tokenStorage.getAccessToken(), 'jwt_access_login_101');

      final playerState = container.read(playerProvider);
      expect(playerState.level, 12);
      expect(playerState.exp, 14400);
      expect(playerState.rank, 'D');

      // Navigation phase transitioned directly to main
      final navState = container.read(navigationProvider);
      expect(navState.phase, AppPhase.main);
    });

    test('P3: Session Restoration with valid tokens: GET /character -> AppPhase.main', () async {
      await tokenStorage.saveTokens(
        accessToken: 'saved_access_token',
        refreshToken: 'saved_refresh_token',
      );

      mockAdapter.handler = (options) async {
        if (options.path.contains('/character')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_uuid_restored',
                'level': 8,
                'totalXp': 6400,
                'currentMana': 120,
                'maxMana': 120,
                'rank': 'E',
                'stats': {'str': 15, 'agi': 15}
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

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.restoreSession();

      final authState = container.read(authNotifierProvider);
      expect(authState.status, AuthStatus.authenticated);

      final navState = container.read(navigationProvider);
      expect(navState.phase, AppPhase.main);

      final playerState = container.read(playerProvider);
      expect(playerState.level, 8);
    });

    test('P4: Session Restoration with revoked token clears storage and sets AppPhase.auth', () async {
      await tokenStorage.saveTokens(
        accessToken: 'invalid_access_token',
        refreshToken: 'revoked_refresh_token',
      );

      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          json.encode({
            'error': {
              'code': 'UNAUTHORIZED',
              'message': 'Token invalid',
            }
          }),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.restoreSession();

      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);

      final authState = container.read(authNotifierProvider);
      expect(authState.status, AuthStatus.unauthenticated);

      final navState = container.read(navigationProvider);
      expect(navState.phase, AppPhase.auth);
    });

    test('P5: Logout Flow: POST /auth/logout -> clears secure storage -> transitions to AppPhase.auth', () async {
      await tokenStorage.saveTokens(
        accessToken: 'active_token',
        refreshToken: 'active_refresh',
      );

      int logoutCallCount = 0;
      mockAdapter.handler = (options) async {
        if (options.path.contains('/auth/logout')) {
          logoutCallCount++;
          return ResponseBody.fromString(
            json.encode({'message': 'Logged out successfully'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.logout();

      expect(logoutCallCount, 1);
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);

      final authState = container.read(authNotifierProvider);
      expect(authState.status, AuthStatus.unauthenticated);

      final navState = container.read(navigationProvider);
      expect(navState.phase, AppPhase.auth);
    });

    test('P6: Error UX: Invalid credentials sets descriptive error state without crashing', () async {
      mockAdapter.handler = (options) async {
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
      };

      final authNotifier = container.read(authNotifierProvider.notifier);
      final success = await authNotifier.login(
        email: 'wrong@arise.io',
        password: 'BadPassword',
      );

      expect(success, false);

      final authState = container.read(authNotifierProvider);
      expect(authState.status, AuthStatus.error);
      expect(authState.errorMessage, contains('Invalid hunter credentials'));
    });
  });
}
