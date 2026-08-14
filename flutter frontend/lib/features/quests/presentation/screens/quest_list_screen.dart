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
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../../shared/models/quest.dart';

class QuestListScreen extends ConsumerStatefulWidget {
  const QuestListScreen({super.key});

  @override
  ConsumerState<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends ConsumerState<QuestListScreen> {
  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredQuestsProvider);
    final activeTab = ref.watch(questProvider.select((s) => s.activeTab));
    final isAddModalOpen = ref.watch(questProvider.select((s) => s.isAddModalOpen));
    final questNotifier = ref.read(questProvider.notifier);

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
                  Text('QUEST LOG', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Daily Reset Banner
            Container(
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
                      Text('⚠ 1 OVERDUE — PENALTY PENDING', style: AppTypography.monoStat(fontSize: 9, color: AppColors.dangerRed)),
                    ],
                  ),
                  Text('23:14:07', style: AppTypography.monoStat(fontSize: 16, color: AppColors.manaCyan)),
                ],
              ),
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

            // List
            Expanded(
              child: ListView.builder(
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
                                        const SizedBox(height: 4),
                                        Text(q.title, style: AppTypography.orbitron(fontSize: 15, color: AppColors.textPrimary)),
                                        Text(q.description, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
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
                                  GestureDetector(
                                    onTap: () => questNotifier.toggleQuest(q.id),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDone ? AppColors.buffGreen.withValues(alpha: 0.2) : Colors.transparent,
                                        border: Border.all(color: isDone ? AppColors.buffGreen : AppColors.manaCyan.withValues(alpha: 0.4), width: 2),
                                      ),
                                      alignment: Alignment.center,
                                      child: isDone ? const Text('✓', style: TextStyle(fontSize: 12, color: AppColors.buffGreen, fontWeight: FontWeight.bold)) : null,
                                    ),
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const DiamondDivider(),
                                Text(
                                  q.description,
                                  style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
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

        // Add Quest FAB Positioned ABOVE bottom navbar
        Positioned(
          right: 16,
          bottom: AriseLayoutInsets.fabBottomInset(context),
          child: GlowFab(
            onPressed: () => questNotifier.setAddModalOpen(true),
          ),
        ),

        // Add Quest Sheet Modal Overlay
        if (isAddModalOpen)
          Positioned.fill(
            child: _AddQuestModal(
              onClose: () => questNotifier.setAddModalOpen(false),
              onSave: questNotifier.addQuest,
            ),
          ),
      ],
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
  final VoidCallback onClose;
  final ValueChanged<Quest> onSave;

  const _AddQuestModal({required this.onClose, required this.onSave});

  @override
  State<_AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends State<_AddQuestModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _expController = TextEditingController(text: '100');
  final _goldController = TextEditingController(text: '25');
  QuestType _type = QuestType.daily;
  String _rank = 'B';
  final String _deadline = 'TODAY · 23:59';

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;
    final newQ = Quest(
      id: DateTime.now().millisecondsSinceEpoch,
      rank: _rank,
      type: _type,
      title: _titleController.text.trim().toUpperCase(),
      description: _descController.text.trim().isEmpty ? 'System quest assignment.' : _descController.text.trim(),
      exp: int.tryParse(_expController.text) ?? 100,
      gold: int.tryParse(_goldController.text) ?? 25,
      deadline: _deadline,
    );
    widget.onSave(newQ);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('[ NEW OBJECTIVE ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                    Text('REGISTER QUEST', style: AppTypography.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
              children: QuestType.values.map((t) {
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

            // EXP & Gold Inputs
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
                      Text('GOLD REWARD', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                      const SizedBox(height: 4),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: _goldController,
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
            const SizedBox(height: 12),

            // Preview Panel
            Text('QUEST SYSTEM PREVIEW', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 4),
            _PulsingDangerCard(
              isOverdue: false,
              child: GlassCard(
                borderColor: AppColors.getRankColor(_rank).withValues(alpha: 0.3),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    RankBadge(rank: _rank, size: RankBadgeSize.md),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.trim().isEmpty ? '[ UNNAMED OBJECTIVE ]' : _titleController.text.trim().toUpperCase(),
                            style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          Text(
                            '${_type.name.toUpperCase()} · +${_expController.text} EXP · ⬡${_goldController.text}G',
                            style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                  '[ REGISTER QUEST ]',
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
