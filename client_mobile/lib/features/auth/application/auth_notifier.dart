import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/player_provider.dart';
import '../../../shared/models/player_data.dart';
import '../domain/auth_models.dart';
import '../infrastructure/auth_remote_data_source.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final AuthCharacter? character;
  final String? errorMessage;
  final String? errorCode;
  final List<String>? validationErrors;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.character,
    this.errorMessage,
    this.errorCode,
    this.validationErrors,
    this.successMessage,
  });

  bool get isLoading => status == AuthStatus.authenticating;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    AuthCharacter? character,
    String? errorMessage,
    String? errorCode,
    List<String>? validationErrors,
    String? successMessage,
    bool clearErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      character: character ?? this.character,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearErrors ? null : (errorCode ?? this.errorCode),
      validationErrors: clearErrors ? null : (validationErrors ?? this.validationErrors),
      successMessage: clearErrors ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final Ref _ref;

  AuthNotifier({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    required Ref ref,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage,
        _ref = ref,
        super(const AuthState());

  /// Attempts to restore session from secure storage on app launch.
  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.initial);

    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      _ref.read(navigationProvider.notifier).setPhase(AppPhase.auth);
      return;
    }

    try {
      // Fetch authenticated character from backend
      final character = await _remoteDataSource.getCharacter();
      final playerData = _mapCharacterToPlayerData(character);

      // Reconcile with local database and PlayerNotifier
      _ref.read(playerProvider.notifier).reconcileFromServerResponse(playerData);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        character: character,
      );

      _ref.read(navigationProvider.notifier).setPhase(AppPhase.main);
    } on UnauthorizedException {
      // Token invalid or refresh failed
      await _tokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
      _ref.read(navigationProvider.notifier).setPhase(AppPhase.auth);
    } on NetworkException {
      // Offline launch: check local database for cached snapshot
      final localData = await _ref.read(playerRepositoryProvider).fetchPlayerData();
      if (localData.name.isNotEmpty) {
        state = state.copyWith(status: AuthStatus.authenticated);
        _ref.read(navigationProvider.notifier).setPhase(AppPhase.main);
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Offline. Please connect to internet to sign in.',
        );
        _ref.read(navigationProvider.notifier).setPhase(AppPhase.auth);
      }
    } catch (_) {
      // Fallback: clear tokens and show auth
      await _tokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
      _ref.read(navigationProvider.notifier).setPhase(AppPhase.auth);
    }
  }

  /// Logs in an existing hunter.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Hunter email and access code are required.',
        errorCode: 'VALIDATION_ERROR',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearErrors: true,
    );

    try {
      final response = await _remoteDataSource.login(
        email: cleanEmail,
        password: password,
      );

      // Securely persist token pair
      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      // Reconcile player data
      if (response.character != null) {
        final playerData = _mapCharacterToPlayerData(
          response.character!,
          email: response.user.email,
          difficulty: response.user.difficultyMode,
        );
        _ref.read(playerProvider.notifier).reconcileFromServerResponse(playerData);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        character: response.character,
      );

      _ref.read(navigationProvider.notifier).setPhase(AppPhase.main);
      return true;
    } on ApiException catch (e) {
      _handleApiError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected authentication error occurred.',
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Registers a new hunter.
  Future<bool> signup({
    required String email,
    required String password,
    String difficultyMode = 'casual',
    String chronotype = 'early_bird',
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.length < 8) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: password.length < 8
            ? 'Encryption key must be at least 8 characters long.'
            : 'Valid uplink email address is required.',
        errorCode: 'VALIDATION_ERROR',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearErrors: true,
    );

    try {
      final response = await _remoteDataSource.signup(
        email: cleanEmail,
        password: password,
        difficultyMode: difficultyMode,
        chronotype: chronotype,
      );

      // Securely persist token pair
      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      // Reconcile player data
      if (response.character != null) {
        final playerData = _mapCharacterToPlayerData(
          response.character!,
          email: response.user.email,
          difficulty: response.user.difficultyMode,
        );
        _ref.read(playerProvider.notifier).reconcileFromServerResponse(playerData);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        character: response.character,
      );

      // Direct new user to onboarding phase
      _ref.read(navigationProvider.notifier).setPhase(AppPhase.onboarding);
      return true;
    } on ApiException catch (e) {
      _handleApiError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Awakening protocol failed. Please try again.',
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Logs out the hunter and clears local session tokens.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    try {
      await _remoteDataSource.logout(refreshToken: refreshToken);
    } catch (_) {
      // Ignore network errors during logout
    }

    await _tokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _ref.read(navigationProvider.notifier).setPhase(AppPhase.auth);
  }

  /// Sends a recovery signal / password reset request.
  Future<bool> requestPasswordReset(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please provide a valid registered frequency (email).',
        errorCode: 'VALIDATION_ERROR',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearErrors: true,
    );

    try {
      final msg = await _remoteDataSource.requestPasswordReset(email: cleanEmail);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: msg,
      );
      return true;
    } on ApiException catch (e) {
      _handleApiError(e);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to transmit recovery signal.',
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearErrors: true);
  }

  // ---------------------------------------------------------------------------
  // Error and Mapping Helpers
  // ---------------------------------------------------------------------------

  void _handleApiError(ApiException error) {
    List<String>? validationErrors;
    if (error is ValidationException) {
      validationErrors = error.validationErrors;
    }

    String userMessage = error.message;
    if (error is ConflictException) {
      userMessage = 'A hunter account with this frequency already exists.';
    } else if (error is UnauthorizedException) {
      userMessage = 'Invalid hunter credentials. Verification rejected.';
    } else if (error is NetworkException) {
      userMessage = 'Uplink failed: No dimensional connection detected.';
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: userMessage,
      errorCode: error.code,
      validationErrors: validationErrors,
    );
  }

  PlayerData _mapCharacterToPlayerData(
    AuthCharacter char, {
    String? email,
    String? difficulty,
  }) {
    final stats = char.stats;
    int str = 10;
    int agi = 10;
    int vit = 10;
    int intStat = 10;
    int per = 10;

    if (stats.containsKey('str') || stats.containsKey('intelligence')) {
      str = (stats['str'] as num?)?.toInt() ?? (stats['fitness'] as num?)?.toInt() ?? 10;
      agi = (stats['agi'] as num?)?.toInt() ?? (stats['discipline'] as num?)?.toInt() ?? 10;
      vit = (stats['vit'] as num?)?.toInt() ?? (stats['health'] as num?)?.toInt() ?? 10;
      intStat = (stats['int'] as num?)?.toInt() ?? (stats['intelligence'] as num?)?.toInt() ?? (stats['coding'] as num?)?.toInt() ?? 10;
      per = (stats['per'] as num?)?.toInt() ?? (stats['creativity'] as num?)?.toInt() ?? 10;
    }

    return PlayerData(
      id: char.userId ?? char.id,
      email: email,
      difficultyMode: difficulty,
      name: 'HUNTER',
      title: char.title ?? 'THE AWAKENED',
      level: char.level,
      rank: char.rank,
      hp: 100,
      maxHp: 100,
      mp: char.currentMana,
      maxMp: char.maxMana,
      exp: char.totalXp,
      maxExp: 100 * (char.level * char.level),
      gold: char.coins,
      streak: char.streak,
      str: str,
      agi: agi,
      vit: vit,
      intStat: intStat,
      per: per,
      remainingPoints: 0,
      syncStatus: 'verified',
      isProgressionPending: false,
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(
    remoteDataSource: remoteDataSource,
    tokenStorage: tokenStorage,
    ref: ref,
  );
});
