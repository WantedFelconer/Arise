/// Domain model for Screen Time Insights and Mana Modifiers (§6.10).
class ScreenTimeInsights {
  final int totalMinutes;
  final int productiveMinutes;
  final int unproductiveMinutes;
  final int neutralMinutes;
  final int netManaDelta;
  final List<AppScreenTimeDrain> appBreakdown;

  const ScreenTimeInsights({
    this.totalMinutes = 0,
    this.productiveMinutes = 0,
    this.unproductiveMinutes = 0,
    this.neutralMinutes = 0,
    this.netManaDelta = 0,
    this.appBreakdown = const [],
  });

  factory ScreenTimeInsights.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final apps = (raw['appBreakdown'] as List<dynamic>?)
            ?.map((a) => AppScreenTimeDrain.fromJson(a as Map<String, dynamic>))
            .toList() ??
        (raw['apps'] as List<dynamic>?)
            ?.map((a) => AppScreenTimeDrain.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return ScreenTimeInsights(
      totalMinutes: (raw['totalMinutes'] as num?)?.toInt() ?? 0,
      productiveMinutes: (raw['productiveMinutes'] as num?)?.toInt() ?? 0,
      unproductiveMinutes: (raw['unproductiveMinutes'] as num?)?.toInt() ?? 0,
      neutralMinutes: (raw['neutralMinutes'] as num?)?.toInt() ?? 0,
      netManaDelta: (raw['netManaDelta'] as num?)?.toInt() ?? (raw['manaDeltaNet'] as num?)?.toInt() ?? 0,
      appBreakdown: apps,
    );
  }
}

class AppScreenTimeDrain {
  final String packageName;
  final String name;
  final int durationMinutes;
  final int limitMinutes;
  final String category; // 'productive' | 'unproductive' | 'neutral'
  final String icon;
  final int manaDrain;

  const AppScreenTimeDrain({
    required this.packageName,
    required this.name,
    this.durationMinutes = 0,
    this.limitMinutes = 30,
    this.category = 'unproductive',
    this.icon = '◈',
    this.manaDrain = 0,
  });

  bool get isOverLimit => durationMinutes > limitMinutes;

  factory AppScreenTimeDrain.fromJson(Map<String, dynamic> json) {
    return AppScreenTimeDrain(
      packageName: json['packageName'] as String? ?? json['name'] as String? ?? '',
      name: json['name'] as String? ?? json['packageName'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? (json['drain'] as num?)?.toInt() ?? 0,
      limitMinutes: (json['limitMinutes'] as num?)?.toInt() ?? (json['limit'] as num?)?.toInt() ?? 30,
      category: json['category'] as String? ?? 'unproductive',
      icon: json['icon'] as String? ?? '◈',
      manaDrain: (json['manaDrain'] as num?)?.toInt() ?? 0,
    );
  }
}
