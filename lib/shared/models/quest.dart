enum QuestType { daily, main, side }

class Quest {
  final int id;
  final String rank;
  final QuestType type;
  final String title;
  final String description;
  final int exp;
  final int gold;
  final bool overdue;
  final bool done;
  final String deadline;
  final int progress;

  const Quest({
    required this.id,
    required this.rank,
    required this.type,
    required this.title,
    required this.description,
    required this.exp,
    this.gold = 0,
    this.overdue = false,
    this.done = false,
    required this.deadline,
    this.progress = 0,
  });

  Quest copyWith({
    bool? done,
    int? progress,
    bool? overdue,
  }) {
    return Quest(
      id: id,
      rank: rank,
      type: type,
      title: title,
      description: description,
      exp: exp,
      gold: gold,
      overdue: overdue ?? this.overdue,
      done: done ?? this.done,
      deadline: deadline,
      progress: progress ?? this.progress,
    );
  }
}
