import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

/// Remote data source communicating with NestJS authentication endpoints (/api/v1/auth/*).
class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  /// Registers a new hunter account.
  /// Endpoint: POST /api/v1/auth/signup
  Future<AuthResponseData> signup({
    required String email,
    required String password,
    String difficultyMode = 'casual',
    String chronotype = 'early_bird',
  }) async {
    final response = await apiClient.post(
      '/auth/signup',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'difficultyMode': difficultyMode,
        'chronotype': chronotype,
      },
    );

    return AuthResponseData.fromJson(response as Map<String, dynamic>);
  }

  /// Authenticates an existing hunter with credentials.
  /// Endpoint: POST /api/v1/auth/login
  Future<AuthResponseData> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    return AuthResponseData.fromJson(response as Map<String, dynamic>);
  }

  /// Rotates a single-use refresh token.
  /// Endpoint: POST /api/v1/auth/refresh
  Future<AuthTokens> refresh({
    required String refreshToken,
  }) async {
    final response = await apiClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = (response as Map<String, dynamic>)['data'] ?? response;
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  /// Invalidates active user session on the server.
  /// Endpoint: POST /api/v1/auth/logout
  Future<String> logout({String? refreshToken}) async {
    final response = await apiClient.post(
      '/auth/logout',
      data: refreshToken != null ? {'refreshToken': refreshToken} : {},
    );

    if (response is Map<String, dynamic> && response.containsKey('message')) {
      return response['message'] as String;
    }
    return 'Logged out successfully';
  }

  /// Requests a password reset link for the given email.
  /// Endpoint: POST /api/v1/auth/password-reset/request
  Future<String> requestPasswordReset({required String email}) async {
    final response = await apiClient.post(
      '/auth/password-reset/request',
      data: {'email': email.trim().toLowerCase()},
    );

    if (response is Map<String, dynamic> && response.containsKey('message')) {
      return response['message'] as String;
    }
    return 'If the email exists, a password reset link has been sent.';
  }

  /// Confirms password reset with reset token.
  /// Endpoint: POST /api/v1/auth/password-reset/confirm
  Future<String> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final response = await apiClient.post(
      '/auth/password-reset/confirm',
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    if (response is Map<String, dynamic> && response.containsKey('message')) {
      return response['message'] as String;
    }
    return 'Password reset successfully';
  }

  /// Fetches the authenticated hunter's character profile and progression.
  /// Endpoint: GET /api/v1/character
  Future<AuthCharacter> getCharacter() async {
    final response = await apiClient.get('/character');
    final data = (response as Map<String, dynamic>)['data'] ?? response;
    return AuthCharacter.fromJson(data as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient: apiClient);
});
