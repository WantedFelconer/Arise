import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/glow_fab.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/arise_sliding_window.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/reward_chip.dart';
import '../../../../core/providers/quest_provider.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/network/network_status.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../../shared/models/quest.dart';

class QuestListScreen extends ConsumerStatefulWidget {
  const QuestListScreen({super.key});

  @override
  ConsumerState<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends ConsumerState<QuestListScreen> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredQuestsProvider);
    final questState = ref.watch(questProvider);
    final activeTab = questState.activeTab;
    final isAddModalOpen = questState.isAddModalOpen;
    final isLoading = questState.isLoading;
    final editingQuest = questState.editingQuest;
    final questNotifier = ref.read(questProvider.notifier);
    final syncState = ref.watch(syncStateProvider).valueOrNull ?? const SyncState();
    final networkStatus = ref.watch(networkStatusProvider).valueOrNull ?? NetworkStatus.online;
    final isOffline = networkStatus == NetworkStatus.offline;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AriseLayoutInsets.topHeaderInset(context)),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ QUEST REGISTRY ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('QUEST LOG', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (syncState.pendingCount > 0 || isOffline)
                        _SyncBadge(
                          isOffline: isOffline,
                          pendingCount: syncState.pendingCount,
                          isSyncing: syncState.status == SyncEngineStatus.syncing,
                          onRetry: () => ref.read(syncEngineProvider).triggerSync(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Daily Reset / Sync Status Banner
            _TopInfoBanner(
              isOffline: isOffline,
              syncState: syncState,
              onTriggerSync: () => ref.read(syncEngineProvider).triggerSync(),
            ),
            const SizedBox(height: 12),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassCard(
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: ['DAILY', 'MAIN', 'SIDE', 'ALL'].map((tab) {
                    final isActive = activeTab == tab;
                    return Expanded(
                      child: PressableCard(
                        onTap: () => questNotifier.setActiveTab(tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(bottom: BorderSide(color: isActive ? AppColors.manaCyan : Colors.transparent, width: 2)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tab,
                            style: AppTypography.orbitron(fontSize: 9, fontWeight: FontWeight.w700, color: isActive ? AppColors.manaCyan : AppColors.textDisabled),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Main List / States
            Expanded(
              child: isLoading && filtered.isEmpty
                  ? const _LoadingQuestsView()
                  : filtered.isEmpty
                      ? _EmptyQuestsView(
                          activeTab: activeTab,
                          onAddQuest: () => questNotifier.setAddModalOpen(true),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, AriseLayoutInsets.bottomContentInset(context, extra: 56.0)),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final q = filtered[idx];
                            final isDone = q.done;
                            final isMain = q.type == QuestType.main;
                            final rankColor = AppColors.getRankColor(q.rank);

                            if (isMain) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: OrnatePanel(
                                  cornerSize: 24,
                                  noCrest: q.rank != 'S',
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            RankBadge(rank: q.rank, size: RankBadgeSize.lg),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: rankColor.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                                                        ),
                                                        child: Text(
                                                          '${q.rank}-RANK QUEST',
                                                          style: AppTypography.monoStat(fontSize: 8, color: rankColor),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      if (q.syncStatus == 'pending')
                                                        const _PendingSyncChip(),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(q.title, style: AppTypography.orbitron(fontSize: 15, color: AppColors.textPrimary)),
                                                  Text(q.description, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _QuestCompletionCheckbox(
                                              isDone: isDone,
                                              onTap: isDone ? null : () => questNotifier.toggleQuest(q.id),
                                            ),
                                          ],
                                        ),
                                        const DiamondDivider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('PROGRESS', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                                            Text('${q.progress}%', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xCC0A1A3A),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: q.progress / 100.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [rankColor.withValues(alpha: 0.6), rankColor]),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            RewardChip(exp: q.exp, gold: q.gold),
                                            Text('⏱ ${q.deadline}', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final isExpanded = _expandedId == q.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: PressableCard(
                                onTap: () => setState(() => _expandedId = isExpanded ? null : q.id),
                                pressedScale: 0.98,
                                child: _PulsingDangerCard(
                                  isOverdue: q.overdue && !isDone,
                                  child: GlassCard(
                                    borderColor: q.overdue && !isDone ? AppColors.dangerRed : rankColor.withValues(alpha: 0.25),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            RankBadge(rank: q.rank, size: RankBadgeSize.sm),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          q.title,
                                                          style: AppTypography.orbitron(fontSize: 12, color: isDone ? AppColors.textDisabled : AppColors.textPrimary),
                                                        ),
                                                      ),
                                                      if (q.syncStatus == 'pending') ...[
                                                        const SizedBox(width: 4),
                                                        const _PendingSyncChip(),
                                                      ],
                                                      if (q.overdue && !isDone)
                                                        Text('PENALTY IMMINENT', style: AppTypography.monoStat(fontSize: 8, color: AppColors.dangerRed)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      RewardChip(exp: q.exp),
                                                      const SizedBox(width: 8),
                                                      Text('⏱ ${q.deadline}', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _QuestCompletionCheckbox(
                                              isDone: isDone,
                                              onTap: isDone ? null : () => questNotifier.toggleQuest(q.id),
                                            ),
                                          ],
                                        ),
                                        if (isExpanded) ...[
                                          const DiamondDivider(),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              q.description.isNotEmpty ? q.description : 'System directive assignment.',
                                              style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              _ActionButton(
                                                label: 'EDIT',
                                                color: AppColors.manaCyan,
                                                onTap: () => questNotifier.setAddModalOpen(true, questToEdit: q),
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                label: 'ARCHIVE',
                                                color: AppColors.textSecondary,
                                                onTap: () => questNotifier.archiveQuest(q.id),
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                label: 'TRASH',
                                                color: AppColors.dangerRed,
                                                onTap: () => questNotifier.trashQuest(q.id),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),

        // Add Quest FAB
        Positioned(
          right: 16,
          bottom: AriseLayoutInsets.fabBottomInset(context),
          child: GlowFab(
            onPressed: () => questNotifier.setAddModalOpen(true),
          ),
        ),

        // Add / Edit Quest Modal Overlay
        if (isAddModalOpen)
          Positioned.fill(
            child: _AddQuestModal(
              existingQuest: editingQuest,
              onClose: () => questNotifier.setAddModalOpen(false),
              onSave: (q) {
                if (editingQuest != null) {
                  questNotifier.updateQuest(q);
                } else {
                  questNotifier.addQuest(q);
                }
              },
            ),
          ),
      ],
    );
  }
}

class _QuestCompletionCheckbox extends StatelessWidget {
  final bool isDone;
  final VoidCallback? onTap;

  const _QuestCompletionCheckbox({required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? AppColors.buffGreen.withValues(alpha: 0.25) : Colors.transparent,
          border: Border.all(
            color: isDone ? AppColors.buffGreen : AppColors.manaCyan.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: AppColors.buffGreen.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isDone
            ? const Text('✓', style: TextStyle(fontSize: 12, color: AppColors.buffGreen, fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }
}

class _PendingSyncChip extends StatelessWidget {
  const _PendingSyncChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.expFrom.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.expFrom.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.expFrom,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'PENDING SYNC',
            style: AppTypography.monoStat(fontSize: 7, color: AppColors.expFrom),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isOffline;
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback onRetry;

  const _SyncBadge({
    required this.isOffline,
    required this.pendingCount,
    required this.isSyncing,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOffline
              ? AppColors.dangerRed.withValues(alpha: 0.12)
              : AppColors.manaCyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOffline
                ? AppColors.dangerRed.withValues(alpha: 0.4)
                : AppColors.manaCyan.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSyncing ? '⟳' : isOffline ? '⚡' : '☁',
              style: TextStyle(
                fontSize: 10,
                color: isOffline ? AppColors.dangerRed : AppColors.manaCyan,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isSyncing
                  ? 'SYNCING...'
                  : isOffline
                      ? 'OFFLINE ($pendingCount)'
                      : '$pendingCount QUEUED',
              style: AppTypography.monoStat(
                fontSize: 8,
                color: isOffline ? AppColors.dangerRed : AppColors.manaCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopInfoBanner extends StatelessWidget {
  final bool isOffline;
  final SyncState syncState;
  final VoidCallback onTriggerSync;

  const _TopInfoBanner({
    required this.isOffline,
    required this.syncState,
    required this.onTriggerSync,
  });

  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OFFLINE-FIRST CORE ENGAGED', style: AppTypography.orbitron(fontSize: 8, color: AppColors.dangerRed)),
                Text('Mutations secured in local SQLite · Auto-sync on reconnect', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
            Text('OFFLINE', style: AppTypography.monoStat(fontSize: 11, color: AppColors.dangerRed)),
          ],
        ),
      );
    }

    if (syncState.status == SyncEngineStatus.syncing) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.manaCyan.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SYSTEM UPLINK SYNCHRONIZING...', style: AppTypography.orbitron(fontSize: 8, color: AppColors.manaCyan)),
                Text('Transmitting queued domain commands to server ledger', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.manaCyan),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.manaCyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DAILY QUEST RESET', style: AppTypography.orbitron(fontSize: 8, color: AppColors.textSecondary)),
              Text('SYSTEM READY — DISPATCH DIRECTIVES', style: AppTypography.monoStat(fontSize: 8, color: AppColors.manaCyan)),
            ],
          ),
          Text('23:14:07', style: AppTypography.monoStat(fontSize: 14, color: AppColors.manaCyan)),
        ],
      ),
    );
  }
}

class _EmptyQuestsView extends StatelessWidget {
  final String activeTab;
  final VoidCallback onAddQuest;

  const _EmptyQuestsView({required this.activeTab, required this.onAddQuest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Text('◈', style: TextStyle(fontSize: 24, color: AppColors.manaCyan)),
            ),
            const SizedBox(height: 16),
            Text(
              '[ NO $activeTab DIRECTIVES ACTIVE ]',
              style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Initialize a new objective to commence your hunter progression.',
              textAlign: TextAlign.center,
              style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            PressableCard(
              onTap: onAddQuest,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.manaCyan.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '+ INITIALIZE DIRECTIVE',
                  style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingQuestsView extends StatelessWidget {
  const _LoadingQuestsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 16),
          Text(
            '[ QUERYING LOCAL MATRIX... ]',
            style: AppTypography.monoStat(fontSize: 10, color: AppColors.manaCyan),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTypography.monoStat(fontSize: 8, color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PulsingDangerCard extends StatefulWidget {
  final bool isOverdue;
  final Widget child;

  const _PulsingDangerCard({required this.isOverdue, required this.child});

  @override
  State<_PulsingDangerCard> createState() => _PulsingDangerCardState();
}

class _PulsingDangerCardState extends State<_PulsingDangerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isOverdue) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingDangerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverdue && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOverdue && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOverdue) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.5);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(255, 46, 77, opacity),
                blurRadius: 16,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _AddQuestModal extends StatefulWidget {
  final Quest? existingQuest;
  final VoidCallback onClose;
  final ValueChanged<Quest> onSave;

  const _AddQuestModal({
    this.existingQuest,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends State<_AddQuestModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _expController;
  late TextEditingController _minsController;
  late QuestType _type;
  late String _rank;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingQuest;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descController = TextEditingController(text: existing?.description ?? '');
    _expController = TextEditingController(text: existing != null ? '${existing.exp}' : '100');
    _minsController = TextEditingController(text: existing != null ? '${existing.estimatedMinutes}' : '30');
    _type = existing?.type ?? QuestType.daily;
    _rank = existing?.rank ?? 'B';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _expController.dispose();
    _minsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;
    final exp = int.tryParse(_expController.text) ?? 100;
    final mins = int.tryParse(_minsController.text) ?? 30;

    final updated = (widget.existingQuest ?? const Quest(
      rank: 'B',
      type: QuestType.daily,
      title: '',
      description: '',
      exp: 100,
      deadline: 'TODAY · 23:59',
    )).copyWith(
      title: _titleController.text.trim().toUpperCase(),
      description: _descController.text.trim().isEmpty ? 'System quest assignment.' : _descController.text.trim(),
      type: _type,
      rank: _rank,
      exp: exp,
      estimatedMinutes: mins,
      deadline: 'TODAY · 23:59',
      deadlineDt: DateTime.now().add(const Duration(hours: 12)),
    );

    widget.onSave(updated);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingQuest != null;

    return AriseSlidingWindow(
      onClose: widget.onClose,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? '[ MODIFY OBJECTIVE ]' : '[ NEW OBJECTIVE ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                    Text(isEditing ? 'UPDATE QUEST' : 'REGISTER QUEST', style: AppTypography.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                ArisePressable(
                  onTap: widget.onClose,
                  child: Text('✕', style: AppTypography.monoStat(fontSize: 18, color: AppColors.textDisabled)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title input
            Text('TITLE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _titleController,
                style: AppTypography.orbitron(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'E.G. 100 PUSH-UPS',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Description input
            Text('DESCRIPTION / SYSTEM INSTRUCTION', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _descController,
                style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Enter specific parameters...',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Type Selection
            Text('TYPE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 6),
            Row(
              children: QuestType.values.take(4).map((t) {
                final isSelected = _type == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: PressableCard(
                      onTap: () => setState(() => _type = t),
                      pressedScale: 0.96,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.manaCyan.withValues(alpha: 0.15) : AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? AppColors.manaCyan : AppColors.glassBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(t.name.toUpperCase(), style: AppTypography.monoStat(fontSize: 9, color: isSelected ? AppColors.manaCyan : AppColors.textDisabled)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Rank Selection
            Text('RANK DESIGNATION', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 6),
            Row(
              children: ['E', 'D', 'C', 'B', 'A', 'S'].map((r) {
                final isSelected = _rank == r;
                final color = AppColors.getRankColor(r);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: PressableCard(
                      onTap: () => setState(() => _rank = r),
                      pressedScale: 0.94,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? color : AppColors.glassBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(r, style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? color : AppColors.textDisabled)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // EXP & Duration Inputs
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXP REWARD', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                      const SizedBox(height: 4),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: _expController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.monoStat(fontSize: 12, color: AppColors.manaCyan),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EST. MINUTES', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                      const SizedBox(height: 4),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: _minsController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.monoStat(fontSize: 12, color: AppColors.expFrom),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Submit Button
            PressableCard(
              onTap: _titleController.text.trim().isEmpty ? null : _handleSave,
              pressedScale: 0.96,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _titleController.text.trim().isNotEmpty
                      ? const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)])
                      : null,
                  color: _titleController.text.trim().isEmpty ? AppColors.manaCyan.withValues(alpha: 0.06) : null,
                  border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                  boxShadow: _titleController.text.trim().isNotEmpty
                      ? const [BoxShadow(color: Color(0x4D3EE6F5), blurRadius: 20)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  isEditing ? '[ UPDATE DIRECTIVE ]' : '[ REGISTER DIRECTIVE ]',
                  style: AppTypography.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _titleController.text.trim().isNotEmpty ? const Color(0xFF030712) : AppColors.textDisabled,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
