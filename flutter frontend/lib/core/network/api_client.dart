import 'token_storage.dart';

class ApiClient {
  final String baseUrl;
  final TokenStorage tokenStorage;

  ApiClient({
    this.baseUrl = 'http://localhost:3000/api/v1',
    required this.tokenStorage,
  });

  Map<String, String> buildHeaders({String? idempotencyKey, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }
}
