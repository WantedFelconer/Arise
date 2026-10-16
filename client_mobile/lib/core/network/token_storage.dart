import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract contract for JWT token persistence.
/// Implementations must survive app restart securely.
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

// ---------------------------------------------------------------------------
// In-memory implementation — retained as a test double.
// DO NOT use in production; tokens are lost on app restart.
// ---------------------------------------------------------------------------

class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

// ---------------------------------------------------------------------------
// Secure persistent implementation.
// iOS: Keychain  |  Android: EncryptedSharedPreferences
// Tokens survive app restart. Never stored in plain SharedPreferences or SQLite.
// ---------------------------------------------------------------------------

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'arise_access_token';
  static const _kRefreshToken = 'arise_refresh_token';

  @override
  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Override in main.dart ProviderScope with SecureTokenStorage for production.
/// Override in tests with InMemoryTokenStorage.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});
