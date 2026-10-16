import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Domain type
// ---------------------------------------------------------------------------

/// Application-level network status.
/// The UI and SyncEngine depend only on this — never on connectivity_plus directly.
enum NetworkStatus {
  /// Internet connection is confirmed available.
  online,

  /// No connectivity detected.
  offline,

  /// Transitioning from offline → online; connection not yet confirmed.
  reconnecting,
}

// ---------------------------------------------------------------------------
// Abstract contract
// ---------------------------------------------------------------------------

abstract class NetworkStatusService {
  /// A continuous stream of [NetworkStatus] changes.
  Stream<NetworkStatus> get statusStream;

  /// The current synchronous status (best-effort; may lag by one event).
  NetworkStatus get current;

  /// Release resources.
  void dispose();
}

// ---------------------------------------------------------------------------
// connectivity_plus implementation
// ---------------------------------------------------------------------------

/// Wraps [connectivity_plus] and maps [ConnectivityResult] values to
/// [NetworkStatus].
///
/// Emits [NetworkStatus.reconnecting] for a short window (2 s) when
/// connectivity transitions from offline → online, allowing the UI to show a
/// "reconnecting…" indicator before the SyncEngine starts sending.
///
/// No UI or business logic code imports connectivity_plus directly.
class ConnectivityNetworkStatusService implements NetworkStatusService {
  ConnectivityNetworkStatusService() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _current = NetworkStatus.offline;
  bool _wasOffline = false;
  Timer? _reconnectingTimer;

  @override
  NetworkStatus get current => _current;

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  void _init() {
    // Emit the initial status immediately.
    _connectivity.checkConnectivity().then(_handleConnectivityChange);

    // Subscribe to changes.
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );

    _reconnectingTimer?.cancel();

    if (isOnline && _wasOffline) {
      // Just came back online — emit 'reconnecting' briefly.
      _emit(NetworkStatus.reconnecting);
      _reconnectingTimer = Timer(const Duration(seconds: 2), () {
        _emit(NetworkStatus.online);
      });
    } else if (isOnline) {
      _emit(NetworkStatus.online);
    } else {
      _wasOffline = true;
      _emit(NetworkStatus.offline);
    }

    if (isOnline) _wasOffline = false;
  }

  void _emit(NetworkStatus status) {
    _current = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  @override
  void dispose() {
    _reconnectingTimer?.cancel();
    _controller.close();
  }
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Singleton [NetworkStatusService].
/// Override in tests with a fake implementation.
final networkStatusServiceProvider =
    Provider<NetworkStatusService>((ref) {
  final service = ConnectivityNetworkStatusService();
  ref.onDispose(service.dispose);
  return service;
});

/// Derived [StreamProvider] consumed by the SyncEngine and UI widgets.
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkStatusServiceProvider);
  return service.statusStream;
});
