import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Environment-aware API and networking configuration for ARISE.
///
/// Handles differences across development environments:
/// - **Android Emulator**: `10.0.2.2` routes to the host machine's loopback (`127.0.0.1`).
/// - **iOS Simulator / Desktop / Web**: `localhost` (or `127.0.0.1`) routes to the host machine.
/// - **Physical Device**: `localhost` refers to the device itself. Provide the LAN IP via
///   `--dart-define=API_BASE_URL=http://192.168.x.x:3000/api/v1`.
/// - **Production**: Configured via compile-time `--dart-define=API_BASE_URL=https://api.arise.app/api/v1`.
class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 10),
  });

  /// Automatically resolves the appropriate base URL for the current runtime platform.
  factory ApiConfig.auto({
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 10),
  }) {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return ApiConfig(
        baseUrl: envUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
    }

    String defaultHost;
    if (kIsWeb) {
      defaultHost = 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special alias to host loopback on standard Android emulators
      defaultHost = 'http://10.0.2.2:3000/api/v1';
    } else {
      // iOS Simulator, macOS, Windows, Linux
      defaultHost = 'http://localhost:3000/api/v1';
    }

    return ApiConfig(
      baseUrl: defaultHost,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }

  ApiConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
    );
  }
}

/// Global provider for API configuration.
/// Can be overridden in ProviderScope for tests or custom environments.
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.auto();
});
