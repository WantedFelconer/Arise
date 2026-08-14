import '../../shared/models/quest.dart';

/// Abstract quest repository interface — the DI seam between
/// presentation and infrastructure.
///
/// All implementations (local, remote, in-memory test double) must satisfy
/// this contract. Do NOT import repositories directly from the UI layer;
/// depend on this interface via Riverpod.
abstract class QuestRepository {
  Future<List<Quest>> fetchQuests();
  Future<void> saveQuest(Quest quest);

  /// Toggle completion by the quest's string ID.
  /// The int-based overload is kept for test-double compatibility only.
  Future<void> toggleQuestCompletion(int id);
}

// ---------------------------------------------------------------------------
// In-memory implementation — retained as a test double.
// Use in tests via ProviderContainer overrides.
// DO NOT use in production; data is lost on app restart.
// ---------------------------------------------------------------------------

class InMemoryQuestRepository implements QuestRepository {
  final List<Quest> _quests = [];

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
    final idx = _quests.indexWhere((q) => q.id == id.toString());
    if (idx != -1) {
      final current = _quests[idx];
      _quests[idx] = current.copyWith(
        done: !current.done,
        progress: current.done ? 0 : 100,
      );
    }
  }
}
