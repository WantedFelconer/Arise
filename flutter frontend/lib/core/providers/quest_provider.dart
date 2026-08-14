import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/quest.dart';
import '../repositories/quest_repository.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return InMemoryQuestRepository();
});

class QuestState {
  final List<Quest> quests;
  final String activeTab; // 'DAILY', 'MAIN', 'SIDE', 'ALL'
  final bool isAddModalOpen;

  const QuestState({
    this.quests = const [],
    this.activeTab = 'DAILY',
    this.isAddModalOpen = false,
  });

  QuestState copyWith({
    List<Quest>? quests,
    String? activeTab,
    bool? isAddModalOpen,
  }) {
    return QuestState(
      quests: quests ?? this.quests,
      activeTab: activeTab ?? this.activeTab,
      isAddModalOpen: isAddModalOpen ?? this.isAddModalOpen,
    );
  }
}

class QuestNotifier extends StateNotifier<QuestState> {
  final QuestRepository _repository;

  QuestNotifier(this._repository) : super(const QuestState()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    final list = await _repository.fetchQuests();
    state = state.copyWith(quests: list);
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setAddModalOpen(bool open) {
    state = state.copyWith(isAddModalOpen: open);
  }

  Future<void> toggleQuest(int id) async {
    await _repository.toggleQuestCompletion(id);
    final updatedList = state.quests.map((q) {
      if (q.id == id) {
        final newDone = !q.done;
        return q.copyWith(
          done: newDone,
          progress: newDone ? 100 : 0,
        );
      }
      return q;
    }).toList();
    state = state.copyWith(quests: updatedList);
  }

  Future<void> addQuest(Quest quest) async {
    await _repository.saveQuest(quest);
    state = state.copyWith(
      quests: [...state.quests, quest],
      isAddModalOpen: false,
    );
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, QuestState>((ref) {
  final repo = ref.watch(questRepositoryProvider);
  return QuestNotifier(repo);
});

final filteredQuestsProvider = Provider<List<Quest>>((ref) {
  final questState = ref.watch(questProvider);
  if (questState.activeTab == 'ALL') {
    return questState.quests;
  }
  return questState.quests
      .where((q) => q.type.name.toUpperCase() == questState.activeTab)
      .toList();
});
