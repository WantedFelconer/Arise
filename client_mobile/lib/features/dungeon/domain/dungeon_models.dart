import '../../boss/domain/boss_models.dart';

/// Dungeon domain models (SRS §4.12, §6.2).
class Dungeon {
  const Dungeon({
    required this.id,
    required this.userId,
    required this.title,
    this.status = 'active',
    this.bosses = const [],
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String status; // active, completed
  final List<Boss> bosses;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == 'completed';

  factory Dungeon.fromJson(Map<String, dynamic> json) {
    final rawBosses = json['bosses'] as List<dynamic>? ?? [];
    return Dungeon(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'local-user',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      bosses: rawBosses
          .map((b) => Boss.fromJson(b as Map<String, dynamic>))
          .toList(),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
