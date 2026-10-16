// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arise_database.dart';

// ignore_for_file: type=lint
class $CharacterSnapshotTableTable extends CharacterSnapshotTable
    with TableInfo<$CharacterSnapshotTableTable, CharacterSnapshotTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSnapshotTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('HUNTER'));
  static const VerificationMeta _titleEquippedMeta =
      const VerificationMeta('titleEquipped');
  @override
  late final GeneratedColumn<String> titleEquipped = GeneratedColumn<String>(
      'title_equipped', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _totalXpMeta =
      const VerificationMeta('totalXp');
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
      'total_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manaMeta = const VerificationMeta('mana');
  @override
  late final GeneratedColumn<int> mana = GeneratedColumn<int>(
      'mana', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _maxManaMeta =
      const VerificationMeta('maxMana');
  @override
  late final GeneratedColumn<int> maxMana = GeneratedColumn<int>(
      'max_mana', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
      'energy', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _hpMeta = const VerificationMeta('hp');
  @override
  late final GeneratedColumn<int> hp = GeneratedColumn<int>(
      'hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
      'max_hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
      'coins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gemsMeta = const VerificationMeta('gems');
  @override
  late final GeneratedColumn<int> gems = GeneratedColumn<int>(
      'gems', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<String> rank = GeneratedColumn<String>(
      'rank', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('E'));
  static const VerificationMeta _statsJsonMeta =
      const VerificationMeta('statsJson');
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
      'stats_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _remainingStatPointsMeta =
      const VerificationMeta('remainingStatPoints');
  @override
  late final GeneratedColumn<int> remainingStatPoints = GeneratedColumn<int>(
      'remaining_stat_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
      'streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _pendingXpDeltaMeta =
      const VerificationMeta('pendingXpDelta');
  @override
  late final GeneratedColumn<int> pendingXpDelta = GeneratedColumn<int>(
      'pending_xp_delta', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        name,
        titleEquipped,
        level,
        totalXp,
        mana,
        maxMana,
        energy,
        hp,
        maxHp,
        coins,
        gems,
        rank,
        statsJson,
        remainingStatPoints,
        streak,
        syncStatus,
        pendingXpDelta,
        updatedAt,
        serverUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_snapshot';
  @override
  VerificationContext validateIntegrity(
      Insertable<CharacterSnapshotTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('title_equipped')) {
      context.handle(
          _titleEquippedMeta,
          titleEquipped.isAcceptableOrUnknown(
              data['title_equipped']!, _titleEquippedMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(_totalXpMeta,
          totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta));
    }
    if (data.containsKey('mana')) {
      context.handle(
          _manaMeta, mana.isAcceptableOrUnknown(data['mana']!, _manaMeta));
    }
    if (data.containsKey('max_mana')) {
      context.handle(_maxManaMeta,
          maxMana.isAcceptableOrUnknown(data['max_mana']!, _maxManaMeta));
    }
    if (data.containsKey('energy')) {
      context.handle(_energyMeta,
          energy.isAcceptableOrUnknown(data['energy']!, _energyMeta));
    }
    if (data.containsKey('hp')) {
      context.handle(_hpMeta, hp.isAcceptableOrUnknown(data['hp']!, _hpMeta));
    }
    if (data.containsKey('max_hp')) {
      context.handle(
          _maxHpMeta, maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta));
    }
    if (data.containsKey('coins')) {
      context.handle(
          _coinsMeta, coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta));
    }
    if (data.containsKey('gems')) {
      context.handle(
          _gemsMeta, gems.isAcceptableOrUnknown(data['gems']!, _gemsMeta));
    }
    if (data.containsKey('rank')) {
      context.handle(
          _rankMeta, rank.isAcceptableOrUnknown(data['rank']!, _rankMeta));
    }
    if (data.containsKey('stats_json')) {
      context.handle(_statsJsonMeta,
          statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta));
    }
    if (data.containsKey('remaining_stat_points')) {
      context.handle(
          _remainingStatPointsMeta,
          remainingStatPoints.isAcceptableOrUnknown(
              data['remaining_stat_points']!, _remainingStatPointsMeta));
    }
    if (data.containsKey('streak')) {
      context.handle(_streakMeta,
          streak.isAcceptableOrUnknown(data['streak']!, _streakMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('pending_xp_delta')) {
      context.handle(
          _pendingXpDeltaMeta,
          pendingXpDelta.isAcceptableOrUnknown(
              data['pending_xp_delta']!, _pendingXpDeltaMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CharacterSnapshotTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSnapshotTableData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      titleEquipped: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_equipped']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      totalXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_xp'])!,
      mana: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mana'])!,
      maxMana: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_mana'])!,
      energy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}energy'])!,
      hp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hp'])!,
      maxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_hp'])!,
      coins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coins'])!,
      gems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gems'])!,
      rank: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rank'])!,
      statsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stats_json'])!,
      remainingStatPoints: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}remaining_stat_points'])!,
      streak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      pendingXpDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pending_xp_delta'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
    );
  }

  @override
  $CharacterSnapshotTableTable createAlias(String alias) {
    return $CharacterSnapshotTableTable(attachedDatabase, alias);
  }
}

class CharacterSnapshotTableData extends DataClass
    implements Insertable<CharacterSnapshotTableData> {
  final String userId;
  final String name;
  final String? titleEquipped;
  final int level;
  final int totalXp;
  final int mana;
  final int maxMana;
  final int energy;
  final int hp;
  final int maxHp;
  final int coins;
  final int gems;
  final String rank;
  final String statsJson;
  final int remainingStatPoints;
  final int streak;
  final String syncStatus;
  final int pendingXpDelta;
  final DateTime? updatedAt;
  final DateTime? serverUpdatedAt;
  const CharacterSnapshotTableData(
      {required this.userId,
      required this.name,
      this.titleEquipped,
      required this.level,
      required this.totalXp,
      required this.mana,
      required this.maxMana,
      required this.energy,
      required this.hp,
      required this.maxHp,
      required this.coins,
      required this.gems,
      required this.rank,
      required this.statsJson,
      required this.remainingStatPoints,
      required this.streak,
      required this.syncStatus,
      required this.pendingXpDelta,
      this.updatedAt,
      this.serverUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || titleEquipped != null) {
      map['title_equipped'] = Variable<String>(titleEquipped);
    }
    map['level'] = Variable<int>(level);
    map['total_xp'] = Variable<int>(totalXp);
    map['mana'] = Variable<int>(mana);
    map['max_mana'] = Variable<int>(maxMana);
    map['energy'] = Variable<int>(energy);
    map['hp'] = Variable<int>(hp);
    map['max_hp'] = Variable<int>(maxHp);
    map['coins'] = Variable<int>(coins);
    map['gems'] = Variable<int>(gems);
    map['rank'] = Variable<String>(rank);
    map['stats_json'] = Variable<String>(statsJson);
    map['remaining_stat_points'] = Variable<int>(remainingStatPoints);
    map['streak'] = Variable<int>(streak);
    map['sync_status'] = Variable<String>(syncStatus);
    map['pending_xp_delta'] = Variable<int>(pendingXpDelta);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    return map;
  }

  CharacterSnapshotTableCompanion toCompanion(bool nullToAbsent) {
    return CharacterSnapshotTableCompanion(
      userId: Value(userId),
      name: Value(name),
      titleEquipped: titleEquipped == null && nullToAbsent
          ? const Value.absent()
          : Value(titleEquipped),
      level: Value(level),
      totalXp: Value(totalXp),
      mana: Value(mana),
      maxMana: Value(maxMana),
      energy: Value(energy),
      hp: Value(hp),
      maxHp: Value(maxHp),
      coins: Value(coins),
      gems: Value(gems),
      rank: Value(rank),
      statsJson: Value(statsJson),
      remainingStatPoints: Value(remainingStatPoints),
      streak: Value(streak),
      syncStatus: Value(syncStatus),
      pendingXpDelta: Value(pendingXpDelta),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory CharacterSnapshotTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSnapshotTableData(
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      titleEquipped: serializer.fromJson<String?>(json['titleEquipped']),
      level: serializer.fromJson<int>(json['level']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      mana: serializer.fromJson<int>(json['mana']),
      maxMana: serializer.fromJson<int>(json['maxMana']),
      energy: serializer.fromJson<int>(json['energy']),
      hp: serializer.fromJson<int>(json['hp']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      coins: serializer.fromJson<int>(json['coins']),
      gems: serializer.fromJson<int>(json['gems']),
      rank: serializer.fromJson<String>(json['rank']),
      statsJson: serializer.fromJson<String>(json['statsJson']),
      remainingStatPoints:
          serializer.fromJson<int>(json['remainingStatPoints']),
      streak: serializer.fromJson<int>(json['streak']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      pendingXpDelta: serializer.fromJson<int>(json['pendingXpDelta']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'titleEquipped': serializer.toJson<String?>(titleEquipped),
      'level': serializer.toJson<int>(level),
      'totalXp': serializer.toJson<int>(totalXp),
      'mana': serializer.toJson<int>(mana),
      'maxMana': serializer.toJson<int>(maxMana),
      'energy': serializer.toJson<int>(energy),
      'hp': serializer.toJson<int>(hp),
      'maxHp': serializer.toJson<int>(maxHp),
      'coins': serializer.toJson<int>(coins),
      'gems': serializer.toJson<int>(gems),
      'rank': serializer.toJson<String>(rank),
      'statsJson': serializer.toJson<String>(statsJson),
      'remainingStatPoints': serializer.toJson<int>(remainingStatPoints),
      'streak': serializer.toJson<int>(streak),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'pendingXpDelta': serializer.toJson<int>(pendingXpDelta),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
    };
  }

  CharacterSnapshotTableData copyWith(
          {String? userId,
          String? name,
          Value<String?> titleEquipped = const Value.absent(),
          int? level,
          int? totalXp,
          int? mana,
          int? maxMana,
          int? energy,
          int? hp,
          int? maxHp,
          int? coins,
          int? gems,
          String? rank,
          String? statsJson,
          int? remainingStatPoints,
          int? streak,
          String? syncStatus,
          int? pendingXpDelta,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> serverUpdatedAt = const Value.absent()}) =>
      CharacterSnapshotTableData(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        titleEquipped:
            titleEquipped.present ? titleEquipped.value : this.titleEquipped,
        level: level ?? this.level,
        totalXp: totalXp ?? this.totalXp,
        mana: mana ?? this.mana,
        maxMana: maxMana ?? this.maxMana,
        energy: energy ?? this.energy,
        hp: hp ?? this.hp,
        maxHp: maxHp ?? this.maxHp,
        coins: coins ?? this.coins,
        gems: gems ?? this.gems,
        rank: rank ?? this.rank,
        statsJson: statsJson ?? this.statsJson,
        remainingStatPoints: remainingStatPoints ?? this.remainingStatPoints,
        streak: streak ?? this.streak,
        syncStatus: syncStatus ?? this.syncStatus,
        pendingXpDelta: pendingXpDelta ?? this.pendingXpDelta,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
      );
  CharacterSnapshotTableData copyWithCompanion(
      CharacterSnapshotTableCompanion data) {
    return CharacterSnapshotTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      titleEquipped: data.titleEquipped.present
          ? data.titleEquipped.value
          : this.titleEquipped,
      level: data.level.present ? data.level.value : this.level,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      mana: data.mana.present ? data.mana.value : this.mana,
      maxMana: data.maxMana.present ? data.maxMana.value : this.maxMana,
      energy: data.energy.present ? data.energy.value : this.energy,
      hp: data.hp.present ? data.hp.value : this.hp,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      coins: data.coins.present ? data.coins.value : this.coins,
      gems: data.gems.present ? data.gems.value : this.gems,
      rank: data.rank.present ? data.rank.value : this.rank,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
      remainingStatPoints: data.remainingStatPoints.present
          ? data.remainingStatPoints.value
          : this.remainingStatPoints,
      streak: data.streak.present ? data.streak.value : this.streak,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      pendingXpDelta: data.pendingXpDelta.present
          ? data.pendingXpDelta.value
          : this.pendingXpDelta,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSnapshotTableData(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('titleEquipped: $titleEquipped, ')
          ..write('level: $level, ')
          ..write('totalXp: $totalXp, ')
          ..write('mana: $mana, ')
          ..write('maxMana: $maxMana, ')
          ..write('energy: $energy, ')
          ..write('hp: $hp, ')
          ..write('maxHp: $maxHp, ')
          ..write('coins: $coins, ')
          ..write('gems: $gems, ')
          ..write('rank: $rank, ')
          ..write('statsJson: $statsJson, ')
          ..write('remainingStatPoints: $remainingStatPoints, ')
          ..write('streak: $streak, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('pendingXpDelta: $pendingXpDelta, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      name,
      titleEquipped,
      level,
      totalXp,
      mana,
      maxMana,
      energy,
      hp,
      maxHp,
      coins,
      gems,
      rank,
      statsJson,
      remainingStatPoints,
      streak,
      syncStatus,
      pendingXpDelta,
      updatedAt,
      serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSnapshotTableData &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.titleEquipped == this.titleEquipped &&
          other.level == this.level &&
          other.totalXp == this.totalXp &&
          other.mana == this.mana &&
          other.maxMana == this.maxMana &&
          other.energy == this.energy &&
          other.hp == this.hp &&
          other.maxHp == this.maxHp &&
          other.coins == this.coins &&
          other.gems == this.gems &&
          other.rank == this.rank &&
          other.statsJson == this.statsJson &&
          other.remainingStatPoints == this.remainingStatPoints &&
          other.streak == this.streak &&
          other.syncStatus == this.syncStatus &&
          other.pendingXpDelta == this.pendingXpDelta &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class CharacterSnapshotTableCompanion
    extends UpdateCompanion<CharacterSnapshotTableData> {
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> titleEquipped;
  final Value<int> level;
  final Value<int> totalXp;
  final Value<int> mana;
  final Value<int> maxMana;
  final Value<int> energy;
  final Value<int> hp;
  final Value<int> maxHp;
  final Value<int> coins;
  final Value<int> gems;
  final Value<String> rank;
  final Value<String> statsJson;
  final Value<int> remainingStatPoints;
  final Value<int> streak;
  final Value<String> syncStatus;
  final Value<int> pendingXpDelta;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<int> rowid;
  const CharacterSnapshotTableCompanion({
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.titleEquipped = const Value.absent(),
    this.level = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.mana = const Value.absent(),
    this.maxMana = const Value.absent(),
    this.energy = const Value.absent(),
    this.hp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.coins = const Value.absent(),
    this.gems = const Value.absent(),
    this.rank = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.remainingStatPoints = const Value.absent(),
    this.streak = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.pendingXpDelta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterSnapshotTableCompanion.insert({
    required String userId,
    this.name = const Value.absent(),
    this.titleEquipped = const Value.absent(),
    this.level = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.mana = const Value.absent(),
    this.maxMana = const Value.absent(),
    this.energy = const Value.absent(),
    this.hp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.coins = const Value.absent(),
    this.gems = const Value.absent(),
    this.rank = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.remainingStatPoints = const Value.absent(),
    this.streak = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.pendingXpDelta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<CharacterSnapshotTableData> custom({
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? titleEquipped,
    Expression<int>? level,
    Expression<int>? totalXp,
    Expression<int>? mana,
    Expression<int>? maxMana,
    Expression<int>? energy,
    Expression<int>? hp,
    Expression<int>? maxHp,
    Expression<int>? coins,
    Expression<int>? gems,
    Expression<String>? rank,
    Expression<String>? statsJson,
    Expression<int>? remainingStatPoints,
    Expression<int>? streak,
    Expression<String>? syncStatus,
    Expression<int>? pendingXpDelta,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (titleEquipped != null) 'title_equipped': titleEquipped,
      if (level != null) 'level': level,
      if (totalXp != null) 'total_xp': totalXp,
      if (mana != null) 'mana': mana,
      if (maxMana != null) 'max_mana': maxMana,
      if (energy != null) 'energy': energy,
      if (hp != null) 'hp': hp,
      if (maxHp != null) 'max_hp': maxHp,
      if (coins != null) 'coins': coins,
      if (gems != null) 'gems': gems,
      if (rank != null) 'rank': rank,
      if (statsJson != null) 'stats_json': statsJson,
      if (remainingStatPoints != null)
        'remaining_stat_points': remainingStatPoints,
      if (streak != null) 'streak': streak,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (pendingXpDelta != null) 'pending_xp_delta': pendingXpDelta,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterSnapshotTableCompanion copyWith(
      {Value<String>? userId,
      Value<String>? name,
      Value<String?>? titleEquipped,
      Value<int>? level,
      Value<int>? totalXp,
      Value<int>? mana,
      Value<int>? maxMana,
      Value<int>? energy,
      Value<int>? hp,
      Value<int>? maxHp,
      Value<int>? coins,
      Value<int>? gems,
      Value<String>? rank,
      Value<String>? statsJson,
      Value<int>? remainingStatPoints,
      Value<int>? streak,
      Value<String>? syncStatus,
      Value<int>? pendingXpDelta,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<int>? rowid}) {
    return CharacterSnapshotTableCompanion(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      titleEquipped: titleEquipped ?? this.titleEquipped,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      energy: energy ?? this.energy,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      rank: rank ?? this.rank,
      statsJson: statsJson ?? this.statsJson,
      remainingStatPoints: remainingStatPoints ?? this.remainingStatPoints,
      streak: streak ?? this.streak,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingXpDelta: pendingXpDelta ?? this.pendingXpDelta,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (titleEquipped.present) {
      map['title_equipped'] = Variable<String>(titleEquipped.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (mana.present) {
      map['mana'] = Variable<int>(mana.value);
    }
    if (maxMana.present) {
      map['max_mana'] = Variable<int>(maxMana.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (hp.present) {
      map['hp'] = Variable<int>(hp.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (gems.present) {
      map['gems'] = Variable<int>(gems.value);
    }
    if (rank.present) {
      map['rank'] = Variable<String>(rank.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (remainingStatPoints.present) {
      map['remaining_stat_points'] = Variable<int>(remainingStatPoints.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (pendingXpDelta.present) {
      map['pending_xp_delta'] = Variable<int>(pendingXpDelta.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSnapshotTableCompanion(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('titleEquipped: $titleEquipped, ')
          ..write('level: $level, ')
          ..write('totalXp: $totalXp, ')
          ..write('mana: $mana, ')
          ..write('maxMana: $maxMana, ')
          ..write('energy: $energy, ')
          ..write('hp: $hp, ')
          ..write('maxHp: $maxHp, ')
          ..write('coins: $coins, ')
          ..write('gems: $gems, ')
          ..write('rank: $rank, ')
          ..write('statsJson: $statsJson, ')
          ..write('remainingStatPoints: $remainingStatPoints, ')
          ..write('streak: $streak, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('pendingXpDelta: $pendingXpDelta, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestsTableTable extends QuestsTable
    with TableInfo<$QuestsTableTable, QuestsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bossIdMeta = const VerificationMeta('bossId');
  @override
  late final GeneratedColumn<String> bossId = GeneratedColumn<String>(
      'boss_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentQuestIdMeta =
      const VerificationMeta('parentQuestId');
  @override
  late final GeneratedColumn<String> parentQuestId = GeneratedColumn<String>(
      'parent_quest_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _questTypeMeta =
      const VerificationMeta('questType');
  @override
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
      'quest_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('side'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _deadlineUtcMeta =
      const VerificationMeta('deadlineUtc');
  @override
  late final GeneratedColumn<DateTime> deadlineUtc = GeneratedColumn<DateTime>(
      'deadline_utc', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deadlineDisplayMeta =
      const VerificationMeta('deadlineDisplay');
  @override
  late final GeneratedColumn<String> deadlineDisplay = GeneratedColumn<String>(
      'deadline_display', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _actualMinutesMeta =
      const VerificationMeta('actualMinutes');
  @override
  late final GeneratedColumn<int> actualMinutes = GeneratedColumn<int>(
      'actual_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _xpRewardMeta =
      const VerificationMeta('xpReward');
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
      'xp_reward', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manaRewardMeta =
      const VerificationMeta('manaReward');
  @override
  late final GeneratedColumn<int> manaReward = GeneratedColumn<int>(
      'mana_reward', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        bossId,
        parentQuestId,
        title,
        description,
        questType,
        priority,
        difficulty,
        deadlineUtc,
        deadlineDisplay,
        estimatedMinutes,
        actualMinutes,
        status,
        tagsJson,
        xpReward,
        manaReward,
        isFavorite,
        isPinned,
        idempotencyKey,
        syncStatus,
        isDirty,
        createdAt,
        updatedAt,
        completedAt,
        serverRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(Insertable<QuestsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(_bossIdMeta,
          bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta));
    }
    if (data.containsKey('parent_quest_id')) {
      context.handle(
          _parentQuestIdMeta,
          parentQuestId.isAcceptableOrUnknown(
              data['parent_quest_id']!, _parentQuestIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('quest_type')) {
      context.handle(_questTypeMeta,
          questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('deadline_utc')) {
      context.handle(
          _deadlineUtcMeta,
          deadlineUtc.isAcceptableOrUnknown(
              data['deadline_utc']!, _deadlineUtcMeta));
    }
    if (data.containsKey('deadline_display')) {
      context.handle(
          _deadlineDisplayMeta,
          deadlineDisplay.isAcceptableOrUnknown(
              data['deadline_display']!, _deadlineDisplayMeta));
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    }
    if (data.containsKey('actual_minutes')) {
      context.handle(
          _actualMinutesMeta,
          actualMinutes.isAcceptableOrUnknown(
              data['actual_minutes']!, _actualMinutesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('xp_reward')) {
      context.handle(_xpRewardMeta,
          xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta));
    }
    if (data.containsKey('mana_reward')) {
      context.handle(
          _manaRewardMeta,
          manaReward.isAcceptableOrUnknown(
              data['mana_reward']!, _manaRewardMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      bossId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boss_id']),
      parentQuestId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_quest_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      questType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quest_type'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      deadlineUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline_utc']),
      deadlineDisplay: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deadline_display']),
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes'])!,
      actualMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_minutes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      xpReward: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}xp_reward'])!,
      manaReward: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mana_reward'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision'])!,
    );
  }

  @override
  $QuestsTableTable createAlias(String alias) {
    return $QuestsTableTable(attachedDatabase, alias);
  }
}

class QuestsTableData extends DataClass implements Insertable<QuestsTableData> {
  final String id;
  final String userId;
  final String? bossId;
  final String? parentQuestId;
  final String title;
  final String description;
  final String questType;
  final String priority;
  final String difficulty;
  final DateTime? deadlineUtc;
  final String? deadlineDisplay;
  final int estimatedMinutes;
  final int? actualMinutes;
  final String status;
  final String tagsJson;
  final int xpReward;
  final int manaReward;
  final bool isFavorite;
  final bool isPinned;
  final String idempotencyKey;
  final String syncStatus;
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int serverRevision;
  const QuestsTableData(
      {required this.id,
      required this.userId,
      this.bossId,
      this.parentQuestId,
      required this.title,
      required this.description,
      required this.questType,
      required this.priority,
      required this.difficulty,
      this.deadlineUtc,
      this.deadlineDisplay,
      required this.estimatedMinutes,
      this.actualMinutes,
      required this.status,
      required this.tagsJson,
      required this.xpReward,
      required this.manaReward,
      required this.isFavorite,
      required this.isPinned,
      required this.idempotencyKey,
      required this.syncStatus,
      required this.isDirty,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt,
      required this.serverRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || bossId != null) {
      map['boss_id'] = Variable<String>(bossId);
    }
    if (!nullToAbsent || parentQuestId != null) {
      map['parent_quest_id'] = Variable<String>(parentQuestId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['quest_type'] = Variable<String>(questType);
    map['priority'] = Variable<String>(priority);
    map['difficulty'] = Variable<String>(difficulty);
    if (!nullToAbsent || deadlineUtc != null) {
      map['deadline_utc'] = Variable<DateTime>(deadlineUtc);
    }
    if (!nullToAbsent || deadlineDisplay != null) {
      map['deadline_display'] = Variable<String>(deadlineDisplay);
    }
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    if (!nullToAbsent || actualMinutes != null) {
      map['actual_minutes'] = Variable<int>(actualMinutes);
    }
    map['status'] = Variable<String>(status);
    map['tags_json'] = Variable<String>(tagsJson);
    map['xp_reward'] = Variable<int>(xpReward);
    map['mana_reward'] = Variable<int>(manaReward);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['server_revision'] = Variable<int>(serverRevision);
    return map;
  }

  QuestsTableCompanion toCompanion(bool nullToAbsent) {
    return QuestsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      bossId:
          bossId == null && nullToAbsent ? const Value.absent() : Value(bossId),
      parentQuestId: parentQuestId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentQuestId),
      title: Value(title),
      description: Value(description),
      questType: Value(questType),
      priority: Value(priority),
      difficulty: Value(difficulty),
      deadlineUtc: deadlineUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineUtc),
      deadlineDisplay: deadlineDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineDisplay),
      estimatedMinutes: Value(estimatedMinutes),
      actualMinutes: actualMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMinutes),
      status: Value(status),
      tagsJson: Value(tagsJson),
      xpReward: Value(xpReward),
      manaReward: Value(manaReward),
      isFavorite: Value(isFavorite),
      isPinned: Value(isPinned),
      idempotencyKey: Value(idempotencyKey),
      syncStatus: Value(syncStatus),
      isDirty: Value(isDirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      serverRevision: Value(serverRevision),
    );
  }

  factory QuestsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      bossId: serializer.fromJson<String?>(json['bossId']),
      parentQuestId: serializer.fromJson<String?>(json['parentQuestId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      questType: serializer.fromJson<String>(json['questType']),
      priority: serializer.fromJson<String>(json['priority']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      deadlineUtc: serializer.fromJson<DateTime?>(json['deadlineUtc']),
      deadlineDisplay: serializer.fromJson<String?>(json['deadlineDisplay']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      actualMinutes: serializer.fromJson<int?>(json['actualMinutes']),
      status: serializer.fromJson<String>(json['status']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      manaReward: serializer.fromJson<int>(json['manaReward']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'bossId': serializer.toJson<String?>(bossId),
      'parentQuestId': serializer.toJson<String?>(parentQuestId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'questType': serializer.toJson<String>(questType),
      'priority': serializer.toJson<String>(priority),
      'difficulty': serializer.toJson<String>(difficulty),
      'deadlineUtc': serializer.toJson<DateTime?>(deadlineUtc),
      'deadlineDisplay': serializer.toJson<String?>(deadlineDisplay),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'actualMinutes': serializer.toJson<int?>(actualMinutes),
      'status': serializer.toJson<String>(status),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'xpReward': serializer.toJson<int>(xpReward),
      'manaReward': serializer.toJson<int>(manaReward),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isPinned': serializer.toJson<bool>(isPinned),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'serverRevision': serializer.toJson<int>(serverRevision),
    };
  }

  QuestsTableData copyWith(
          {String? id,
          String? userId,
          Value<String?> bossId = const Value.absent(),
          Value<String?> parentQuestId = const Value.absent(),
          String? title,
          String? description,
          String? questType,
          String? priority,
          String? difficulty,
          Value<DateTime?> deadlineUtc = const Value.absent(),
          Value<String?> deadlineDisplay = const Value.absent(),
          int? estimatedMinutes,
          Value<int?> actualMinutes = const Value.absent(),
          String? status,
          String? tagsJson,
          int? xpReward,
          int? manaReward,
          bool? isFavorite,
          bool? isPinned,
          String? idempotencyKey,
          String? syncStatus,
          bool? isDirty,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          int? serverRevision}) =>
      QuestsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        bossId: bossId.present ? bossId.value : this.bossId,
        parentQuestId:
            parentQuestId.present ? parentQuestId.value : this.parentQuestId,
        title: title ?? this.title,
        description: description ?? this.description,
        questType: questType ?? this.questType,
        priority: priority ?? this.priority,
        difficulty: difficulty ?? this.difficulty,
        deadlineUtc: deadlineUtc.present ? deadlineUtc.value : this.deadlineUtc,
        deadlineDisplay: deadlineDisplay.present
            ? deadlineDisplay.value
            : this.deadlineDisplay,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        actualMinutes:
            actualMinutes.present ? actualMinutes.value : this.actualMinutes,
        status: status ?? this.status,
        tagsJson: tagsJson ?? this.tagsJson,
        xpReward: xpReward ?? this.xpReward,
        manaReward: manaReward ?? this.manaReward,
        isFavorite: isFavorite ?? this.isFavorite,
        isPinned: isPinned ?? this.isPinned,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        serverRevision: serverRevision ?? this.serverRevision,
      );
  QuestsTableData copyWithCompanion(QuestsTableCompanion data) {
    return QuestsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      parentQuestId: data.parentQuestId.present
          ? data.parentQuestId.value
          : this.parentQuestId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      questType: data.questType.present ? data.questType.value : this.questType,
      priority: data.priority.present ? data.priority.value : this.priority,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      deadlineUtc:
          data.deadlineUtc.present ? data.deadlineUtc.value : this.deadlineUtc,
      deadlineDisplay: data.deadlineDisplay.present
          ? data.deadlineDisplay.value
          : this.deadlineDisplay,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      actualMinutes: data.actualMinutes.present
          ? data.actualMinutes.value
          : this.actualMinutes,
      status: data.status.present ? data.status.value : this.status,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      manaReward:
          data.manaReward.present ? data.manaReward.value : this.manaReward,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bossId: $bossId, ')
          ..write('parentQuestId: $parentQuestId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('questType: $questType, ')
          ..write('priority: $priority, ')
          ..write('difficulty: $difficulty, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('deadlineDisplay: $deadlineDisplay, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('status: $status, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('xpReward: $xpReward, ')
          ..write('manaReward: $manaReward, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('serverRevision: $serverRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        bossId,
        parentQuestId,
        title,
        description,
        questType,
        priority,
        difficulty,
        deadlineUtc,
        deadlineDisplay,
        estimatedMinutes,
        actualMinutes,
        status,
        tagsJson,
        xpReward,
        manaReward,
        isFavorite,
        isPinned,
        idempotencyKey,
        syncStatus,
        isDirty,
        createdAt,
        updatedAt,
        completedAt,
        serverRevision
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.bossId == this.bossId &&
          other.parentQuestId == this.parentQuestId &&
          other.title == this.title &&
          other.description == this.description &&
          other.questType == this.questType &&
          other.priority == this.priority &&
          other.difficulty == this.difficulty &&
          other.deadlineUtc == this.deadlineUtc &&
          other.deadlineDisplay == this.deadlineDisplay &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.actualMinutes == this.actualMinutes &&
          other.status == this.status &&
          other.tagsJson == this.tagsJson &&
          other.xpReward == this.xpReward &&
          other.manaReward == this.manaReward &&
          other.isFavorite == this.isFavorite &&
          other.isPinned == this.isPinned &&
          other.idempotencyKey == this.idempotencyKey &&
          other.syncStatus == this.syncStatus &&
          other.isDirty == this.isDirty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.serverRevision == this.serverRevision);
}

class QuestsTableCompanion extends UpdateCompanion<QuestsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> bossId;
  final Value<String?> parentQuestId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> questType;
  final Value<String> priority;
  final Value<String> difficulty;
  final Value<DateTime?> deadlineUtc;
  final Value<String?> deadlineDisplay;
  final Value<int> estimatedMinutes;
  final Value<int?> actualMinutes;
  final Value<String> status;
  final Value<String> tagsJson;
  final Value<int> xpReward;
  final Value<int> manaReward;
  final Value<bool> isFavorite;
  final Value<bool> isPinned;
  final Value<String> idempotencyKey;
  final Value<String> syncStatus;
  final Value<bool> isDirty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> serverRevision;
  final Value<int> rowid;
  const QuestsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.bossId = const Value.absent(),
    this.parentQuestId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.questType = const Value.absent(),
    this.priority = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.deadlineDisplay = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.manaReward = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestsTableCompanion.insert({
    required String id,
    required String userId,
    this.bossId = const Value.absent(),
    this.parentQuestId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.questType = const Value.absent(),
    this.priority = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.deadlineDisplay = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.manaReward = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    required String idempotencyKey,
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        idempotencyKey = Value(idempotencyKey),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<QuestsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? bossId,
    Expression<String>? parentQuestId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? questType,
    Expression<String>? priority,
    Expression<String>? difficulty,
    Expression<DateTime>? deadlineUtc,
    Expression<String>? deadlineDisplay,
    Expression<int>? estimatedMinutes,
    Expression<int>? actualMinutes,
    Expression<String>? status,
    Expression<String>? tagsJson,
    Expression<int>? xpReward,
    Expression<int>? manaReward,
    Expression<bool>? isFavorite,
    Expression<bool>? isPinned,
    Expression<String>? idempotencyKey,
    Expression<String>? syncStatus,
    Expression<bool>? isDirty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? serverRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (bossId != null) 'boss_id': bossId,
      if (parentQuestId != null) 'parent_quest_id': parentQuestId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (questType != null) 'quest_type': questType,
      if (priority != null) 'priority': priority,
      if (difficulty != null) 'difficulty': difficulty,
      if (deadlineUtc != null) 'deadline_utc': deadlineUtc,
      if (deadlineDisplay != null) 'deadline_display': deadlineDisplay,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (actualMinutes != null) 'actual_minutes': actualMinutes,
      if (status != null) 'status': status,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (xpReward != null) 'xp_reward': xpReward,
      if (manaReward != null) 'mana_reward': manaReward,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isPinned != null) 'is_pinned': isPinned,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? bossId,
      Value<String?>? parentQuestId,
      Value<String>? title,
      Value<String>? description,
      Value<String>? questType,
      Value<String>? priority,
      Value<String>? difficulty,
      Value<DateTime?>? deadlineUtc,
      Value<String?>? deadlineDisplay,
      Value<int>? estimatedMinutes,
      Value<int?>? actualMinutes,
      Value<String>? status,
      Value<String>? tagsJson,
      Value<int>? xpReward,
      Value<int>? manaReward,
      Value<bool>? isFavorite,
      Value<bool>? isPinned,
      Value<String>? idempotencyKey,
      Value<String>? syncStatus,
      Value<bool>? isDirty,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? completedAt,
      Value<int>? serverRevision,
      Value<int>? rowid}) {
    return QuestsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bossId: bossId ?? this.bossId,
      parentQuestId: parentQuestId ?? this.parentQuestId,
      title: title ?? this.title,
      description: description ?? this.description,
      questType: questType ?? this.questType,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      deadlineUtc: deadlineUtc ?? this.deadlineUtc,
      deadlineDisplay: deadlineDisplay ?? this.deadlineDisplay,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      status: status ?? this.status,
      tagsJson: tagsJson ?? this.tagsJson,
      xpReward: xpReward ?? this.xpReward,
      manaReward: manaReward ?? this.manaReward,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (parentQuestId.present) {
      map['parent_quest_id'] = Variable<String>(parentQuestId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (deadlineUtc.present) {
      map['deadline_utc'] = Variable<DateTime>(deadlineUtc.value);
    }
    if (deadlineDisplay.present) {
      map['deadline_display'] = Variable<String>(deadlineDisplay.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (actualMinutes.present) {
      map['actual_minutes'] = Variable<int>(actualMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (manaReward.present) {
      map['mana_reward'] = Variable<int>(manaReward.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bossId: $bossId, ')
          ..write('parentQuestId: $parentQuestId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('questType: $questType, ')
          ..write('priority: $priority, ')
          ..write('difficulty: $difficulty, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('deadlineDisplay: $deadlineDisplay, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('status: $status, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('xpReward: $xpReward, ')
          ..write('manaReward: $manaReward, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BossesTableTable extends BossesTable
    with TableInfo<$BossesTableTable, BossesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BossesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dungeonIdMeta =
      const VerificationMeta('dungeonId');
  @override
  late final GeneratedColumn<String> dungeonId = GeneratedColumn<String>(
      'dungeon_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hpMaxMeta = const VerificationMeta('hpMax');
  @override
  late final GeneratedColumn<int> hpMax = GeneratedColumn<int>(
      'hp_max', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hpCurrentMeta =
      const VerificationMeta('hpCurrent');
  @override
  late final GeneratedColumn<int> hpCurrent = GeneratedColumn<int>(
      'hp_current', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _defeatedAtMeta =
      const VerificationMeta('defeatedAt');
  @override
  late final GeneratedColumn<DateTime> defeatedAt = GeneratedColumn<DateTime>(
      'defeated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        dungeonId,
        title,
        description,
        hpMax,
        hpCurrent,
        difficulty,
        status,
        deadline,
        defeatedAt,
        syncStatus,
        isDirty,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bosses_table';
  @override
  VerificationContext validateIntegrity(Insertable<BossesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('dungeon_id')) {
      context.handle(_dungeonIdMeta,
          dungeonId.isAcceptableOrUnknown(data['dungeon_id']!, _dungeonIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('hp_max')) {
      context.handle(
          _hpMaxMeta, hpMax.isAcceptableOrUnknown(data['hp_max']!, _hpMaxMeta));
    } else if (isInserting) {
      context.missing(_hpMaxMeta);
    }
    if (data.containsKey('hp_current')) {
      context.handle(_hpCurrentMeta,
          hpCurrent.isAcceptableOrUnknown(data['hp_current']!, _hpCurrentMeta));
    } else if (isInserting) {
      context.missing(_hpCurrentMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('defeated_at')) {
      context.handle(
          _defeatedAtMeta,
          defeatedAt.isAcceptableOrUnknown(
              data['defeated_at']!, _defeatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BossesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BossesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dungeonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dungeon_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      hpMax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hp_max'])!,
      hpCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hp_current'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      defeatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}defeated_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BossesTableTable createAlias(String alias) {
    return $BossesTableTable(attachedDatabase, alias);
  }
}

class BossesTableData extends DataClass implements Insertable<BossesTableData> {
  final String id;
  final String userId;
  final String? dungeonId;
  final String title;
  final String? description;
  final int hpMax;
  final int hpCurrent;
  final String difficulty;
  final String status;
  final DateTime? deadline;
  final DateTime? defeatedAt;
  final String syncStatus;
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BossesTableData(
      {required this.id,
      required this.userId,
      this.dungeonId,
      required this.title,
      this.description,
      required this.hpMax,
      required this.hpCurrent,
      required this.difficulty,
      required this.status,
      this.deadline,
      this.defeatedAt,
      required this.syncStatus,
      required this.isDirty,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || dungeonId != null) {
      map['dungeon_id'] = Variable<String>(dungeonId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['hp_max'] = Variable<int>(hpMax);
    map['hp_current'] = Variable<int>(hpCurrent);
    map['difficulty'] = Variable<String>(difficulty);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || defeatedAt != null) {
      map['defeated_at'] = Variable<DateTime>(defeatedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BossesTableCompanion toCompanion(bool nullToAbsent) {
    return BossesTableCompanion(
      id: Value(id),
      userId: Value(userId),
      dungeonId: dungeonId == null && nullToAbsent
          ? const Value.absent()
          : Value(dungeonId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      hpMax: Value(hpMax),
      hpCurrent: Value(hpCurrent),
      difficulty: Value(difficulty),
      status: Value(status),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      defeatedAt: defeatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(defeatedAt),
      syncStatus: Value(syncStatus),
      isDirty: Value(isDirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BossesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BossesTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dungeonId: serializer.fromJson<String?>(json['dungeonId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      hpMax: serializer.fromJson<int>(json['hpMax']),
      hpCurrent: serializer.fromJson<int>(json['hpCurrent']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      status: serializer.fromJson<String>(json['status']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      defeatedAt: serializer.fromJson<DateTime?>(json['defeatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dungeonId': serializer.toJson<String?>(dungeonId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'hpMax': serializer.toJson<int>(hpMax),
      'hpCurrent': serializer.toJson<int>(hpCurrent),
      'difficulty': serializer.toJson<String>(difficulty),
      'status': serializer.toJson<String>(status),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'defeatedAt': serializer.toJson<DateTime?>(defeatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BossesTableData copyWith(
          {String? id,
          String? userId,
          Value<String?> dungeonId = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          int? hpMax,
          int? hpCurrent,
          String? difficulty,
          String? status,
          Value<DateTime?> deadline = const Value.absent(),
          Value<DateTime?> defeatedAt = const Value.absent(),
          String? syncStatus,
          bool? isDirty,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BossesTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dungeonId: dungeonId.present ? dungeonId.value : this.dungeonId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        hpMax: hpMax ?? this.hpMax,
        hpCurrent: hpCurrent ?? this.hpCurrent,
        difficulty: difficulty ?? this.difficulty,
        status: status ?? this.status,
        deadline: deadline.present ? deadline.value : this.deadline,
        defeatedAt: defeatedAt.present ? defeatedAt.value : this.defeatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BossesTableData copyWithCompanion(BossesTableCompanion data) {
    return BossesTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dungeonId: data.dungeonId.present ? data.dungeonId.value : this.dungeonId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      hpMax: data.hpMax.present ? data.hpMax.value : this.hpMax,
      hpCurrent: data.hpCurrent.present ? data.hpCurrent.value : this.hpCurrent,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      status: data.status.present ? data.status.value : this.status,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      defeatedAt:
          data.defeatedAt.present ? data.defeatedAt.value : this.defeatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BossesTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dungeonId: $dungeonId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('hpMax: $hpMax, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('difficulty: $difficulty, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('defeatedAt: $defeatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      dungeonId,
      title,
      description,
      hpMax,
      hpCurrent,
      difficulty,
      status,
      deadline,
      defeatedAt,
      syncStatus,
      isDirty,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BossesTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dungeonId == this.dungeonId &&
          other.title == this.title &&
          other.description == this.description &&
          other.hpMax == this.hpMax &&
          other.hpCurrent == this.hpCurrent &&
          other.difficulty == this.difficulty &&
          other.status == this.status &&
          other.deadline == this.deadline &&
          other.defeatedAt == this.defeatedAt &&
          other.syncStatus == this.syncStatus &&
          other.isDirty == this.isDirty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BossesTableCompanion extends UpdateCompanion<BossesTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> dungeonId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> hpMax;
  final Value<int> hpCurrent;
  final Value<String> difficulty;
  final Value<String> status;
  final Value<DateTime?> deadline;
  final Value<DateTime?> defeatedAt;
  final Value<String> syncStatus;
  final Value<bool> isDirty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BossesTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dungeonId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.hpMax = const Value.absent(),
    this.hpCurrent = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.defeatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BossesTableCompanion.insert({
    required String id,
    required String userId,
    this.dungeonId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int hpMax,
    required int hpCurrent,
    this.difficulty = const Value.absent(),
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.defeatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        hpMax = Value(hpMax),
        hpCurrent = Value(hpCurrent),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<BossesTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dungeonId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? hpMax,
    Expression<int>? hpCurrent,
    Expression<String>? difficulty,
    Expression<String>? status,
    Expression<DateTime>? deadline,
    Expression<DateTime>? defeatedAt,
    Expression<String>? syncStatus,
    Expression<bool>? isDirty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dungeonId != null) 'dungeon_id': dungeonId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (hpMax != null) 'hp_max': hpMax,
      if (hpCurrent != null) 'hp_current': hpCurrent,
      if (difficulty != null) 'difficulty': difficulty,
      if (status != null) 'status': status,
      if (deadline != null) 'deadline': deadline,
      if (defeatedAt != null) 'defeated_at': defeatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BossesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? dungeonId,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? hpMax,
      Value<int>? hpCurrent,
      Value<String>? difficulty,
      Value<String>? status,
      Value<DateTime?>? deadline,
      Value<DateTime?>? defeatedAt,
      Value<String>? syncStatus,
      Value<bool>? isDirty,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BossesTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dungeonId: dungeonId ?? this.dungeonId,
      title: title ?? this.title,
      description: description ?? this.description,
      hpMax: hpMax ?? this.hpMax,
      hpCurrent: hpCurrent ?? this.hpCurrent,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      defeatedAt: defeatedAt ?? this.defeatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dungeonId.present) {
      map['dungeon_id'] = Variable<String>(dungeonId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (hpMax.present) {
      map['hp_max'] = Variable<int>(hpMax.value);
    }
    if (hpCurrent.present) {
      map['hp_current'] = Variable<int>(hpCurrent.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (defeatedAt.present) {
      map['defeated_at'] = Variable<DateTime>(defeatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BossesTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dungeonId: $dungeonId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('hpMax: $hpMax, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('difficulty: $difficulty, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('defeatedAt: $defeatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DungeonsTableTable extends DungeonsTable
    with TableInfo<$DungeonsTableTable, DungeonsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DungeonsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, title, status, syncStatus, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dungeons_table';
  @override
  VerificationContext validateIntegrity(Insertable<DungeonsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DungeonsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DungeonsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DungeonsTableTable createAlias(String alias) {
    return $DungeonsTableTable(attachedDatabase, alias);
  }
}

class DungeonsTableData extends DataClass
    implements Insertable<DungeonsTableData> {
  final String id;
  final String userId;
  final String title;
  final String status;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DungeonsTableData(
      {required this.id,
      required this.userId,
      required this.title,
      required this.status,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DungeonsTableCompanion toCompanion(bool nullToAbsent) {
    return DungeonsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DungeonsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DungeonsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DungeonsTableData copyWith(
          {String? id,
          String? userId,
          String? title,
          String? status,
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DungeonsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        status: status ?? this.status,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DungeonsTableData copyWithCompanion(DungeonsTableCompanion data) {
    return DungeonsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DungeonsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, status, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DungeonsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DungeonsTableCompanion extends UpdateCompanion<DungeonsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DungeonsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DungeonsTableCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DungeonsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DungeonsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String>? status,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DungeonsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DungeonsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GateSessionsTableTable extends GateSessionsTable
    with TableInfo<$GateSessionsTableTable, GateSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GateSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questIdMeta =
      const VerificationMeta('questId');
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
      'quest_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pausedAtMeta =
      const VerificationMeta('pausedAt');
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
      'paused_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _plannedDurationSMeta =
      const VerificationMeta('plannedDurationS');
  @override
  late final GeneratedColumn<int> plannedDurationS = GeneratedColumn<int>(
      'planned_duration_s', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actualDurationSMeta =
      const VerificationMeta('actualDurationS');
  @override
  late final GeneratedColumn<int> actualDurationS = GeneratedColumn<int>(
      'actual_duration_s', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pauseCountMeta =
      const VerificationMeta('pauseCount');
  @override
  late final GeneratedColumn<int> pauseCount = GeneratedColumn<int>(
      'pause_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalPausedDurationSMeta =
      const VerificationMeta('totalPausedDurationS');
  @override
  late final GeneratedColumn<int> totalPausedDurationS = GeneratedColumn<int>(
      'total_paused_duration_s', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _exitReasonMeta =
      const VerificationMeta('exitReason');
  @override
  late final GeneratedColumn<String> exitReason = GeneratedColumn<String>(
      'exit_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _stabilityFinalMeta =
      const VerificationMeta('stabilityFinal');
  @override
  late final GeneratedColumn<double> stabilityFinal = GeneratedColumn<double>(
      'stability_final', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _xpAwardedMeta =
      const VerificationMeta('xpAwarded');
  @override
  late final GeneratedColumn<int> xpAwarded = GeneratedColumn<int>(
      'xp_awarded', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _manaDeltaMeta =
      const VerificationMeta('manaDelta');
  @override
  late final GeneratedColumn<int> manaDelta = GeneratedColumn<int>(
      'mana_delta', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        questId,
        startedAt,
        endedAt,
        pausedAt,
        plannedDurationS,
        actualDurationS,
        pauseCount,
        totalPausedDurationS,
        exitReason,
        status,
        stabilityFinal,
        xpAwarded,
        manaDelta,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gate_sessions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GateSessionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(_questIdMeta,
          questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('paused_at')) {
      context.handle(_pausedAtMeta,
          pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta));
    }
    if (data.containsKey('planned_duration_s')) {
      context.handle(
          _plannedDurationSMeta,
          plannedDurationS.isAcceptableOrUnknown(
              data['planned_duration_s']!, _plannedDurationSMeta));
    } else if (isInserting) {
      context.missing(_plannedDurationSMeta);
    }
    if (data.containsKey('actual_duration_s')) {
      context.handle(
          _actualDurationSMeta,
          actualDurationS.isAcceptableOrUnknown(
              data['actual_duration_s']!, _actualDurationSMeta));
    }
    if (data.containsKey('pause_count')) {
      context.handle(
          _pauseCountMeta,
          pauseCount.isAcceptableOrUnknown(
              data['pause_count']!, _pauseCountMeta));
    }
    if (data.containsKey('total_paused_duration_s')) {
      context.handle(
          _totalPausedDurationSMeta,
          totalPausedDurationS.isAcceptableOrUnknown(
              data['total_paused_duration_s']!, _totalPausedDurationSMeta));
    }
    if (data.containsKey('exit_reason')) {
      context.handle(
          _exitReasonMeta,
          exitReason.isAcceptableOrUnknown(
              data['exit_reason']!, _exitReasonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('stability_final')) {
      context.handle(
          _stabilityFinalMeta,
          stabilityFinal.isAcceptableOrUnknown(
              data['stability_final']!, _stabilityFinalMeta));
    }
    if (data.containsKey('xp_awarded')) {
      context.handle(_xpAwardedMeta,
          xpAwarded.isAcceptableOrUnknown(data['xp_awarded']!, _xpAwardedMeta));
    }
    if (data.containsKey('mana_delta')) {
      context.handle(_manaDeltaMeta,
          manaDelta.isAcceptableOrUnknown(data['mana_delta']!, _manaDeltaMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GateSessionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GateSessionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      questId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quest_id']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      pausedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at']),
      plannedDurationS: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}planned_duration_s'])!,
      actualDurationS: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_duration_s']),
      pauseCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pause_count'])!,
      totalPausedDurationS: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_paused_duration_s'])!,
      exitReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exit_reason']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      stabilityFinal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability_final']),
      xpAwarded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}xp_awarded']),
      manaDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mana_delta']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GateSessionsTableTable createAlias(String alias) {
    return $GateSessionsTableTable(attachedDatabase, alias);
  }
}

class GateSessionsTableData extends DataClass
    implements Insertable<GateSessionsTableData> {
  final String id;
  final String userId;
  final String? questId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? pausedAt;
  final int plannedDurationS;
  final int? actualDurationS;
  final int pauseCount;
  final int totalPausedDurationS;
  final String? exitReason;
  final String status;
  final double? stabilityFinal;
  final int? xpAwarded;
  final int? manaDelta;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GateSessionsTableData(
      {required this.id,
      required this.userId,
      this.questId,
      required this.startedAt,
      this.endedAt,
      this.pausedAt,
      required this.plannedDurationS,
      this.actualDurationS,
      required this.pauseCount,
      required this.totalPausedDurationS,
      this.exitReason,
      required this.status,
      this.stabilityFinal,
      this.xpAwarded,
      this.manaDelta,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || questId != null) {
      map['quest_id'] = Variable<String>(questId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    map['planned_duration_s'] = Variable<int>(plannedDurationS);
    if (!nullToAbsent || actualDurationS != null) {
      map['actual_duration_s'] = Variable<int>(actualDurationS);
    }
    map['pause_count'] = Variable<int>(pauseCount);
    map['total_paused_duration_s'] = Variable<int>(totalPausedDurationS);
    if (!nullToAbsent || exitReason != null) {
      map['exit_reason'] = Variable<String>(exitReason);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || stabilityFinal != null) {
      map['stability_final'] = Variable<double>(stabilityFinal);
    }
    if (!nullToAbsent || xpAwarded != null) {
      map['xp_awarded'] = Variable<int>(xpAwarded);
    }
    if (!nullToAbsent || manaDelta != null) {
      map['mana_delta'] = Variable<int>(manaDelta);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GateSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return GateSessionsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      questId: questId == null && nullToAbsent
          ? const Value.absent()
          : Value(questId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      plannedDurationS: Value(plannedDurationS),
      actualDurationS: actualDurationS == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationS),
      pauseCount: Value(pauseCount),
      totalPausedDurationS: Value(totalPausedDurationS),
      exitReason: exitReason == null && nullToAbsent
          ? const Value.absent()
          : Value(exitReason),
      status: Value(status),
      stabilityFinal: stabilityFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(stabilityFinal),
      xpAwarded: xpAwarded == null && nullToAbsent
          ? const Value.absent()
          : Value(xpAwarded),
      manaDelta: manaDelta == null && nullToAbsent
          ? const Value.absent()
          : Value(manaDelta),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GateSessionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GateSessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      questId: serializer.fromJson<String?>(json['questId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      plannedDurationS: serializer.fromJson<int>(json['plannedDurationS']),
      actualDurationS: serializer.fromJson<int?>(json['actualDurationS']),
      pauseCount: serializer.fromJson<int>(json['pauseCount']),
      totalPausedDurationS:
          serializer.fromJson<int>(json['totalPausedDurationS']),
      exitReason: serializer.fromJson<String?>(json['exitReason']),
      status: serializer.fromJson<String>(json['status']),
      stabilityFinal: serializer.fromJson<double?>(json['stabilityFinal']),
      xpAwarded: serializer.fromJson<int?>(json['xpAwarded']),
      manaDelta: serializer.fromJson<int?>(json['manaDelta']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'questId': serializer.toJson<String?>(questId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'plannedDurationS': serializer.toJson<int>(plannedDurationS),
      'actualDurationS': serializer.toJson<int?>(actualDurationS),
      'pauseCount': serializer.toJson<int>(pauseCount),
      'totalPausedDurationS': serializer.toJson<int>(totalPausedDurationS),
      'exitReason': serializer.toJson<String?>(exitReason),
      'status': serializer.toJson<String>(status),
      'stabilityFinal': serializer.toJson<double?>(stabilityFinal),
      'xpAwarded': serializer.toJson<int?>(xpAwarded),
      'manaDelta': serializer.toJson<int?>(manaDelta),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GateSessionsTableData copyWith(
          {String? id,
          String? userId,
          Value<String?> questId = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          Value<DateTime?> pausedAt = const Value.absent(),
          int? plannedDurationS,
          Value<int?> actualDurationS = const Value.absent(),
          int? pauseCount,
          int? totalPausedDurationS,
          Value<String?> exitReason = const Value.absent(),
          String? status,
          Value<double?> stabilityFinal = const Value.absent(),
          Value<int?> xpAwarded = const Value.absent(),
          Value<int?> manaDelta = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GateSessionsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        questId: questId.present ? questId.value : this.questId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
        plannedDurationS: plannedDurationS ?? this.plannedDurationS,
        actualDurationS: actualDurationS.present
            ? actualDurationS.value
            : this.actualDurationS,
        pauseCount: pauseCount ?? this.pauseCount,
        totalPausedDurationS: totalPausedDurationS ?? this.totalPausedDurationS,
        exitReason: exitReason.present ? exitReason.value : this.exitReason,
        status: status ?? this.status,
        stabilityFinal:
            stabilityFinal.present ? stabilityFinal.value : this.stabilityFinal,
        xpAwarded: xpAwarded.present ? xpAwarded.value : this.xpAwarded,
        manaDelta: manaDelta.present ? manaDelta.value : this.manaDelta,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GateSessionsTableData copyWithCompanion(GateSessionsTableCompanion data) {
    return GateSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      questId: data.questId.present ? data.questId.value : this.questId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      plannedDurationS: data.plannedDurationS.present
          ? data.plannedDurationS.value
          : this.plannedDurationS,
      actualDurationS: data.actualDurationS.present
          ? data.actualDurationS.value
          : this.actualDurationS,
      pauseCount:
          data.pauseCount.present ? data.pauseCount.value : this.pauseCount,
      totalPausedDurationS: data.totalPausedDurationS.present
          ? data.totalPausedDurationS.value
          : this.totalPausedDurationS,
      exitReason:
          data.exitReason.present ? data.exitReason.value : this.exitReason,
      status: data.status.present ? data.status.value : this.status,
      stabilityFinal: data.stabilityFinal.present
          ? data.stabilityFinal.value
          : this.stabilityFinal,
      xpAwarded: data.xpAwarded.present ? data.xpAwarded.value : this.xpAwarded,
      manaDelta: data.manaDelta.present ? data.manaDelta.value : this.manaDelta,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GateSessionsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('questId: $questId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('plannedDurationS: $plannedDurationS, ')
          ..write('actualDurationS: $actualDurationS, ')
          ..write('pauseCount: $pauseCount, ')
          ..write('totalPausedDurationS: $totalPausedDurationS, ')
          ..write('exitReason: $exitReason, ')
          ..write('status: $status, ')
          ..write('stabilityFinal: $stabilityFinal, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('manaDelta: $manaDelta, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      questId,
      startedAt,
      endedAt,
      pausedAt,
      plannedDurationS,
      actualDurationS,
      pauseCount,
      totalPausedDurationS,
      exitReason,
      status,
      stabilityFinal,
      xpAwarded,
      manaDelta,
      syncStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GateSessionsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.questId == this.questId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.pausedAt == this.pausedAt &&
          other.plannedDurationS == this.plannedDurationS &&
          other.actualDurationS == this.actualDurationS &&
          other.pauseCount == this.pauseCount &&
          other.totalPausedDurationS == this.totalPausedDurationS &&
          other.exitReason == this.exitReason &&
          other.status == this.status &&
          other.stabilityFinal == this.stabilityFinal &&
          other.xpAwarded == this.xpAwarded &&
          other.manaDelta == this.manaDelta &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GateSessionsTableCompanion
    extends UpdateCompanion<GateSessionsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> questId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<DateTime?> pausedAt;
  final Value<int> plannedDurationS;
  final Value<int?> actualDurationS;
  final Value<int> pauseCount;
  final Value<int> totalPausedDurationS;
  final Value<String?> exitReason;
  final Value<String> status;
  final Value<double?> stabilityFinal;
  final Value<int?> xpAwarded;
  final Value<int?> manaDelta;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GateSessionsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.questId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.plannedDurationS = const Value.absent(),
    this.actualDurationS = const Value.absent(),
    this.pauseCount = const Value.absent(),
    this.totalPausedDurationS = const Value.absent(),
    this.exitReason = const Value.absent(),
    this.status = const Value.absent(),
    this.stabilityFinal = const Value.absent(),
    this.xpAwarded = const Value.absent(),
    this.manaDelta = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GateSessionsTableCompanion.insert({
    required String id,
    required String userId,
    this.questId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    required int plannedDurationS,
    this.actualDurationS = const Value.absent(),
    this.pauseCount = const Value.absent(),
    this.totalPausedDurationS = const Value.absent(),
    this.exitReason = const Value.absent(),
    this.status = const Value.absent(),
    this.stabilityFinal = const Value.absent(),
    this.xpAwarded = const Value.absent(),
    this.manaDelta = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        startedAt = Value(startedAt),
        plannedDurationS = Value(plannedDurationS),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GateSessionsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? questId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? pausedAt,
    Expression<int>? plannedDurationS,
    Expression<int>? actualDurationS,
    Expression<int>? pauseCount,
    Expression<int>? totalPausedDurationS,
    Expression<String>? exitReason,
    Expression<String>? status,
    Expression<double>? stabilityFinal,
    Expression<int>? xpAwarded,
    Expression<int>? manaDelta,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (questId != null) 'quest_id': questId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (plannedDurationS != null) 'planned_duration_s': plannedDurationS,
      if (actualDurationS != null) 'actual_duration_s': actualDurationS,
      if (pauseCount != null) 'pause_count': pauseCount,
      if (totalPausedDurationS != null)
        'total_paused_duration_s': totalPausedDurationS,
      if (exitReason != null) 'exit_reason': exitReason,
      if (status != null) 'status': status,
      if (stabilityFinal != null) 'stability_final': stabilityFinal,
      if (xpAwarded != null) 'xp_awarded': xpAwarded,
      if (manaDelta != null) 'mana_delta': manaDelta,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GateSessionsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? questId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<DateTime?>? pausedAt,
      Value<int>? plannedDurationS,
      Value<int?>? actualDurationS,
      Value<int>? pauseCount,
      Value<int>? totalPausedDurationS,
      Value<String?>? exitReason,
      Value<String>? status,
      Value<double?>? stabilityFinal,
      Value<int?>? xpAwarded,
      Value<int?>? manaDelta,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GateSessionsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questId: questId ?? this.questId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      plannedDurationS: plannedDurationS ?? this.plannedDurationS,
      actualDurationS: actualDurationS ?? this.actualDurationS,
      pauseCount: pauseCount ?? this.pauseCount,
      totalPausedDurationS: totalPausedDurationS ?? this.totalPausedDurationS,
      exitReason: exitReason ?? this.exitReason,
      status: status ?? this.status,
      stabilityFinal: stabilityFinal ?? this.stabilityFinal,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      manaDelta: manaDelta ?? this.manaDelta,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (plannedDurationS.present) {
      map['planned_duration_s'] = Variable<int>(plannedDurationS.value);
    }
    if (actualDurationS.present) {
      map['actual_duration_s'] = Variable<int>(actualDurationS.value);
    }
    if (pauseCount.present) {
      map['pause_count'] = Variable<int>(pauseCount.value);
    }
    if (totalPausedDurationS.present) {
      map['total_paused_duration_s'] =
          Variable<int>(totalPausedDurationS.value);
    }
    if (exitReason.present) {
      map['exit_reason'] = Variable<String>(exitReason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stabilityFinal.present) {
      map['stability_final'] = Variable<double>(stabilityFinal.value);
    }
    if (xpAwarded.present) {
      map['xp_awarded'] = Variable<int>(xpAwarded.value);
    }
    if (manaDelta.present) {
      map['mana_delta'] = Variable<int>(manaDelta.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GateSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('questId: $questId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('plannedDurationS: $plannedDurationS, ')
          ..write('actualDurationS: $actualDurationS, ')
          ..write('pauseCount: $pauseCount, ')
          ..write('totalPausedDurationS: $totalPausedDurationS, ')
          ..write('exitReason: $exitReason, ')
          ..write('status: $status, ')
          ..write('stabilityFinal: $stabilityFinal, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('manaDelta: $manaDelta, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalEventQueueTableTable extends LocalEventQueueTable
    with TableInfo<$LocalEventQueueTableTable, LocalEventQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEventQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtClientMeta =
      const VerificationMeta('occurredAtClient');
  @override
  late final GeneratedColumn<DateTime> occurredAtClient =
      GeneratedColumn<DateTime>('occurred_at_client', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        eventId,
        userId,
        deviceId,
        eventType,
        payloadJson,
        occurredAtClient,
        syncStatus,
        retryCount,
        version,
        lastError,
        nextRetryAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_event_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalEventQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('occurred_at_client')) {
      context.handle(
          _occurredAtClientMeta,
          occurredAtClient.isAcceptableOrUnknown(
              data['occurred_at_client']!, _occurredAtClientMeta));
    } else if (isInserting) {
      context.missing(_occurredAtClientMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  LocalEventQueueTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEventQueueTableData(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      occurredAtClient: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}occurred_at_client'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
    );
  }

  @override
  $LocalEventQueueTableTable createAlias(String alias) {
    return $LocalEventQueueTableTable(attachedDatabase, alias);
  }
}

class LocalEventQueueTableData extends DataClass
    implements Insertable<LocalEventQueueTableData> {
  final String eventId;
  final String userId;
  final String deviceId;
  final String eventType;
  final String payloadJson;
  final DateTime occurredAtClient;
  final String syncStatus;
  final int retryCount;
  final int version;
  final String? lastError;
  final DateTime? nextRetryAt;
  const LocalEventQueueTableData(
      {required this.eventId,
      required this.userId,
      required this.deviceId,
      required this.eventType,
      required this.payloadJson,
      required this.occurredAtClient,
      required this.syncStatus,
      required this.retryCount,
      required this.version,
      this.lastError,
      this.nextRetryAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['user_id'] = Variable<String>(userId);
    map['device_id'] = Variable<String>(deviceId);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['occurred_at_client'] = Variable<DateTime>(occurredAtClient);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    return map;
  }

  LocalEventQueueTableCompanion toCompanion(bool nullToAbsent) {
    return LocalEventQueueTableCompanion(
      eventId: Value(eventId),
      userId: Value(userId),
      deviceId: Value(deviceId),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      occurredAtClient: Value(occurredAtClient),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      version: Value(version),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
    );
  }

  factory LocalEventQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEventQueueTableData(
      eventId: serializer.fromJson<String>(json['eventId']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      occurredAtClient: serializer.fromJson<DateTime>(json['occurredAtClient']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      version: serializer.fromJson<int>(json['version']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'userId': serializer.toJson<String>(userId),
      'deviceId': serializer.toJson<String>(deviceId),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'occurredAtClient': serializer.toJson<DateTime>(occurredAtClient),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'version': serializer.toJson<int>(version),
      'lastError': serializer.toJson<String?>(lastError),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
    };
  }

  LocalEventQueueTableData copyWith(
          {String? eventId,
          String? userId,
          String? deviceId,
          String? eventType,
          String? payloadJson,
          DateTime? occurredAtClient,
          String? syncStatus,
          int? retryCount,
          int? version,
          Value<String?> lastError = const Value.absent(),
          Value<DateTime?> nextRetryAt = const Value.absent()}) =>
      LocalEventQueueTableData(
        eventId: eventId ?? this.eventId,
        userId: userId ?? this.userId,
        deviceId: deviceId ?? this.deviceId,
        eventType: eventType ?? this.eventType,
        payloadJson: payloadJson ?? this.payloadJson,
        occurredAtClient: occurredAtClient ?? this.occurredAtClient,
        syncStatus: syncStatus ?? this.syncStatus,
        retryCount: retryCount ?? this.retryCount,
        version: version ?? this.version,
        lastError: lastError.present ? lastError.value : this.lastError,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
      );
  LocalEventQueueTableData copyWithCompanion(
      LocalEventQueueTableCompanion data) {
    return LocalEventQueueTableData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      occurredAtClient: data.occurredAtClient.present
          ? data.occurredAtClient.value
          : this.occurredAtClient,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      version: data.version.present ? data.version.value : this.version,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEventQueueTableData(')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAtClient: $occurredAtClient, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('version: $version, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      eventId,
      userId,
      deviceId,
      eventType,
      payloadJson,
      occurredAtClient,
      syncStatus,
      retryCount,
      version,
      lastError,
      nextRetryAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEventQueueTableData &&
          other.eventId == this.eventId &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.occurredAtClient == this.occurredAtClient &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.version == this.version &&
          other.lastError == this.lastError &&
          other.nextRetryAt == this.nextRetryAt);
}

class LocalEventQueueTableCompanion
    extends UpdateCompanion<LocalEventQueueTableData> {
  final Value<String> eventId;
  final Value<String> userId;
  final Value<String> deviceId;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<DateTime> occurredAtClient;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<int> version;
  final Value<String?> lastError;
  final Value<DateTime?> nextRetryAt;
  final Value<int> rowid;
  const LocalEventQueueTableCompanion({
    this.eventId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.occurredAtClient = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.version = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEventQueueTableCompanion.insert({
    required String eventId,
    required String userId,
    required String deviceId,
    required String eventType,
    required String payloadJson,
    required DateTime occurredAtClient,
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.version = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        userId = Value(userId),
        deviceId = Value(deviceId),
        eventType = Value(eventType),
        payloadJson = Value(payloadJson),
        occurredAtClient = Value(occurredAtClient);
  static Insertable<LocalEventQueueTableData> custom({
    Expression<String>? eventId,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<DateTime>? occurredAtClient,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<int>? version,
    Expression<String>? lastError,
    Expression<DateTime>? nextRetryAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (occurredAtClient != null) 'occurred_at_client': occurredAtClient,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (version != null) 'version': version,
      if (lastError != null) 'last_error': lastError,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEventQueueTableCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? userId,
      Value<String>? deviceId,
      Value<String>? eventType,
      Value<String>? payloadJson,
      Value<DateTime>? occurredAtClient,
      Value<String>? syncStatus,
      Value<int>? retryCount,
      Value<int>? version,
      Value<String?>? lastError,
      Value<DateTime?>? nextRetryAt,
      Value<int>? rowid}) {
    return LocalEventQueueTableCompanion(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      occurredAtClient: occurredAtClient ?? this.occurredAtClient,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      version: version ?? this.version,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (occurredAtClient.present) {
      map['occurred_at_client'] = Variable<DateTime>(occurredAtClient.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEventQueueTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAtClient: $occurredAtClient, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('version: $version, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTableTable extends SyncMetaTable
    with TableInfo<$SyncMetaTableTable, SyncMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [entityType, lastSyncedAt, serverRevision];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaTableData(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision'])!,
    );
  }

  @override
  $SyncMetaTableTable createAlias(String alias) {
    return $SyncMetaTableTable(attachedDatabase, alias);
  }
}

class SyncMetaTableData extends DataClass
    implements Insertable<SyncMetaTableData> {
  final String entityType;
  final DateTime? lastSyncedAt;
  final int serverRevision;
  const SyncMetaTableData(
      {required this.entityType,
      this.lastSyncedAt,
      required this.serverRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['server_revision'] = Variable<int>(serverRevision);
    return map;
  }

  SyncMetaTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaTableCompanion(
      entityType: Value(entityType),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      serverRevision: Value(serverRevision),
    );
  }

  factory SyncMetaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaTableData(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'serverRevision': serializer.toJson<int>(serverRevision),
    };
  }

  SyncMetaTableData copyWith(
          {String? entityType,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? serverRevision}) =>
      SyncMetaTableData(
        entityType: entityType ?? this.entityType,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        serverRevision: serverRevision ?? this.serverRevision,
      );
  SyncMetaTableData copyWithCompanion(SyncMetaTableCompanion data) {
    return SyncMetaTableData(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableData(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverRevision: $serverRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastSyncedAt, serverRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaTableData &&
          other.entityType == this.entityType &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.serverRevision == this.serverRevision);
}

class SyncMetaTableCompanion extends UpdateCompanion<SyncMetaTableData> {
  final Value<String> entityType;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> serverRevision;
  final Value<int> rowid;
  const SyncMetaTableCompanion({
    this.entityType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaTableCompanion.insert({
    required String entityType,
    this.lastSyncedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType);
  static Insertable<SyncMetaTableData> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? serverRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaTableCompanion copyWith(
      {Value<String>? entityType,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? serverRevision,
      Value<int>? rowid}) {
    return SyncMetaTableCompanion(
      entityType: entityType ?? this.entityType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTableTable extends AppMetaTable
    with TableInfo<$AppMetaTableTable, AppMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTableTable createAlias(String alias) {
    return $AppMetaTableTable(attachedDatabase, alias);
  }
}

class AppMetaTableData extends DataClass
    implements Insertable<AppMetaTableData> {
  final String key;
  final String value;
  const AppMetaTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaTableCompanion toCompanion(bool nullToAbsent) {
    return AppMetaTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaTableData copyWith({String? key, String? value}) => AppMetaTableData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaTableData copyWithCompanion(AppMetaTableCompanion data) {
    return AppMetaTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaTableCompanion extends UpdateCompanion<AppMetaTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AriseDatabase extends GeneratedDatabase {
  _$AriseDatabase(QueryExecutor e) : super(e);
  $AriseDatabaseManager get managers => $AriseDatabaseManager(this);
  late final $CharacterSnapshotTableTable characterSnapshotTable =
      $CharacterSnapshotTableTable(this);
  late final $QuestsTableTable questsTable = $QuestsTableTable(this);
  late final $BossesTableTable bossesTable = $BossesTableTable(this);
  late final $DungeonsTableTable dungeonsTable = $DungeonsTableTable(this);
  late final $GateSessionsTableTable gateSessionsTable =
      $GateSessionsTableTable(this);
  late final $LocalEventQueueTableTable localEventQueueTable =
      $LocalEventQueueTableTable(this);
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  late final $AppMetaTableTable appMetaTable = $AppMetaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        characterSnapshotTable,
        questsTable,
        bossesTable,
        dungeonsTable,
        gateSessionsTable,
        localEventQueueTable,
        syncMetaTable,
        appMetaTable
      ];
}

typedef $$CharacterSnapshotTableTableCreateCompanionBuilder
    = CharacterSnapshotTableCompanion Function({
  required String userId,
  Value<String> name,
  Value<String?> titleEquipped,
  Value<int> level,
  Value<int> totalXp,
  Value<int> mana,
  Value<int> maxMana,
  Value<int> energy,
  Value<int> hp,
  Value<int> maxHp,
  Value<int> coins,
  Value<int> gems,
  Value<String> rank,
  Value<String> statsJson,
  Value<int> remainingStatPoints,
  Value<int> streak,
  Value<String> syncStatus,
  Value<int> pendingXpDelta,
  Value<DateTime?> updatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$CharacterSnapshotTableTableUpdateCompanionBuilder
    = CharacterSnapshotTableCompanion Function({
  Value<String> userId,
  Value<String> name,
  Value<String?> titleEquipped,
  Value<int> level,
  Value<int> totalXp,
  Value<int> mana,
  Value<int> maxMana,
  Value<int> energy,
  Value<int> hp,
  Value<int> maxHp,
  Value<int> coins,
  Value<int> gems,
  Value<String> rank,
  Value<String> statsJson,
  Value<int> remainingStatPoints,
  Value<int> streak,
  Value<String> syncStatus,
  Value<int> pendingXpDelta,
  Value<DateTime?> updatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<int> rowid,
});

class $$CharacterSnapshotTableTableFilterComposer
    extends Composer<_$AriseDatabase, $CharacterSnapshotTableTable> {
  $$CharacterSnapshotTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleEquipped => $composableBuilder(
      column: $table.titleEquipped, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalXp => $composableBuilder(
      column: $table.totalXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mana => $composableBuilder(
      column: $table.mana, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxMana => $composableBuilder(
      column: $table.maxMana, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hp => $composableBuilder(
      column: $table.hp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coins => $composableBuilder(
      column: $table.coins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gems => $composableBuilder(
      column: $table.gems, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rank => $composableBuilder(
      column: $table.rank, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statsJson => $composableBuilder(
      column: $table.statsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remainingStatPoints => $composableBuilder(
      column: $table.remainingStatPoints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streak => $composableBuilder(
      column: $table.streak, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pendingXpDelta => $composableBuilder(
      column: $table.pendingXpDelta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$CharacterSnapshotTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $CharacterSnapshotTableTable> {
  $$CharacterSnapshotTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleEquipped => $composableBuilder(
      column: $table.titleEquipped,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalXp => $composableBuilder(
      column: $table.totalXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mana => $composableBuilder(
      column: $table.mana, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxMana => $composableBuilder(
      column: $table.maxMana, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hp => $composableBuilder(
      column: $table.hp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coins => $composableBuilder(
      column: $table.coins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gems => $composableBuilder(
      column: $table.gems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rank => $composableBuilder(
      column: $table.rank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statsJson => $composableBuilder(
      column: $table.statsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remainingStatPoints => $composableBuilder(
      column: $table.remainingStatPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streak => $composableBuilder(
      column: $table.streak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pendingXpDelta => $composableBuilder(
      column: $table.pendingXpDelta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CharacterSnapshotTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $CharacterSnapshotTableTable> {
  $$CharacterSnapshotTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get titleEquipped => $composableBuilder(
      column: $table.titleEquipped, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get mana =>
      $composableBuilder(column: $table.mana, builder: (column) => column);

  GeneratedColumn<int> get maxMana =>
      $composableBuilder(column: $table.maxMana, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get hp =>
      $composableBuilder(column: $table.hp, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get gems =>
      $composableBuilder(column: $table.gems, builder: (column) => column);

  GeneratedColumn<String> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  GeneratedColumn<int> get remainingStatPoints => $composableBuilder(
      column: $table.remainingStatPoints, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get pendingXpDelta => $composableBuilder(
      column: $table.pendingXpDelta, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$CharacterSnapshotTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $CharacterSnapshotTableTable,
    CharacterSnapshotTableData,
    $$CharacterSnapshotTableTableFilterComposer,
    $$CharacterSnapshotTableTableOrderingComposer,
    $$CharacterSnapshotTableTableAnnotationComposer,
    $$CharacterSnapshotTableTableCreateCompanionBuilder,
    $$CharacterSnapshotTableTableUpdateCompanionBuilder,
    (
      CharacterSnapshotTableData,
      BaseReferences<_$AriseDatabase, $CharacterSnapshotTableTable,
          CharacterSnapshotTableData>
    ),
    CharacterSnapshotTableData,
    PrefetchHooks Function()> {
  $$CharacterSnapshotTableTableTableManager(
      _$AriseDatabase db, $CharacterSnapshotTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterSnapshotTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterSnapshotTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterSnapshotTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> titleEquipped = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> totalXp = const Value.absent(),
            Value<int> mana = const Value.absent(),
            Value<int> maxMana = const Value.absent(),
            Value<int> energy = const Value.absent(),
            Value<int> hp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> coins = const Value.absent(),
            Value<int> gems = const Value.absent(),
            Value<String> rank = const Value.absent(),
            Value<String> statsJson = const Value.absent(),
            Value<int> remainingStatPoints = const Value.absent(),
            Value<int> streak = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> pendingXpDelta = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CharacterSnapshotTableCompanion(
            userId: userId,
            name: name,
            titleEquipped: titleEquipped,
            level: level,
            totalXp: totalXp,
            mana: mana,
            maxMana: maxMana,
            energy: energy,
            hp: hp,
            maxHp: maxHp,
            coins: coins,
            gems: gems,
            rank: rank,
            statsJson: statsJson,
            remainingStatPoints: remainingStatPoints,
            streak: streak,
            syncStatus: syncStatus,
            pendingXpDelta: pendingXpDelta,
            updatedAt: updatedAt,
            serverUpdatedAt: serverUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String> name = const Value.absent(),
            Value<String?> titleEquipped = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> totalXp = const Value.absent(),
            Value<int> mana = const Value.absent(),
            Value<int> maxMana = const Value.absent(),
            Value<int> energy = const Value.absent(),
            Value<int> hp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> coins = const Value.absent(),
            Value<int> gems = const Value.absent(),
            Value<String> rank = const Value.absent(),
            Value<String> statsJson = const Value.absent(),
            Value<int> remainingStatPoints = const Value.absent(),
            Value<int> streak = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> pendingXpDelta = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CharacterSnapshotTableCompanion.insert(
            userId: userId,
            name: name,
            titleEquipped: titleEquipped,
            level: level,
            totalXp: totalXp,
            mana: mana,
            maxMana: maxMana,
            energy: energy,
            hp: hp,
            maxHp: maxHp,
            coins: coins,
            gems: gems,
            rank: rank,
            statsJson: statsJson,
            remainingStatPoints: remainingStatPoints,
            streak: streak,
            syncStatus: syncStatus,
            pendingXpDelta: pendingXpDelta,
            updatedAt: updatedAt,
            serverUpdatedAt: serverUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CharacterSnapshotTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AriseDatabase,
        $CharacterSnapshotTableTable,
        CharacterSnapshotTableData,
        $$CharacterSnapshotTableTableFilterComposer,
        $$CharacterSnapshotTableTableOrderingComposer,
        $$CharacterSnapshotTableTableAnnotationComposer,
        $$CharacterSnapshotTableTableCreateCompanionBuilder,
        $$CharacterSnapshotTableTableUpdateCompanionBuilder,
        (
          CharacterSnapshotTableData,
          BaseReferences<_$AriseDatabase, $CharacterSnapshotTableTable,
              CharacterSnapshotTableData>
        ),
        CharacterSnapshotTableData,
        PrefetchHooks Function()>;
typedef $$QuestsTableTableCreateCompanionBuilder = QuestsTableCompanion
    Function({
  required String id,
  required String userId,
  Value<String?> bossId,
  Value<String?> parentQuestId,
  required String title,
  Value<String> description,
  Value<String> questType,
  Value<String> priority,
  Value<String> difficulty,
  Value<DateTime?> deadlineUtc,
  Value<String?> deadlineDisplay,
  Value<int> estimatedMinutes,
  Value<int?> actualMinutes,
  Value<String> status,
  Value<String> tagsJson,
  Value<int> xpReward,
  Value<int> manaReward,
  Value<bool> isFavorite,
  Value<bool> isPinned,
  required String idempotencyKey,
  Value<String> syncStatus,
  Value<bool> isDirty,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> completedAt,
  Value<int> serverRevision,
  Value<int> rowid,
});
typedef $$QuestsTableTableUpdateCompanionBuilder = QuestsTableCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> bossId,
  Value<String?> parentQuestId,
  Value<String> title,
  Value<String> description,
  Value<String> questType,
  Value<String> priority,
  Value<String> difficulty,
  Value<DateTime?> deadlineUtc,
  Value<String?> deadlineDisplay,
  Value<int> estimatedMinutes,
  Value<int?> actualMinutes,
  Value<String> status,
  Value<String> tagsJson,
  Value<int> xpReward,
  Value<int> manaReward,
  Value<bool> isFavorite,
  Value<bool> isPinned,
  Value<String> idempotencyKey,
  Value<String> syncStatus,
  Value<bool> isDirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> completedAt,
  Value<int> serverRevision,
  Value<int> rowid,
});

class $$QuestsTableTableFilterComposer
    extends Composer<_$AriseDatabase, $QuestsTableTable> {
  $$QuestsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bossId => $composableBuilder(
      column: $table.bossId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentQuestId => $composableBuilder(
      column: $table.parentQuestId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questType => $composableBuilder(
      column: $table.questType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadlineUtc => $composableBuilder(
      column: $table.deadlineUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deadlineDisplay => $composableBuilder(
      column: $table.deadlineDisplay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualMinutes => $composableBuilder(
      column: $table.actualMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get xpReward => $composableBuilder(
      column: $table.xpReward, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get manaReward => $composableBuilder(
      column: $table.manaReward, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));
}

class $$QuestsTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $QuestsTableTable> {
  $$QuestsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bossId => $composableBuilder(
      column: $table.bossId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentQuestId => $composableBuilder(
      column: $table.parentQuestId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questType => $composableBuilder(
      column: $table.questType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadlineUtc => $composableBuilder(
      column: $table.deadlineUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deadlineDisplay => $composableBuilder(
      column: $table.deadlineDisplay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualMinutes => $composableBuilder(
      column: $table.actualMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get xpReward => $composableBuilder(
      column: $table.xpReward, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get manaReward => $composableBuilder(
      column: $table.manaReward, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$QuestsTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $QuestsTableTable> {
  $$QuestsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get bossId =>
      $composableBuilder(column: $table.bossId, builder: (column) => column);

  GeneratedColumn<String> get parentQuestId => $composableBuilder(
      column: $table.parentQuestId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get questType =>
      $composableBuilder(column: $table.questType, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineUtc => $composableBuilder(
      column: $table.deadlineUtc, builder: (column) => column);

  GeneratedColumn<String> get deadlineDisplay => $composableBuilder(
      column: $table.deadlineDisplay, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<int> get actualMinutes => $composableBuilder(
      column: $table.actualMinutes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<int> get manaReward => $composableBuilder(
      column: $table.manaReward, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);
}

class $$QuestsTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $QuestsTableTable,
    QuestsTableData,
    $$QuestsTableTableFilterComposer,
    $$QuestsTableTableOrderingComposer,
    $$QuestsTableTableAnnotationComposer,
    $$QuestsTableTableCreateCompanionBuilder,
    $$QuestsTableTableUpdateCompanionBuilder,
    (
      QuestsTableData,
      BaseReferences<_$AriseDatabase, $QuestsTableTable, QuestsTableData>
    ),
    QuestsTableData,
    PrefetchHooks Function()> {
  $$QuestsTableTableTableManager(_$AriseDatabase db, $QuestsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> bossId = const Value.absent(),
            Value<String?> parentQuestId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> questType = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<DateTime?> deadlineUtc = const Value.absent(),
            Value<String?> deadlineDisplay = const Value.absent(),
            Value<int> estimatedMinutes = const Value.absent(),
            Value<int?> actualMinutes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int> xpReward = const Value.absent(),
            Value<int> manaReward = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> serverRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestsTableCompanion(
            id: id,
            userId: userId,
            bossId: bossId,
            parentQuestId: parentQuestId,
            title: title,
            description: description,
            questType: questType,
            priority: priority,
            difficulty: difficulty,
            deadlineUtc: deadlineUtc,
            deadlineDisplay: deadlineDisplay,
            estimatedMinutes: estimatedMinutes,
            actualMinutes: actualMinutes,
            status: status,
            tagsJson: tagsJson,
            xpReward: xpReward,
            manaReward: manaReward,
            isFavorite: isFavorite,
            isPinned: isPinned,
            idempotencyKey: idempotencyKey,
            syncStatus: syncStatus,
            isDirty: isDirty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            serverRevision: serverRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> bossId = const Value.absent(),
            Value<String?> parentQuestId = const Value.absent(),
            required String title,
            Value<String> description = const Value.absent(),
            Value<String> questType = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<DateTime?> deadlineUtc = const Value.absent(),
            Value<String?> deadlineDisplay = const Value.absent(),
            Value<int> estimatedMinutes = const Value.absent(),
            Value<int?> actualMinutes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int> xpReward = const Value.absent(),
            Value<int> manaReward = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            required String idempotencyKey,
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> serverRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestsTableCompanion.insert(
            id: id,
            userId: userId,
            bossId: bossId,
            parentQuestId: parentQuestId,
            title: title,
            description: description,
            questType: questType,
            priority: priority,
            difficulty: difficulty,
            deadlineUtc: deadlineUtc,
            deadlineDisplay: deadlineDisplay,
            estimatedMinutes: estimatedMinutes,
            actualMinutes: actualMinutes,
            status: status,
            tagsJson: tagsJson,
            xpReward: xpReward,
            manaReward: manaReward,
            isFavorite: isFavorite,
            isPinned: isPinned,
            idempotencyKey: idempotencyKey,
            syncStatus: syncStatus,
            isDirty: isDirty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            serverRevision: serverRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestsTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $QuestsTableTable,
    QuestsTableData,
    $$QuestsTableTableFilterComposer,
    $$QuestsTableTableOrderingComposer,
    $$QuestsTableTableAnnotationComposer,
    $$QuestsTableTableCreateCompanionBuilder,
    $$QuestsTableTableUpdateCompanionBuilder,
    (
      QuestsTableData,
      BaseReferences<_$AriseDatabase, $QuestsTableTable, QuestsTableData>
    ),
    QuestsTableData,
    PrefetchHooks Function()>;
typedef $$BossesTableTableCreateCompanionBuilder = BossesTableCompanion
    Function({
  required String id,
  required String userId,
  Value<String?> dungeonId,
  required String title,
  Value<String?> description,
  required int hpMax,
  required int hpCurrent,
  Value<String> difficulty,
  Value<String> status,
  Value<DateTime?> deadline,
  Value<DateTime?> defeatedAt,
  Value<String> syncStatus,
  Value<bool> isDirty,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$BossesTableTableUpdateCompanionBuilder = BossesTableCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> dungeonId,
  Value<String> title,
  Value<String?> description,
  Value<int> hpMax,
  Value<int> hpCurrent,
  Value<String> difficulty,
  Value<String> status,
  Value<DateTime?> deadline,
  Value<DateTime?> defeatedAt,
  Value<String> syncStatus,
  Value<bool> isDirty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$BossesTableTableFilterComposer
    extends Composer<_$AriseDatabase, $BossesTableTable> {
  $$BossesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dungeonId => $composableBuilder(
      column: $table.dungeonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hpMax => $composableBuilder(
      column: $table.hpMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hpCurrent => $composableBuilder(
      column: $table.hpCurrent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get defeatedAt => $composableBuilder(
      column: $table.defeatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$BossesTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $BossesTableTable> {
  $$BossesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dungeonId => $composableBuilder(
      column: $table.dungeonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hpMax => $composableBuilder(
      column: $table.hpMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hpCurrent => $composableBuilder(
      column: $table.hpCurrent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get defeatedAt => $composableBuilder(
      column: $table.defeatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BossesTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $BossesTableTable> {
  $$BossesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dungeonId =>
      $composableBuilder(column: $table.dungeonId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get hpMax =>
      $composableBuilder(column: $table.hpMax, builder: (column) => column);

  GeneratedColumn<int> get hpCurrent =>
      $composableBuilder(column: $table.hpCurrent, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<DateTime> get defeatedAt => $composableBuilder(
      column: $table.defeatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BossesTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $BossesTableTable,
    BossesTableData,
    $$BossesTableTableFilterComposer,
    $$BossesTableTableOrderingComposer,
    $$BossesTableTableAnnotationComposer,
    $$BossesTableTableCreateCompanionBuilder,
    $$BossesTableTableUpdateCompanionBuilder,
    (
      BossesTableData,
      BaseReferences<_$AriseDatabase, $BossesTableTable, BossesTableData>
    ),
    BossesTableData,
    PrefetchHooks Function()> {
  $$BossesTableTableTableManager(_$AriseDatabase db, $BossesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BossesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BossesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BossesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> dungeonId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> hpMax = const Value.absent(),
            Value<int> hpCurrent = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<DateTime?> defeatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BossesTableCompanion(
            id: id,
            userId: userId,
            dungeonId: dungeonId,
            title: title,
            description: description,
            hpMax: hpMax,
            hpCurrent: hpCurrent,
            difficulty: difficulty,
            status: status,
            deadline: deadline,
            defeatedAt: defeatedAt,
            syncStatus: syncStatus,
            isDirty: isDirty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> dungeonId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required int hpMax,
            required int hpCurrent,
            Value<String> difficulty = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<DateTime?> defeatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BossesTableCompanion.insert(
            id: id,
            userId: userId,
            dungeonId: dungeonId,
            title: title,
            description: description,
            hpMax: hpMax,
            hpCurrent: hpCurrent,
            difficulty: difficulty,
            status: status,
            deadline: deadline,
            defeatedAt: defeatedAt,
            syncStatus: syncStatus,
            isDirty: isDirty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BossesTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $BossesTableTable,
    BossesTableData,
    $$BossesTableTableFilterComposer,
    $$BossesTableTableOrderingComposer,
    $$BossesTableTableAnnotationComposer,
    $$BossesTableTableCreateCompanionBuilder,
    $$BossesTableTableUpdateCompanionBuilder,
    (
      BossesTableData,
      BaseReferences<_$AriseDatabase, $BossesTableTable, BossesTableData>
    ),
    BossesTableData,
    PrefetchHooks Function()>;
typedef $$DungeonsTableTableCreateCompanionBuilder = DungeonsTableCompanion
    Function({
  required String id,
  required String userId,
  required String title,
  Value<String> status,
  Value<String> syncStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DungeonsTableTableUpdateCompanionBuilder = DungeonsTableCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String> status,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DungeonsTableTableFilterComposer
    extends Composer<_$AriseDatabase, $DungeonsTableTable> {
  $$DungeonsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DungeonsTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $DungeonsTableTable> {
  $$DungeonsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DungeonsTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $DungeonsTableTable> {
  $$DungeonsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DungeonsTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $DungeonsTableTable,
    DungeonsTableData,
    $$DungeonsTableTableFilterComposer,
    $$DungeonsTableTableOrderingComposer,
    $$DungeonsTableTableAnnotationComposer,
    $$DungeonsTableTableCreateCompanionBuilder,
    $$DungeonsTableTableUpdateCompanionBuilder,
    (
      DungeonsTableData,
      BaseReferences<_$AriseDatabase, $DungeonsTableTable, DungeonsTableData>
    ),
    DungeonsTableData,
    PrefetchHooks Function()> {
  $$DungeonsTableTableTableManager(
      _$AriseDatabase db, $DungeonsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DungeonsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DungeonsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DungeonsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DungeonsTableCompanion(
            id: id,
            userId: userId,
            title: title,
            status: status,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            Value<String> status = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DungeonsTableCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            status: status,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DungeonsTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $DungeonsTableTable,
    DungeonsTableData,
    $$DungeonsTableTableFilterComposer,
    $$DungeonsTableTableOrderingComposer,
    $$DungeonsTableTableAnnotationComposer,
    $$DungeonsTableTableCreateCompanionBuilder,
    $$DungeonsTableTableUpdateCompanionBuilder,
    (
      DungeonsTableData,
      BaseReferences<_$AriseDatabase, $DungeonsTableTable, DungeonsTableData>
    ),
    DungeonsTableData,
    PrefetchHooks Function()>;
typedef $$GateSessionsTableTableCreateCompanionBuilder
    = GateSessionsTableCompanion Function({
  required String id,
  required String userId,
  Value<String?> questId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<DateTime?> pausedAt,
  required int plannedDurationS,
  Value<int?> actualDurationS,
  Value<int> pauseCount,
  Value<int> totalPausedDurationS,
  Value<String?> exitReason,
  Value<String> status,
  Value<double?> stabilityFinal,
  Value<int?> xpAwarded,
  Value<int?> manaDelta,
  Value<String> syncStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GateSessionsTableTableUpdateCompanionBuilder
    = GateSessionsTableCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> questId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<DateTime?> pausedAt,
  Value<int> plannedDurationS,
  Value<int?> actualDurationS,
  Value<int> pauseCount,
  Value<int> totalPausedDurationS,
  Value<String?> exitReason,
  Value<String> status,
  Value<double?> stabilityFinal,
  Value<int?> xpAwarded,
  Value<int?> manaDelta,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GateSessionsTableTableFilterComposer
    extends Composer<_$AriseDatabase, $GateSessionsTableTable> {
  $$GateSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questId => $composableBuilder(
      column: $table.questId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plannedDurationS => $composableBuilder(
      column: $table.plannedDurationS,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualDurationS => $composableBuilder(
      column: $table.actualDurationS,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pauseCount => $composableBuilder(
      column: $table.pauseCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPausedDurationS => $composableBuilder(
      column: $table.totalPausedDurationS,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exitReason => $composableBuilder(
      column: $table.exitReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stabilityFinal => $composableBuilder(
      column: $table.stabilityFinal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get xpAwarded => $composableBuilder(
      column: $table.xpAwarded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get manaDelta => $composableBuilder(
      column: $table.manaDelta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GateSessionsTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $GateSessionsTableTable> {
  $$GateSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questId => $composableBuilder(
      column: $table.questId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plannedDurationS => $composableBuilder(
      column: $table.plannedDurationS,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualDurationS => $composableBuilder(
      column: $table.actualDurationS,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pauseCount => $composableBuilder(
      column: $table.pauseCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPausedDurationS => $composableBuilder(
      column: $table.totalPausedDurationS,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exitReason => $composableBuilder(
      column: $table.exitReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stabilityFinal => $composableBuilder(
      column: $table.stabilityFinal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get xpAwarded => $composableBuilder(
      column: $table.xpAwarded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get manaDelta => $composableBuilder(
      column: $table.manaDelta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GateSessionsTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $GateSessionsTableTable> {
  $$GateSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationS => $composableBuilder(
      column: $table.plannedDurationS, builder: (column) => column);

  GeneratedColumn<int> get actualDurationS => $composableBuilder(
      column: $table.actualDurationS, builder: (column) => column);

  GeneratedColumn<int> get pauseCount => $composableBuilder(
      column: $table.pauseCount, builder: (column) => column);

  GeneratedColumn<int> get totalPausedDurationS => $composableBuilder(
      column: $table.totalPausedDurationS, builder: (column) => column);

  GeneratedColumn<String> get exitReason => $composableBuilder(
      column: $table.exitReason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get stabilityFinal => $composableBuilder(
      column: $table.stabilityFinal, builder: (column) => column);

  GeneratedColumn<int> get xpAwarded =>
      $composableBuilder(column: $table.xpAwarded, builder: (column) => column);

  GeneratedColumn<int> get manaDelta =>
      $composableBuilder(column: $table.manaDelta, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GateSessionsTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $GateSessionsTableTable,
    GateSessionsTableData,
    $$GateSessionsTableTableFilterComposer,
    $$GateSessionsTableTableOrderingComposer,
    $$GateSessionsTableTableAnnotationComposer,
    $$GateSessionsTableTableCreateCompanionBuilder,
    $$GateSessionsTableTableUpdateCompanionBuilder,
    (
      GateSessionsTableData,
      BaseReferences<_$AriseDatabase, $GateSessionsTableTable,
          GateSessionsTableData>
    ),
    GateSessionsTableData,
    PrefetchHooks Function()> {
  $$GateSessionsTableTableTableManager(
      _$AriseDatabase db, $GateSessionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GateSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GateSessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GateSessionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> questId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<int> plannedDurationS = const Value.absent(),
            Value<int?> actualDurationS = const Value.absent(),
            Value<int> pauseCount = const Value.absent(),
            Value<int> totalPausedDurationS = const Value.absent(),
            Value<String?> exitReason = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> stabilityFinal = const Value.absent(),
            Value<int?> xpAwarded = const Value.absent(),
            Value<int?> manaDelta = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GateSessionsTableCompanion(
            id: id,
            userId: userId,
            questId: questId,
            startedAt: startedAt,
            endedAt: endedAt,
            pausedAt: pausedAt,
            plannedDurationS: plannedDurationS,
            actualDurationS: actualDurationS,
            pauseCount: pauseCount,
            totalPausedDurationS: totalPausedDurationS,
            exitReason: exitReason,
            status: status,
            stabilityFinal: stabilityFinal,
            xpAwarded: xpAwarded,
            manaDelta: manaDelta,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> questId = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            required int plannedDurationS,
            Value<int?> actualDurationS = const Value.absent(),
            Value<int> pauseCount = const Value.absent(),
            Value<int> totalPausedDurationS = const Value.absent(),
            Value<String?> exitReason = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> stabilityFinal = const Value.absent(),
            Value<int?> xpAwarded = const Value.absent(),
            Value<int?> manaDelta = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GateSessionsTableCompanion.insert(
            id: id,
            userId: userId,
            questId: questId,
            startedAt: startedAt,
            endedAt: endedAt,
            pausedAt: pausedAt,
            plannedDurationS: plannedDurationS,
            actualDurationS: actualDurationS,
            pauseCount: pauseCount,
            totalPausedDurationS: totalPausedDurationS,
            exitReason: exitReason,
            status: status,
            stabilityFinal: stabilityFinal,
            xpAwarded: xpAwarded,
            manaDelta: manaDelta,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GateSessionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $GateSessionsTableTable,
    GateSessionsTableData,
    $$GateSessionsTableTableFilterComposer,
    $$GateSessionsTableTableOrderingComposer,
    $$GateSessionsTableTableAnnotationComposer,
    $$GateSessionsTableTableCreateCompanionBuilder,
    $$GateSessionsTableTableUpdateCompanionBuilder,
    (
      GateSessionsTableData,
      BaseReferences<_$AriseDatabase, $GateSessionsTableTable,
          GateSessionsTableData>
    ),
    GateSessionsTableData,
    PrefetchHooks Function()>;
typedef $$LocalEventQueueTableTableCreateCompanionBuilder
    = LocalEventQueueTableCompanion Function({
  required String eventId,
  required String userId,
  required String deviceId,
  required String eventType,
  required String payloadJson,
  required DateTime occurredAtClient,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<int> version,
  Value<String?> lastError,
  Value<DateTime?> nextRetryAt,
  Value<int> rowid,
});
typedef $$LocalEventQueueTableTableUpdateCompanionBuilder
    = LocalEventQueueTableCompanion Function({
  Value<String> eventId,
  Value<String> userId,
  Value<String> deviceId,
  Value<String> eventType,
  Value<String> payloadJson,
  Value<DateTime> occurredAtClient,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<int> version,
  Value<String?> lastError,
  Value<DateTime?> nextRetryAt,
  Value<int> rowid,
});

class $$LocalEventQueueTableTableFilterComposer
    extends Composer<_$AriseDatabase, $LocalEventQueueTableTable> {
  $$LocalEventQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAtClient => $composableBuilder(
      column: $table.occurredAtClient,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));
}

class $$LocalEventQueueTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $LocalEventQueueTableTable> {
  $$LocalEventQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAtClient => $composableBuilder(
      column: $table.occurredAtClient,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalEventQueueTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $LocalEventQueueTableTable> {
  $$LocalEventQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtClient => $composableBuilder(
      column: $table.occurredAtClient, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);
}

class $$LocalEventQueueTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $LocalEventQueueTableTable,
    LocalEventQueueTableData,
    $$LocalEventQueueTableTableFilterComposer,
    $$LocalEventQueueTableTableOrderingComposer,
    $$LocalEventQueueTableTableAnnotationComposer,
    $$LocalEventQueueTableTableCreateCompanionBuilder,
    $$LocalEventQueueTableTableUpdateCompanionBuilder,
    (
      LocalEventQueueTableData,
      BaseReferences<_$AriseDatabase, $LocalEventQueueTableTable,
          LocalEventQueueTableData>
    ),
    LocalEventQueueTableData,
    PrefetchHooks Function()> {
  $$LocalEventQueueTableTableTableManager(
      _$AriseDatabase db, $LocalEventQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEventQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEventQueueTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEventQueueTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> occurredAtClient = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalEventQueueTableCompanion(
            eventId: eventId,
            userId: userId,
            deviceId: deviceId,
            eventType: eventType,
            payloadJson: payloadJson,
            occurredAtClient: occurredAtClient,
            syncStatus: syncStatus,
            retryCount: retryCount,
            version: version,
            lastError: lastError,
            nextRetryAt: nextRetryAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String userId,
            required String deviceId,
            required String eventType,
            required String payloadJson,
            required DateTime occurredAtClient,
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalEventQueueTableCompanion.insert(
            eventId: eventId,
            userId: userId,
            deviceId: deviceId,
            eventType: eventType,
            payloadJson: payloadJson,
            occurredAtClient: occurredAtClient,
            syncStatus: syncStatus,
            retryCount: retryCount,
            version: version,
            lastError: lastError,
            nextRetryAt: nextRetryAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalEventQueueTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AriseDatabase,
        $LocalEventQueueTableTable,
        LocalEventQueueTableData,
        $$LocalEventQueueTableTableFilterComposer,
        $$LocalEventQueueTableTableOrderingComposer,
        $$LocalEventQueueTableTableAnnotationComposer,
        $$LocalEventQueueTableTableCreateCompanionBuilder,
        $$LocalEventQueueTableTableUpdateCompanionBuilder,
        (
          LocalEventQueueTableData,
          BaseReferences<_$AriseDatabase, $LocalEventQueueTableTable,
              LocalEventQueueTableData>
        ),
        LocalEventQueueTableData,
        PrefetchHooks Function()>;
typedef $$SyncMetaTableTableCreateCompanionBuilder = SyncMetaTableCompanion
    Function({
  required String entityType,
  Value<DateTime?> lastSyncedAt,
  Value<int> serverRevision,
  Value<int> rowid,
});
typedef $$SyncMetaTableTableUpdateCompanionBuilder = SyncMetaTableCompanion
    Function({
  Value<String> entityType,
  Value<DateTime?> lastSyncedAt,
  Value<int> serverRevision,
  Value<int> rowid,
});

class $$SyncMetaTableTableFilterComposer
    extends Composer<_$AriseDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);
}

class $$SyncMetaTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $SyncMetaTableTable,
    SyncMetaTableData,
    $$SyncMetaTableTableFilterComposer,
    $$SyncMetaTableTableOrderingComposer,
    $$SyncMetaTableTableAnnotationComposer,
    $$SyncMetaTableTableCreateCompanionBuilder,
    $$SyncMetaTableTableUpdateCompanionBuilder,
    (
      SyncMetaTableData,
      BaseReferences<_$AriseDatabase, $SyncMetaTableTable, SyncMetaTableData>
    ),
    SyncMetaTableData,
    PrefetchHooks Function()> {
  $$SyncMetaTableTableTableManager(
      _$AriseDatabase db, $SyncMetaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> serverRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaTableCompanion(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            serverRevision: serverRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> serverRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaTableCompanion.insert(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            serverRevision: serverRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetaTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $SyncMetaTableTable,
    SyncMetaTableData,
    $$SyncMetaTableTableFilterComposer,
    $$SyncMetaTableTableOrderingComposer,
    $$SyncMetaTableTableAnnotationComposer,
    $$SyncMetaTableTableCreateCompanionBuilder,
    $$SyncMetaTableTableUpdateCompanionBuilder,
    (
      SyncMetaTableData,
      BaseReferences<_$AriseDatabase, $SyncMetaTableTable, SyncMetaTableData>
    ),
    SyncMetaTableData,
    PrefetchHooks Function()>;
typedef $$AppMetaTableTableCreateCompanionBuilder = AppMetaTableCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableTableUpdateCompanionBuilder = AppMetaTableCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableTableFilterComposer
    extends Composer<_$AriseDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableTableOrderingComposer
    extends Composer<_$AriseDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableTableAnnotationComposer
    extends Composer<_$AriseDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableTableManager extends RootTableManager<
    _$AriseDatabase,
    $AppMetaTableTable,
    AppMetaTableData,
    $$AppMetaTableTableFilterComposer,
    $$AppMetaTableTableOrderingComposer,
    $$AppMetaTableTableAnnotationComposer,
    $$AppMetaTableTableCreateCompanionBuilder,
    $$AppMetaTableTableUpdateCompanionBuilder,
    (
      AppMetaTableData,
      BaseReferences<_$AriseDatabase, $AppMetaTableTable, AppMetaTableData>
    ),
    AppMetaTableData,
    PrefetchHooks Function()> {
  $$AppMetaTableTableTableManager(_$AriseDatabase db, $AppMetaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableTableProcessedTableManager = ProcessedTableManager<
    _$AriseDatabase,
    $AppMetaTableTable,
    AppMetaTableData,
    $$AppMetaTableTableFilterComposer,
    $$AppMetaTableTableOrderingComposer,
    $$AppMetaTableTableAnnotationComposer,
    $$AppMetaTableTableCreateCompanionBuilder,
    $$AppMetaTableTableUpdateCompanionBuilder,
    (
      AppMetaTableData,
      BaseReferences<_$AriseDatabase, $AppMetaTableTable, AppMetaTableData>
    ),
    AppMetaTableData,
    PrefetchHooks Function()>;

class $AriseDatabaseManager {
  final _$AriseDatabase _db;
  $AriseDatabaseManager(this._db);
  $$CharacterSnapshotTableTableTableManager get characterSnapshotTable =>
      $$CharacterSnapshotTableTableTableManager(
          _db, _db.characterSnapshotTable);
  $$QuestsTableTableTableManager get questsTable =>
      $$QuestsTableTableTableManager(_db, _db.questsTable);
  $$BossesTableTableTableManager get bossesTable =>
      $$BossesTableTableTableManager(_db, _db.bossesTable);
  $$DungeonsTableTableTableManager get dungeonsTable =>
      $$DungeonsTableTableTableManager(_db, _db.dungeonsTable);
  $$GateSessionsTableTableTableManager get gateSessionsTable =>
      $$GateSessionsTableTableTableManager(_db, _db.gateSessionsTable);
  $$LocalEventQueueTableTableTableManager get localEventQueueTable =>
      $$LocalEventQueueTableTableTableManager(_db, _db.localEventQueueTable);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
  $$AppMetaTableTableTableManager get appMetaTable =>
      $$AppMetaTableTableTableManager(_db, _db.appMetaTable);
}
