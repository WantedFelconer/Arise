import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/arise_database.dart';
import '../../../core/repositories/player_repository.dart';
import '../../../shared/models/player_data.dart';

/// Persistent implementation of [PlayerRepository] backed by Drift SQLite.
///
/// All reads and writes target the local [CharacterSnapshotTable].
/// This acts as the local projection of the server's authoritative state.
class LocalPlayerRepository implements PlayerRepository {
  LocalPlayerRepository(this._db);

  final AriseDatabase _db;

  /// Sentinel user ID used before first successful authentication.
  static const String kLocalUserId = 'local-user';

  @override
  Future<PlayerData> fetchPlayerData([String? userId]) async {
    CharacterSnapshotTableData? snapshot;

    if (userId != null && userId.isNotEmpty) {
      snapshot = await _db.getCharacterSnapshot(userId);
    }

    snapshot ??= await _db.getCharacterSnapshot(kLocalUserId);

    if (snapshot == null) {
      final all = await (_db.select(_db.characterSnapshotTable)..limit(1)).get();
      if (all.isNotEmpty) {
        snapshot = all.first;
      }
    }

    if (snapshot == null) return PlayerData.empty;
    return _snapshotToPlayerData(snapshot);
  }

  @override
  Future<void> updatePlayerData(PlayerData data) async {
    final stats = json.encode({
      'str': data.str,
      'agi': data.agi,
      'vit': data.vit,
      'int': data.intStat,
      'per': data.per,
    });

    final targetUserId = (data.id != null && data.id!.isNotEmpty)
        ? data.id!
        : kLocalUserId;

    await _db.upsertCharacterSnapshot(
      CharacterSnapshotTableCompanion(
        userId: Value(targetUserId),
        name: Value(data.name),
        titleEquipped: Value(data.title.isEmpty ? null : data.title),
        level: Value(data.level),
        totalXp: Value(data.exp),
        mana: Value(data.mp),
        maxMana: Value(data.maxMp),
        energy: Value(data.hp),
        hp: Value(data.hp),
        maxHp: Value(data.maxHp),
        coins: Value(data.gold),
        gems: Value(data.gems),
        rank: Value(data.rank),
        statsJson: Value(stats),
        remainingStatPoints: Value(data.remainingPoints),
        streak: Value(data.streak),
        syncStatus: Value(data.syncStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Saves raw backend CharacterResponse map into SQLite.
  Future<PlayerData> saveServerSnapshot(Map<String, dynamic> rawChar, {String? email, String? difficulty}) async {
    final charId = rawChar['id'] as String? ?? rawChar['userId'] as String? ?? kLocalUserId;
    final level = (rawChar['level'] as num?)?.toInt() ?? 1;
    final totalXp = (rawChar['totalXp'] as num?)?.toInt() ?? 0;
    final xpToNext = (rawChar['xpToNextLevel'] as num?)?.toInt() ?? (100 * level * level);
    final currentMana = (rawChar['currentMana'] as num?)?.toInt() ?? 100;
    final maxMana = (rawChar['maxMana'] as num?)?.toInt() ?? 100;
    final coins = (rawChar['coins'] as num?)?.toInt() ?? 0;
    final gems = (rawChar['gems'] as num?)?.toInt() ?? 0;
    final rank = rawChar['rank'] as String? ?? 'E';
    final activeTitleId = rawChar['activeTitleId'] as String?;
    final statsRaw = rawChar['stats'] as Map<String, dynamic>? ?? {};

    int str = 10, agi = 10, vit = 10, intStat = 10, per = 10;
    if (statsRaw.containsKey('str') || statsRaw.containsKey('STR')) {
      str = (statsRaw['str'] ?? statsRaw['STR'] as num?)?.toInt() ?? 10;
      agi = (statsRaw['agi'] ?? statsRaw['AGI'] as num?)?.toInt() ?? 10;
      vit = (statsRaw['vit'] ?? statsRaw['VIT'] as num?)?.toInt() ?? 10;
      intStat = (statsRaw['int'] ?? statsRaw['INT'] as num?)?.toInt() ?? 10;
      per = (statsRaw['per'] ?? statsRaw['PER'] as num?)?.toInt() ?? 10;
    } else {
      str = (statsRaw['fitness'] as num?)?.toInt() ?? 10;
      agi = (statsRaw['discipline'] as num?)?.toInt() ?? 10;
      vit = (statsRaw['health'] as num?)?.toInt() ?? 10;
      intStat = (statsRaw['intelligence'] as num?)?.toInt() ?? (statsRaw['coding'] as num?)?.toInt() ?? 10;
      per = (statsRaw['creativity'] as num?)?.toInt() ?? 10;
    }

    final statsJson = json.encode({
      'str': str,
      'agi': agi,
      'vit': vit,
      'int': intStat,
      'per': per,
    });

    await _db.upsertCharacterSnapshot(
      CharacterSnapshotTableCompanion(
        userId: Value(charId),
        name: const Value('HUNTER'),
        titleEquipped: Value(activeTitleId),
        level: Value(level),
        totalXp: Value(totalXp),
        mana: Value(currentMana),
        maxMana: Value(maxMana),
        energy: const Value(100),
        hp: const Value(100),
        maxHp: const Value(100),
        coins: Value(coins),
        gems: Value(gems),
        rank: Value(rank),
        statsJson: Value(statsJson),
        remainingStatPoints: const Value(0),
        streak: const Value(0),
        syncStatus: const Value('verified'),
        pendingXpDelta: const Value(0),
        updatedAt: Value(DateTime.now()),
        serverUpdatedAt: Value(DateTime.now()),
      ),
    );

    return PlayerData(
      id: charId,
      name: 'HUNTER',
      title: activeTitleId ?? 'THE AWAKENED',
      activeTitleId: activeTitleId,
      email: email,
      difficultyMode: difficulty,
      level: level,
      rank: rank,
      hp: 100,
      maxHp: 100,
      mp: currentMana,
      maxMp: maxMana,
      exp: totalXp,
      maxExp: totalXp + xpToNext,
      gold: coins,
      gems: gems,
      streak: 0,
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

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  PlayerData _snapshotToPlayerData(CharacterSnapshotTableData row) {
    Map<String, dynamic> stats = {};
    try {
      stats = json.decode(row.statsJson) as Map<String, dynamic>;
    } catch (_) {
      // Malformed JSON — treat as zero stats.
    }

    int str = 10, agi = 10, vit = 10, intStat = 10, per = 10;
    if (stats.containsKey('str') || stats.containsKey('STR')) {
      str = (stats['str'] ?? stats['STR'] as num?)?.toInt() ?? 10;
      agi = (stats['agi'] ?? stats['AGI'] as num?)?.toInt() ?? 10;
      vit = (stats['vit'] ?? stats['VIT'] as num?)?.toInt() ?? 10;
      intStat = (stats['int'] ?? stats['INT'] as num?)?.toInt() ?? 10;
      per = (stats['per'] ?? stats['PER'] as num?)?.toInt() ?? 10;
    } else {
      str = (stats['fitness'] as num?)?.toInt() ?? 10;
      agi = (stats['discipline'] as num?)?.toInt() ?? 10;
      vit = (stats['health'] as num?)?.toInt() ?? 10;
      intStat = (stats['intelligence'] as num?)?.toInt() ?? (stats['coding'] as num?)?.toInt() ?? 10;
      per = (stats['creativity'] as num?)?.toInt() ?? 10;
    }

    final totalXp = row.totalXp;
    final level = row.level;
    // Approximated threshold for next level if not explicitly provided
    final maxExp = 100 * level * level;

    return PlayerData(
      id: row.userId == kLocalUserId ? null : row.userId,
      name: row.name,
      title: row.titleEquipped ?? 'THE AWAKENED',
      activeTitleId: row.titleEquipped,
      level: level,
      rank: row.rank,
      hp: row.hp,
      maxHp: row.maxHp,
      mp: row.mana,
      maxMp: row.maxMana,
      exp: totalXp + row.pendingXpDelta,
      maxExp: maxExp > totalXp ? maxExp : totalXp + 100,
      gold: row.coins,
      gems: row.gems,
      streak: row.streak,
      str: str,
      agi: agi,
      vit: vit,
      intStat: intStat,
      per: per,
      remainingPoints: row.remainingStatPoints,
      syncStatus: row.syncStatus,
      isProgressionPending: row.pendingXpDelta > 0,
    );
  }
}
