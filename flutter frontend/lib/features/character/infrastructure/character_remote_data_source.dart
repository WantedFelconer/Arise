import '../../../core/network/api_client.dart';

class CharacterRemoteDataSource {
  final ApiClient apiClient;

  CharacterRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> fetchCharacter() async {
    // Scaffolded for Flutter HTTP client integration
    return {
      'level': 1,
      'totalXp': 0,
      'currentMana': 100,
      'rank': 'E',
    };
  }
}
