import '../../shared/models/quest.dart';

abstract class QuestRepository {
  Future<List<Quest>> fetchQuests();
  Future<void> saveQuest(Quest quest);
  Future<void> toggleQuestCompletion(int id);
}

class InMemoryQuestRepository implements QuestRepository {
  final List<Quest> _quests = [
    const Quest(id: 1, rank: 'B', type: QuestType.daily, title: '100 PUSH-UPS', description: 'Complete 100 consecutive push-ups. No breaks. No excuses.', exp: 80, gold: 20, deadline: '23:14:07', progress: 60),
    const Quest(id: 2, rank: 'B', type: QuestType.daily, title: '100 SIT-UPS', description: 'Core training mandatory by System decree.', exp: 80, gold: 20, done: true, deadline: '23:14:07', progress: 100),
    const Quest(id: 3, rank: 'B', type: QuestType.daily, title: '100 SQUATS', description: 'Lower body reinforcement. Essential for dungeon mobility.', exp: 80, gold: 20, deadline: '23:14:07', progress: 0),
    const Quest(id: 4, rank: 'A', type: QuestType.daily, title: '10KM RUN', description: 'Complete the daily distance requirement. Weather is not an excuse.', exp: 120, gold: 40, overdue: true, deadline: 'OVERDUE', progress: 40),
    const Quest(id: 5, rank: 'S', type: QuestType.main, title: 'SHIP THE APP', description: 'Launch the production build. The System awaits your greatest work.', exp: 2000, gold: 500, deadline: '14D', progress: 35),
    const Quest(id: 6, rank: 'A', type: QuestType.main, title: 'RUN A MARATHON', description: 'Complete 42.195km. Prove the body knows no limits.', exp: 1500, gold: 300, deadline: '60D', progress: 20),
    const Quest(id: 7, rank: 'B', type: QuestType.main, title: 'READ 12 BOOKS', description: 'Annual mind cultivation quota. Current: 3/12.', exp: 800, gold: 150, deadline: '180D', progress: 25),
    const Quest(id: 8, rank: 'D', type: QuestType.side, title: 'CALL A PARENT', description: 'Maintain bonds outside the dungeon. The System rewards perspective.', exp: 30, gold: 10, deadline: 'TONIGHT', progress: 0),
    const Quest(id: 9, rank: 'C', type: QuestType.side, title: 'CLEAN WORKSPACE', description: 'A cluttered environment is a cluttered mind.', exp: 50, gold: 15, done: true, deadline: 'DONE', progress: 100),
    const Quest(id: 10, rank: 'E', type: QuestType.side, title: 'DRINK 2L WATER', description: 'Baseline vitals maintenance. Non-negotiable.', exp: 20, gold: 5, deadline: '23:14:07', progress: 75),
  ];

  @override
  Future<List<Quest>> fetchQuests() async {
    return List.unmodifiable(_quests);
  }

  @override
  Future<void> saveQuest(Quest quest) async {
    _quests.add(quest);
  }

  @override
  Future<void> toggleQuestCompletion(int id) async {
    final idx = _quests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final current = _quests[idx];
      _quests[idx] = current.copyWith(
        done: !current.done,
        progress: current.done ? 0 : 100,
      );
    }
  }
}
