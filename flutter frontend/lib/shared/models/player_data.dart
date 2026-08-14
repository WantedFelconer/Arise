/// Domain model for the user's RPG character (client projection).
///
/// Fields marked [backend-authoritative] MUST NOT be computed client-side.
/// They are set only via server response reconciliation (SRS §4.28, FR-VALID-1).
///
/// syncStatus values:
///   'local'   — created locally, never synced
///   'pending' — has pending mutations awaiting server ack
///   'verified'— last known state confirmed by server
///   'failed'  — last sync attempt failed
class PlayerData {
  final String name;
  final String title;

  // [backend-authoritative] Level computed by XP Engine server-side.
  final int level;

  // [backend-authoritative] Rank computed server-side.
  final String rank;

  final int hp;
  final int maxHp;
  final int mp;
  final int maxMp;

  // Current XP displayed — may be 'pending' (optimistic) or 'verified'.
  final int exp;

  // [backend-authoritative] XP threshold for next level.
  final int maxExp;

  final int gold;
  final int gems;

  // [backend-authoritative] Streak computed by server.
  final int streak;

  final int str;
  final int agi;
  final int vit;
  final int intStat;
  final int per;
  final int remainingPoints;

  // ---- Sprint A1 additions: backend integration fields ----

  /// Backend UUID for this user's character. Null until first successful auth.
  final String? id;

  /// Active equipped title ID on backend
  final String? activeTitleId;

  /// Authenticated user's email. Null until first successful auth.
  final String? email;

  /// User's selected difficulty mode: 'casual' | 'normal' | 'hardcore'.
  final String? difficultyMode;

  /// User's circadian profile: 'early_bird' | 'night_owl' | 'custom'.
  final String? chronotype;

  /// Sync state of this record.
  /// 'local' | 'pending' | 'verified' | 'failed'
  final String syncStatus;

  /// Whether the current exp/level values are optimistic pending values
  /// (true) or server-confirmed (false). UI may indicate pending state subtly.
  final bool isProgressionPending;

  const PlayerData({
    required this.name,
    required this.title,
    required this.level,
    required this.rank,
    required this.hp,
    required this.maxHp,
    required this.mp,
    required this.maxMp,
    required this.exp,
    required this.maxExp,
    required this.gold,
    this.gems = 0,
    required this.streak,
    required this.str,
    required this.agi,
    required this.vit,
    required this.intStat,
    required this.per,
    required this.remainingPoints,
    this.id,
    this.activeTitleId,
    this.email,
    this.difficultyMode,
    this.chronotype,
    this.syncStatus = 'local',
    this.isProgressionPending = false,
  });

  /// Default placeholder used before any real data is loaded.
  /// All backend-authoritative fields start at sane minimums.
  /// syncStatus='local' signals no server data has been received yet.
  static const defaultPlayer = PlayerData(
    name: 'HUNTER',
    title: 'THE AWAKENED',
    level: 1,
    rank: 'E',
    hp: 100,
    maxHp: 100,
    mp: 100,
    maxMp: 100,
    exp: 0,
    maxExp: 1000,
    gold: 0,
    gems: 0,
    streak: 0,
    str: 10,
    agi: 10,
    vit: 10,
    intStat: 10,
    per: 10,
    remainingPoints: 0,
    syncStatus: 'local',
    isProgressionPending: false,
  );

  /// Empty state — used when no local character snapshot exists.
  static const empty = PlayerData(
    name: '',
    title: '',
    level: 1,
    rank: 'E',
    hp: 100,
    maxHp: 100,
    mp: 100,
    maxMp: 100,
    exp: 0,
    maxExp: 1000,
    gold: 0,
    gems: 0,
    streak: 0,
    str: 10,
    agi: 10,
    vit: 10,
    intStat: 10,
    per: 10,
    remainingPoints: 0,
    syncStatus: 'local',
    isProgressionPending: false,
  );

  double get manaRatio => maxMp > 0 ? (mp / maxMp).clamp(0.0, 1.0) : 1.0;
  double get expRatio => maxExp > 0 ? (exp / maxExp).clamp(0.0, 1.0) : 0.0;
  bool get isVerified => syncStatus == 'verified';
  bool get isPending => syncStatus == 'pending' || isProgressionPending;
  bool get isOffline => syncStatus == 'local' || syncStatus == 'failed';

  PlayerData copyWith({
    String? name,
    String? title,
    int? level,
    String? rank,
    int? hp,
    int? maxHp,
    int? mp,
    int? maxMp,
    int? exp,
    int? maxExp,
    int? gold,
    int? gems,
    int? streak,
    int? str,
    int? agi,
    int? vit,
    int? intStat,
    int? per,
    int? remainingPoints,
    String? id,
    String? activeTitleId,
    String? email,
    String? difficultyMode,
    String? chronotype,
    String? syncStatus,
    bool? isProgressionPending,
  }) {
    return PlayerData(
      name: name ?? this.name,
      title: title ?? this.title,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      mp: mp ?? this.mp,
      maxMp: maxMp ?? this.maxMp,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      str: str ?? this.str,
      agi: agi ?? this.agi,
      vit: vit ?? this.vit,
      intStat: intStat ?? this.intStat,
      per: per ?? this.per,
      remainingPoints: remainingPoints ?? this.remainingPoints,
      id: id ?? this.id,
      activeTitleId: activeTitleId ?? this.activeTitleId,
      email: email ?? this.email,
      difficultyMode: difficultyMode ?? this.difficultyMode,
      chronotype: chronotype ?? this.chronotype,
      syncStatus: syncStatus ?? this.syncStatus,
      isProgressionPending:
          isProgressionPending ?? this.isProgressionPending,
    );
  }
}
