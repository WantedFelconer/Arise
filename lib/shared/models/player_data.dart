class PlayerData {
  final String name;
  final String title;
  final int level;
  final String rank;
  final int hp;
  final int maxHp;
  final int mp;
  final int maxMp;
  final int exp;
  final int maxExp;
  final int gold;
  final int streak;
  final int str;
  final int agi;
  final int vit;
  final int intStat;
  final int per;
  final int remainingPoints;

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
    required this.streak,
    required this.str,
    required this.agi,
    required this.vit,
    required this.intStat,
    required this.per,
    required this.remainingPoints,
  });

  static const defaultPlayer = PlayerData(
    name: 'HUNTER',
    title: 'THE AWAKENED',
    level: 14,
    rank: 'B',
    hp: 4200,
    maxHp: 5000,
    mp: 391,
    maxMp: 500,
    exp: 7340,
    maxExp: 10000,
    gold: 1240,
    streak: 14,
    str: 53,
    agi: 38,
    vit: 30,
    intStat: 30,
    per: 32,
    remainingPoints: 3,
  );

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
    int? streak,
    int? str,
    int? agi,
    int? vit,
    int? intStat,
    int? per,
    int? remainingPoints,
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
      streak: streak ?? this.streak,
      str: str ?? this.str,
      agi: agi ?? this.agi,
      vit: vit ?? this.vit,
      intStat: intStat ?? this.intStat,
      per: per ?? this.per,
      remainingPoints: remainingPoints ?? this.remainingPoints,
    );
  }
}
