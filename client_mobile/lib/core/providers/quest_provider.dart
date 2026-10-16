import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/quest.dart';
import '../database/arise_database.dart';
import '../repositories/quest_repository.dart';
import '../sync/offline_command_queue.dart';
import '../sync/sync_engine.dart';
import '../../features/quests/infrastructure/local_quest_repository.dart';
import '../../features/quests/infrastructure/quest_remote_data_source.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final db = ref.watch(ariseDatabaseProvider);
  return LocalQuestRepository(db);
});

class QuestState {
  final List<Quest> quests;
  final String activeTab; // 'DAILY', 'MAIN', 'SIDE', 'RECURRING', 'ALL'
  final bool isAddModalOpen;
  final bool isLoading;
  final String? error;
  final Quest? editingQuest;

  const QuestState({
    this.quests = const [],
    this.activeTab = 'DAILY',
    this.isAddModalOpen = false,
    this.isLoading = false,
    this.error,
    this.editingQuest,
  });

  QuestState copyWith({
    List<Quest>? quests,
    String? activeTab,
    bool? isAddModalOpen,
    bool? isLoading,
    String? error,
    Quest? editingQuest,
    bool clearEditingQuest = false,
  }) {
    return QuestState(
      quests: quests ?? this.quests,
      activeTab: activeTab ?? this.activeTab,
      isAddModalOpen: isAddModalOpen ?? this.isAddModalOpen,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      editingQuest: clearEditingQuest ? null : (editingQuest ?? this.editingQuest),
    );
  }
}

class QuestNotifier extends StateNotifier<QuestState> {
  QuestNotifier(
    this._repository,
    this._commandQueue, {
    QuestRemoteDataSource? remoteDataSource,
    SyncEngine? syncEngine,
  })  : _remoteDataSource = remoteDataSource,
        _syncEngine = syncEngine,
        super(const QuestState()) {
    _init();
  }

  final QuestRepository _repository;
  final PersistentCommandQueue _commandQueue;
  final QuestRemoteDataSource? _remoteDataSource;
  final SyncEngine? _syncEngine;

  StreamSubscription<List<Quest>>? _questsSubscription;
  static const _uuid = Uuid();
  static const String _kLocalUserId = 'local-user';

  void _init() {
    if (_repository is LocalQuestRepository) {
      final localRepo = _repository as LocalQuestRepository;
      _questsSubscription = localRepo.watchQuests().listen((list) {
        if (mounted) {
          state = state.copyWith(quests: list, isLoading: false);
        }
      });
    }
    loadQuests();
  }

  @override
  void dispose() {
    _questsSubscription?.cancel();
    super.dispose();
  }

  /// Initial load from local database, followed by background remote sync if online.
  Future<void> loadQuests([String? userId]) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: state.quests.isEmpty, error: null);
    try {
      final list = await _repository.fetchQuests();
      if (!mounted) return;
      if (list.isNotEmpty || state.quests.isEmpty) {
        state = state.copyWith(quests: list, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }

      // Attempt remote refresh in background if online
      final remote = _remoteDataSource;
      if (remote != null && _repository is LocalQuestRepository && _syncEngine?.isOnline != false) {
        try {
          final serverQuests = await remote.fetchQuests();
          if (!mounted) return;
          final localRepo = _repository as LocalQuestRepository;
          await localRepo.reconcileServerQuests(serverQuests, userId ?? _kLocalUserId);
        } catch (_) {
          // Network errors during background remote sync are handled gracefully offline
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setAddModalOpen(bool open, {Quest? questToEdit}) {
    state = state.copyWith(
      isAddModalOpen: open,
      editingQuest: questToEdit,
      clearEditingQuest: !open && questToEdit == null,
    );
  }

  /// Toggle / Complete quest with offline-first write & double-tap protection.
  Future<void> toggleQuest(String questId) async {
    final existingIndex = state.quests.indexWhere((q) => q.id == questId);
    if (existingIndex == -1) return;
    final currentQuest = state.quests[existingIndex];

    // Double tap protection: if already completed, do nothing
    if (currentQuest.done) return;

    const newDone = true;
    final now = DateTime.now();

    // 1. Immediate optimistic local update
    final updatedList = List<Quest>.from(state.quests);
    updatedList[existingIndex] = currentQuest.copyWith(
      done: newDone,
      progress: 100,
      syncStatus: 'pending',
      status: 'completed',
    );
    state = state.copyWith(quests: updatedList);

    // 2. Persist to local database
    if (_repository is LocalQuestRepository) {
      final localRepo = _repository as LocalQuestRepository;
      await localRepo.completeQuestLocal(questId);
    } else {
      await _repository.toggleQuestCompletion(int.tryParse(questId) ?? 0);
    }

    // 3. Enqueue domain command (never client-submitted XP)
    await _commandQueue.enqueue(
      commandType: 'COMPLETE_QUEST',
      userId: currentQuest.userId ?? _kLocalUserId,
      idempotencyKey: _uuid.v4(),
      payload: {
        'questId': questId,
        'completedAt': now.toIso8601String(),
      },
    );

    // 4. Trigger sync
    _syncEngine?.triggerSync();
  }

  /// Create a new quest — offline-first write.
  Future<void> addQuest(Quest quest) async {
    final questId = quest.id.isEmpty ? _uuid.v4() : quest.id;
    final idempotencyKey =
        quest.idempotencyKey.isEmpty ? _uuid.v4() : quest.idempotencyKey;

    final questWithIds = quest.copyWith(
      id: questId,
      idempotencyKey: idempotencyKey,
      syncStatus: 'pending',
      status: 'active',
    );

    // 1. Optimistic state update
    state = state.copyWith(
      quests: [questWithIds, ...state.quests],
      isAddModalOpen: false,
      clearEditingQuest: true,
    );

    // 2. Persist to local DB
    await _repository.saveQuest(questWithIds);

    // 3. Enqueue CREATE_QUEST command
    await _commandQueue.enqueue(
      commandType: 'CREATE_QUEST',
      userId: questWithIds.userId ?? _kLocalUserId,
      idempotencyKey: idempotencyKey,
      payload: {
        'id': questId,
        'questId': questId,
        'title': questWithIds.title,
        'description': questWithIds.description,
        'questType': questWithIds.type.name,
        'priority': 'medium',
        'difficulty': _rankToDifficulty(questWithIds.rank),
        'estimatedMinutes': questWithIds.estimatedMinutes,
        'deadline': questWithIds.deadlineDt?.toIso8601String(),
      },
    );

    // 4. Trigger sync
    _syncEngine?.triggerSync();
  }

  /// Update an existing quest.
  Future<void> updateQuest(Quest quest) async {
    final questWithStatus = quest.copyWith(
      syncStatus: 'pending',
    );

    // 1. Optimistic update
    final updatedList = state.quests.map((q) => q.id == quest.id ? questWithStatus : q).toList();
    state = state.copyWith(
      quests: updatedList,
      isAddModalOpen: false,
      clearEditingQuest: true,
    );

    // 2. Persist to local DB
    await _repository.saveQuest(questWithStatus);

    // 3. Enqueue UPDATE_QUEST command
    await _commandQueue.enqueue(
      commandType: 'UPDATE_QUEST',
      userId: quest.userId ?? _kLocalUserId,
      idempotencyKey: _uuid.v4(),
      payload: {
        'questId': quest.id,
        'title': quest.title,
        'description': quest.description,
        'questType': quest.type.name,
        'difficulty': _rankToDifficulty(quest.rank),
        'estimatedMinutes': quest.estimatedMinutes,
        'deadline': quest.deadlineDt?.toIso8601String(),
        'isFavorite': quest.isFavorite,
        'isPinned': quest.isPinned,
      },
    );

    // 4. Trigger sync
    _syncEngine?.triggerSync();
  }

  /// Archive a quest.
  Future<void> archiveQuest(String questId) async {
    final existing = state.quests.firstWhere((q) => q.id == questId, orElse: () => state.quests.first);
    state = state.copyWith(
      quests: state.quests.where((q) => q.id != questId).toList(),
    );

    if (_repository is LocalQuestRepository) {
      await (_repository as LocalQuestRepository).archiveQuestLocal(questId);
    }

    await _commandQueue.enqueue(
      commandType: 'ARCHIVE_QUEST',
      userId: existing.userId ?? _kLocalUserId,
      idempotencyKey: _uuid.v4(),
      payload: {'questId': questId},
    );

    _syncEngine?.triggerSync();
  }

  /// Trash / delete a quest.
  Future<void> trashQuest(String questId) async {
    final existing = state.quests.firstWhere((q) => q.id == questId, orElse: () => state.quests.first);
    state = state.copyWith(
      quests: state.quests.where((q) => q.id != questId).toList(),
    );

    if (_repository is LocalQuestRepository) {
      await (_repository as LocalQuestRepository).trashQuestLocal(questId);
    }

    await _commandQueue.enqueue(
      commandType: 'TRASH_QUEST',
      userId: existing.userId ?? _kLocalUserId,
      idempotencyKey: _uuid.v4(),
      payload: {'questId': questId},
    );

    _syncEngine?.triggerSync();
  }

  /// Restore a quest.
  Future<void> restoreQuest(String questId) async {
    final existing = state.quests.firstWhere((q) => q.id == questId, orElse: () => state.quests.first);
    if (_repository is LocalQuestRepository) {
      await (_repository as LocalQuestRepository).restoreQuestLocal(questId);
    }

    await _commandQueue.enqueue(
      commandType: 'RESTORE_QUEST',
      userId: existing.userId ?? _kLocalUserId,
      idempotencyKey: _uuid.v4(),
      payload: {'questId': questId},
    );

    _syncEngine?.triggerSync();
  }

  static String _rankToDifficulty(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return 'epic';
      case 'A':
        return 'hard';
      case 'B':
        return 'medium';
      case 'C':
      case 'D':
        return 'easy';
      default:
        return 'trivial';
    }
  }
}

final questProvider =
    StateNotifierProvider<QuestNotifier, QuestState>((ref) {
  final repo = ref.watch(questRepositoryProvider);
  final queue = ref.watch(commandQueueProvider);
  QuestRemoteDataSource? remoteSource;
  try {
    remoteSource = ref.watch(questRemoteDataSourceProvider);
  } catch (_) {}

  SyncEngine? syncEng;
  try {
    syncEng = ref.watch(syncEngineProvider);
  } catch (_) {}

  return QuestNotifier(
    repo,
    queue,
    remoteDataSource: remoteSource,
    syncEngine: syncEng,
  );
});

final questNotifierProvider = questProvider;

final filteredQuestsProvider = Provider<List<Quest>>((ref) {
  final questState = ref.watch(questProvider);
  if (questState.activeTab == 'ALL') {
    return questState.quests;
  }
  return questState.quests
      .where((q) => q.type.name.toUpperCase() == questState.activeTab)
      .toList();
});
