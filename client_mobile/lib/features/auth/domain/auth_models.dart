/// Represents JWT RS256 token pair issued by the backend.
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

/// Represents the authenticated user profile.
class AuthUser {
  final String id;
  final String email;
  final String difficultyMode;

  const AuthUser({
    required this.id,
    required this.email,
    required this.difficultyMode,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      difficultyMode: json['difficultyMode'] as String? ?? 'casual',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'difficultyMode': difficultyMode,
      };
}

/// Represents the character snapshot returned by auth & character endpoints.
class AuthCharacter {
  final String id;
  final String? userId;
  final int level;
  final int totalXp;
  final int currentMana;
  final int maxMana;
  final String rank;
  final int coins;
  final int streak;
  final String? title;
  final Map<String, dynamic> stats;

  const AuthCharacter({
    required this.id,
    this.userId,
    this.level = 1,
    this.totalXp = 0,
    this.currentMana = 100,
    this.maxMana = 100,
    this.rank = 'E',
    this.coins = 0,
    this.streak = 0,
    this.title,
    this.stats = const {},
  });

  factory AuthCharacter.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parsedStats = {};
    if (json['stats'] is Map) {
      parsedStats = Map<String, dynamic>.from(json['stats'] as Map);
    }

    return AuthCharacter(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentMana: (json['currentMana'] as num?)?.toInt() ?? (json['mana'] as num?)?.toInt() ?? 100,
      maxMana: (json['maxMana'] as num?)?.toInt() ?? 100,
      rank: json['rank'] as String? ?? 'E',
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      title: json['activeTitleId'] as String? ?? json['titleEquipped'] as String? ?? json['title'] as String?,
      stats: parsedStats,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'level': level,
        'totalXp': totalXp,
        'currentMana': currentMana,
        'maxMana': maxMana,
        'rank': rank,
        'coins': coins,
        'streak': streak,
        'title': title,
        'stats': stats,
      };
}

/// Represents the complete response from /api/v1/auth/signup and /api/v1/auth/login.
class AuthResponseData {
  final AuthUser user;
  final AuthCharacter? character;
  final AuthTokens tokens;

  const AuthResponseData({
    required this.user,
    this.character,
    required this.tokens,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthResponseData(
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
      character: data['character'] != null
          ? AuthCharacter.fromJson(data['character'] as Map<String, dynamic>)
          : null,
      tokens: AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>? ?? {}),
    );
  }
}
