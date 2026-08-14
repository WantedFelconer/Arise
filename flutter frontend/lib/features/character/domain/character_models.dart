/// Domain models for Character & RPG State (Authoritative Server Integration).
library character_models;

class XpTransaction {
  final String id;
  final String? characterId;
  final int amount;
  final String sourceType;
  final String? sourceId;
  final String? statKey;
  final String? reason;
  final DateTime createdAt;

  const XpTransaction({
    required this.id,
    this.characterId,
    required this.amount,
    required this.sourceType,
    this.sourceId,
    this.statKey,
    this.reason,
    required this.createdAt,
  });

  factory XpTransaction.fromJson(Map<String, dynamic> json) {
    return XpTransaction(
      id: json['id'] as String? ?? '',
      characterId: json['characterId'] as String?,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      sourceType: json['sourceType'] as String? ?? 'unknown',
      sourceId: json['sourceId'] as String?,
      statKey: json['statKey'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'amount': amount,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'statKey': statKey,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ManaTransaction {
  final String id;
  final String? characterId;
  final int delta;
  final String sourceType;
  final String? sourceId;
  final String? reason;
  final DateTime createdAt;

  const ManaTransaction({
    required this.id,
    this.characterId,
    required this.delta,
    required this.sourceType,
    this.sourceId,
    this.reason,
    required this.createdAt,
  });

  factory ManaTransaction.fromJson(Map<String, dynamic> json) {
    return ManaTransaction(
      id: json['id'] as String? ?? '',
      characterId: json['characterId'] as String?,
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      sourceType: json['sourceType'] as String? ?? 'unknown',
      sourceId: json['sourceId'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'delta': delta,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
}

class CharacterTransactionHistory {
  final List<XpTransaction> xpTransactions;
  final List<ManaTransaction> manaTransactions;

  const CharacterTransactionHistory({
    this.xpTransactions = const [],
    this.manaTransactions = const [],
  });

  factory CharacterTransactionHistory.fromJson(Map<String, dynamic> json) {
    final xpList = (json['xpTransactions'] as List<dynamic>? ?? [])
        .map((x) => XpTransaction.fromJson(x as Map<String, dynamic>))
        .toList();
    final manaList = (json['manaTransactions'] as List<dynamic>? ?? [])
        .map((m) => ManaTransaction.fromJson(m as Map<String, dynamic>))
        .toList();

    return CharacterTransactionHistory(
      xpTransactions: xpList,
      manaTransactions: manaList,
    );
  }

  static const empty = CharacterTransactionHistory();
}

class XpAggregates {
  final int today;
  final int thisWeek;
  final int thisMonth;
  final int lifetime;

  const XpAggregates({
    this.today = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
    this.lifetime = 0,
  });

  factory XpAggregates.fromJson(Map<String, dynamic> json) {
    return XpAggregates(
      today: (json['today'] as num?)?.toInt() ?? 0,
      thisWeek: (json['thisWeek'] as num?)?.toInt() ?? 0,
      thisMonth: (json['thisMonth'] as num?)?.toInt() ?? 0,
      lifetime: (json['lifetime'] as num?)?.toInt() ?? 0,
    );
  }

  static const zero = XpAggregates();
}

class CharacterTitle {
  final String id;
  final String name;
  final String description;
  final bool unlocked;

  const CharacterTitle({
    required this.id,
    required this.name,
    required this.description,
    this.unlocked = true,
  });
}
