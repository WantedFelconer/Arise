import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/player_data.dart';
import '../database/arise_database.dart';
import '../repositories/player_repository.dart';
import '../../features/character/infrastructure/local_player_repository.dart';
import '../../features/character/infrastructure/character_remote_data_source.dart';
import '../../features/character/domain/character_models.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final db = ref.watch(ariseDatabaseProvider);
  return LocalPlayerRepository(db);
});

class PlayerNotifier extends StateNotifier<PlayerData> {
  PlayerNotifier(
    this._repository, {
    CharacterRemoteDataSource? remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(PlayerData.defaultPlayer) {
    _loadFromDatabase();
  }

  final PlayerRepository _repository;
  final CharacterRemoteDataSource? _remoteDataSource;

  Future<void> _loadFromDatabase() async {
    try {
      final data = await _repository.fetchPlayerData();
      if (data.name.isNotEmpty) {
        state = data;
      }
    } catch (_) {
      // Gracefully handle uninitialized or closed database in transient test states
    }
  }

  /// Reloads local projection from Drift SQLite.
  Future<void> reloadFromDatabase([String? userId]) async {
    try {
      final data = await _repository.fetchPlayerData(userId);
      if (data.name.isNotEmpty) {
        state = data;
      }
    } catch (_) {}
  }

  /// Fetches authoritative character state from backend API (FR-CHAR-001..003).
  Future<PlayerData?> refreshFromServer() async {
    final remote = _remoteDataSource;
    if (remote == null) return null;
    try {
      final raw = await remote.fetchCharacter();
      if (_repository is LocalPlayerRepository) {
        final localRepo = _repository as LocalPlayerRepository;
        final reconciled = await localRepo.saveServerSnapshot(raw);
        state = reconciled;
        return reconciled;
      } else {
        // Fallback for in-memory / mock repositories
        final totalXp = (raw['totalXp'] as num?)?.toInt() ?? 0;
        final xpToNext = (raw['xpToNextLevel'] as num?)?.toInt() ?? 1000;
        final level = (raw['level'] as num?)?.toInt() ?? 1;
        final rank = raw['rank'] as String? ?? 'E';
        final mana = (raw['currentMana'] as num?)?.toInt() ?? 100;
        final maxMana = (raw['maxMana'] as num?)?.toInt() ?? 100;

        final reconciled = state.copyWith(
          id: raw['id'] as String?,
          level: level,
          rank: rank,
          exp: totalXp,
          maxExp: totalXp + xpToNext,
          mp: mana,
          maxMp: maxMana,
          syncStatus: 'verified',
          isProgressionPending: false,
        );
        state = reconciled;
        await _repository.updatePlayerData(reconciled);
        return reconciled;
      }
    } catch (e) {
      // If offline, state remains in local cached projection
      return null;
    }
  }

  void setPlayerData(PlayerData data) {
    state = data;
    _repository.updatePlayerData(data);
  }

  /// Allocates stat points locally (optimistic pending mutation).
  void incrementStat(String stat) {
    if (state.remainingPoints <= 0) return;
    final updated = state.copyWith(
      remainingPoints: state.remainingPoints - 1,
      str: stat == 'STR' ? state.str + 1 : state.str,
      agi: stat == 'AGI' ? state.agi + 1 : state.agi,
      vit: stat == 'VIT' ? state.vit + 1 : state.vit,
      intStat: stat == 'INT' ? state.intStat + 1 : state.intStat,
      per: stat == 'PER' ? state.per + 1 : state.per,
      syncStatus: 'pending',
    );
    state = updated;
    _repository.updatePlayerData(updated);
  }

  /// Equips an active title on the character.
  Future<void> equipTitle(String? titleId) async {
    final updated = state.copyWith(
      activeTitleId: titleId,
      title: titleId != null ? titleId.toUpperCase().replaceAll('_', ' ') : 'THE AWAKENED',
      syncStatus: 'pending',
    );
    state = updated;
    await _repository.updatePlayerData(updated);

    final remote = _remoteDataSource;
    if (remote != null) {
      try {
        final result = await remote.equipTitle(titleId);
        final verified = state.copyWith(
          activeTitleId: result['activeTitleId'] as String?,
          syncStatus: 'verified',
        );
        state = verified;
        await _repository.updatePlayerData(verified);
      } catch (_) {
        // Keeps pending local projection if network fails
      }
    }
  }

  /// Applies an optimistic pending XP delta.
  ///
  /// IMPORTANT: This MUST NOT compute a new level or rank.
  /// XP, Level, Rank, and Mana are strictly backend-authoritative (SRS §4.28, FR-VALID-1).
  /// The UI shows this as a 'pending' prediction; the server reconciles truth on sync.
  void applyPendingXpDelta(int delta) {
    final updated = state.copyWith(
      exp: state.exp + delta,
      syncStatus: 'pending',
      isProgressionPending: true,
    );
    state = updated;
    _repository.updatePlayerData(updated);
  }

  /// Reconciles local state with server authoritative result.
  /// Overwrites any pending/optimistic values with server-confirmed values.
  void reconcileFromServerResponse(PlayerData serverData) {
    final reconciled = serverData.copyWith(
      syncStatus: 'verified',
      isProgressionPending: false,
    );
    state = reconciled;
    _repository.updatePlayerData(reconciled);
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerData>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  CharacterRemoteDataSource? remoteSource;
  try {
    remoteSource = ref.watch(characterRemoteDataSourceProvider);
  } catch (_) {}

  return PlayerNotifier(repo, remoteDataSource: remoteSource);
});

/// Stream / Future providers for Character History & Aggregates
final characterHistoryProvider = FutureProvider<CharacterTransactionHistory>((ref) async {
  final remoteDataSource = ref.watch(characterRemoteDataSourceProvider);
  try {
    return await remoteDataSource.fetchTransactionHistory();
  } catch (_) {
    return CharacterTransactionHistory.empty;
  }
});

final xpAggregatesProvider = FutureProvider<XpAggregates>((ref) async {
  final remoteDataSource = ref.watch(characterRemoteDataSourceProvider);
  try {
    return await remoteDataSource.fetchXpAggregates();
  } catch (_) {
    return XpAggregates.zero;
  }
});
