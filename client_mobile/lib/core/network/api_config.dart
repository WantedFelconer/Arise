import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/arise_database.dart';

/// Environment-aware API and networking configuration for ARISE.
///
/// Handles differences across development environments:
/// - **Android Emulator**: `10.0.2.2` routes to the host machine's loopback (`127.0.0.1`).
/// - **iOS Simulator / Desktop / Web**: `localhost` (or `127.0.0.1`) routes to the host machine.
/// - **Physical Device**: `localhost` refers to the device itself. Provide the LAN IP or hosted
///   cloud URL via `--dart-define=API_BASE_URL=https://<your-render-url>/api/v1` or configure it
///   directly in the app via the Gateway Settings modal.
/// - **Production / Cloud (Render)**: Connect timeouts are set to 60 seconds to accommodate
///   free-tier cold starts.
class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.sendTimeout = const Duration(seconds: 30),
  });

  /// Sanitizes and standardizes a user or environment-provided base URL.
  /// Ensures valid scheme (https:// or http://), trims trailing slashes,
  /// and automatically appends /api/v1 if not present.
  static String sanitizeBaseUrl(String url) {
    var clean = url.trim();
    if (clean.isEmpty) return clean;

    // Default to https if no protocol specified, unless it's a localhost/10.0.2.2/192.168.x IP
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      final isLocal = clean.startsWith('localhost') ||
          clean.startsWith('127.0.0.1') ||
          clean.startsWith('10.0.2.2') ||
          clean.startsWith('192.168.');
      clean = isLocal ? 'http://$clean' : 'https://$clean';
    }

    // Remove any trailing slashes
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }

    // If the path doesn't end with /api/v1, append it
    if (!clean.endsWith('/api/v1')) {
      clean = '$clean/api/v1';
    }

    return clean;
  }

  /// Automatically resolves the appropriate base URL for the current runtime platform.
  factory ApiConfig.auto({
    String? initialBaseUrl,
    Duration connectTimeout = const Duration(seconds: 60),
    Duration receiveTimeout = const Duration(seconds: 60),
    Duration sendTimeout = const Duration(seconds: 30),
  }) {
    if (initialBaseUrl != null && initialBaseUrl.trim().isNotEmpty) {
      return ApiConfig(
        baseUrl: sanitizeBaseUrl(initialBaseUrl),
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
    }

    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return ApiConfig(
        baseUrl: sanitizeBaseUrl(envUrl),
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

/// State notifier managing runtime updates and local database persistence for [ApiConfig].
class ApiConfigNotifier extends StateNotifier<ApiConfig> {
  final AriseDatabase? _db;
  static const String metaKey = 'custom_api_base_url';

  ApiConfigNotifier({AriseDatabase? db, ApiConfig? initialConfig})
      : _db = db,
        super(initialConfig ?? ApiConfig.auto());

  /// Sets and persists a new server gateway base URL.
  Future<void> updateBaseUrl(String newUrl) async {
    final sanitized = ApiConfig.sanitizeBaseUrl(newUrl);
    if (sanitized.isEmpty) return;

    state = state.copyWith(baseUrl: sanitized);
    if (_db != null) {
      await _db!.setAppMeta(metaKey, sanitized);
    }
  }

  /// Resets configuration back to system environment defaults.
  Future<void> resetToDefault() async {
    state = ApiConfig.auto();
    if (_db != null) {
      await _db!.setAppMeta(metaKey, '');
    }
  }
}

/// Global provider for API configuration.
/// Allows runtime mutation of the server URL while retaining full backward compatibility.
final apiConfigProvider = StateNotifierProvider<ApiConfigNotifier, ApiConfig>((ref) {
  AriseDatabase? db;
  try {
    db = ref.watch(ariseDatabaseProvider);
  } catch (_) {
    // Allows testing outside a full database ProviderScope
  }
  return ApiConfigNotifier(db: db);
});
