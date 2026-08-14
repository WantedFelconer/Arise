import '../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  // Thin client contracts wired to backend endpoints (/api/v1/auth/*)
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String difficultyMode = 'casual',
    String chronotype = 'early_bird',
  }) async {
    // Scaffolded for Flutter HTTP client integration
    return {
      'user': {'email': email, 'difficultyMode': difficultyMode},
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return {
      'user': {'email': email},
    };
  }
}
