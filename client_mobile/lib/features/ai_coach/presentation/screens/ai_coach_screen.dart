import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/decrypt_text.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/uplink_chip.dart';
import '../../application/ai_coach_notifier.dart';
import '../../domain/ai_plan.dart';

class AICoachScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const AICoachScreen({super.key, required this.onBack});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const actionChips = [
    '[ PLAN MY WEEK ]',
    '[ DEPLOY QUESTS ]',
    '[ DAILY BRIEFING ]',
    '[ WEEKLY REVIEW ]',
    '[ SYSTEM NUDGES ]',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiCoachNotifierProvider.notifier).sendMessage(text.trim());
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showEditPlanDialog(AiGeneratedPlan plan) {
    final titleController = TextEditingController(text: plan.goal);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.manaCyan),
        ),
        title: Text(
          'EDIT TACTICAL PLAN',
          style: AppTypography.orbitron(fontSize: 14, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GOAL DIRECTIVE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextField(
                controller: titleController,
                style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: AppTypography.monoStat(fontSize: 11, color: AppColors.textDisabled)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.manaCyan),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(aiCoachNotifierProvider.notifier).editPlan(plan.id, {
                'goal': titleController.text.trim(),
              });
            },
            child: Text('APPLY EDIT', style: AppTypography.orbitron(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRegenerateDialog(AiGeneratedPlan plan) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.manaCyan),
        ),
        title: Text(
          'REGENERATE PLAN',
          style: AppTypography.orbitron(fontSize: 14, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TACTICAL FEEDBACK / ADJUSTMENTS', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextField(
                controller: feedbackController,
                maxLines: 3,
                style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'E.g., Increase difficulty, focus more on coding...',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: AppTypography.monoStat(fontSize: 11, color: AppColors.textDisabled)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.manaCyan),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(aiCoachNotifierProvider.notifier).regeneratePlan(
                plan.id,
                feedback: feedbackController.text.trim(),
              );
            },
            child: Text('REGENERATE', style: AppTypography.orbitron(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiCoachNotifierProvider);
    final quota = aiState.quota;
    final plan = aiState.activePlan;

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AriseBackButton(onPressed: widget.onBack),
                  Column(
                    children: [
                      Text('[ SYSTEM AI — NEURAL LINK ]', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                      Text('AI COACH & PLANNER', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  Row(
                    children: [
                      if (quota != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: quota.remaining > 5
                                ? AppColors.manaCyan.withValues(alpha: 0.15)
                                : AppColors.dangerRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: quota.remaining > 5 ? AppColors.manaCyan : AppColors.dangerRed,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${quota.remaining}/${quota.dailyLimit}',
                            style: AppTypography.monoStat(
                              fontSize: 9,
                              color: quota.remaining > 5 ? AppColors.manaCyan : AppColors.dangerRed,
                            ),
                          ),
                        ),
                      UplinkChip(stable: !aiState.isOffline),
                    ],
                  ),
                ],
              ),
            ),

            // Offline or Quota Banner
            if (aiState.isOffline)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 14, color: AppColors.dangerRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'NEURAL UPLINK OFFLINE — LIVE CONNECTION REQUIRED',
                        style: AppTypography.monoStat(fontSize: 8, color: AppColors.dangerRed),
                      ),
                    ),
                  ],
                ),
              ),

            if (aiState.isQuotaExceeded)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rankA.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rankA.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_empty, size: 14, color: AppColors.rankA),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DAILY AI QUOTA REACHED — RESETS AT UTC MIDNIGHT',
                        style: AppTypography.monoStat(fontSize: 8, color: AppColors.rankA),
                      ),
                    ),
                  ],
                ),
              ),

            // Orb Avatar
            Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (aiState.isQuotaExceeded
                          ? AppColors.rankA
                          : aiState.isOffline
                              ? AppColors.dangerRed
                              : AppColors.manaCyan)
                      .withValues(alpha: 0.2),
                  border: Border.all(
                    color: aiState.isQuotaExceeded
                        ? AppColors.rankA
                        : aiState.isOffline
                            ? AppColors.dangerRed
                            : AppColors.manaCyan,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: aiState.isQuotaExceeded
                          ? AppColors.rankA
                          : aiState.isOffline
                              ? AppColors.dangerRed
                              : AppColors.manaCyan,
                      blurRadius: 20,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('◈', style: TextStyle(fontSize: 22, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              aiState.isThinking
                  ? '[ NEURAL SYNTHESIS IN PROGRESS... ]'
                  : aiState.isOffline
                      ? '[ UPLINK DISCONNECTED ]'
                      : aiState.isQuotaExceeded
                          ? '[ QUOTA EXHAUSTED ]'
                          : '[ SYSTEM ONLINE ]',
              style: AppTypography.monoStat(
                fontSize: 9,
                color: aiState.isOffline
                    ? AppColors.dangerRed
                    : aiState.isQuotaExceeded
                        ? AppColors.rankA
                        : AppColors.manaCyan,
              ),
            ),
            const SizedBox(height: 8),

            // Chat Scroll
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: aiState.messages.length + (plan != null && plan.isPendingApproval ? 1 : 0),
                itemBuilder: (context, idx) {
                  if (idx < aiState.messages.length) {
                    final msg = aiState.messages[idx];
                    final isAi = msg.isAssistant;
                    final isSys = msg.role == 'system';

                    if (isSys) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.glassPanel,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.textDisabled.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              msg.content,
                              textAlign: TextAlign.center,
                              style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          if (isAi)
                            Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.manaCyan.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: const Text('◈', style: TextStyle(fontSize: 11, color: AppColors.manaCyan)),
                            ),
                          Flexible(
                            child: GlassCard(
                              borderColor: isAi
                                  ? AppColors.manaCyan.withValues(alpha: 0.25)
                                  : AppColors.terminalGreen.withValues(alpha: 0.25),
                              padding: const EdgeInsets.all(12),
                              child: isAi
                                  ? DecryptText(
                                      text: msg.content,
                                      style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary),
                                    )
                                  : Text(
                                      msg.content,
                                      style: AppTypography.rajdhani(fontSize: 13, color: AppColors.terminalGreen),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tactical Briefing Plan Card (Rule 10: Explicit User Approval Gate)
                  if (plan == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: OrnatePanel(
                      cornerSize: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('[ TACTICAL BRIEF — STAGED PLAN ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.expFrom.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.expFrom, width: 1),
                                ),
                                child: Text('+${plan.estimatedXp} TOTAL XP', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(plan.goal.toUpperCase(), style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('ESTIMATED DURATION: ${plan.durationDays} DAYS · ${plan.quests.length} OBJECTIVES', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),

                          // Staged Quest Rows
                          ...plan.quests.map((q) => _StagedQuestRow(quest: q)),

                          const DiamondDivider(),

                          // Approval Action Bar
                          Row(
                            children: [
                              // Discard
                              Expanded(
                                flex: 1,
                                child: PressableCard(
                                  onTap: () => ref.read(aiCoachNotifierProvider.notifier).rejectPlan(plan.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.4)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('DISCARD', style: AppTypography.orbitron(fontSize: 8, color: AppColors.dangerRed)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Edit
                              Expanded(
                                flex: 1,
                                child: PressableCard(
                                  onTap: () => _showEditPlanDialog(plan),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('EDIT', style: AppTypography.orbitron(fontSize: 8, color: AppColors.manaCyan)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Regenerate
                              Expanded(
                                flex: 1,
                                child: PressableCard(
                                  onTap: () => _showRegenerateDialog(plan),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.rankB.withValues(alpha: 0.4)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('RETRY', style: AppTypography.orbitron(fontSize: 8, color: AppColors.rankB)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Accept & Deploy (Rule 10: Commit Gate)
                              Expanded(
                                flex: 2,
                                child: PressableCard(
                                  onTap: () => ref.read(aiCoachNotifierProvider.notifier).approvePlan(plan.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 14)],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'ACCEPT & DEPLOY',
                                      style: AppTypography.orbitron(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Chips
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: actionChips.length,
                itemBuilder: (context, idx) {
                  final chip = actionChips[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: PressableCard(
                      onTap: () => _sendMessage(chip.replaceAll(RegExp(r'[\[\]]'), '').trim()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                        ),
                        child: Text(chip, style: AppTypography.monoStat(fontSize: 8, color: AppColors.manaCyan)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Input Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 6 + MediaQuery.of(context).padding.bottom),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !aiState.isThinking,
                        style: AppTypography.monoStat(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: aiState.isThinking
                              ? '> Processing...'
                              : aiState.isOffline
                                  ? '> Uplink offline...'
                                  : '> Enter tactical directive...',
                          hintStyle: const TextStyle(color: AppColors.textDisabled),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    ArisePressable(
                      onTap: aiState.isThinking ? null : () => _sendMessage(_controller.text),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_upward,
                          color: aiState.isThinking ? AppColors.textDisabled : AppColors.manaCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StagedQuestRow extends StatelessWidget {
  final AiPlanQuest quest;

  const _StagedQuestRow({required this.quest});

  @override
  Widget build(BuildContext context) {
    Color rankColor = AppColors.rankB;
    if (quest.rank == 'S') rankColor = AppColors.expFrom;
    if (quest.rank == 'A') rankColor = AppColors.rankA;
    if (quest.rank == 'D') rankColor = AppColors.rankD;
    if (quest.rank == 'E') rankColor = AppColors.rankE;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        borderColor: rankColor.withValues(alpha: 0.2),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColor.withValues(alpha: 0.15),
                border: Border.all(color: rankColor),
              ),
              alignment: Alignment.center,
              child: Text(
                quest.rank,
                style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: rankColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title, style: AppTypography.orbitron(fontSize: 10, color: AppColors.textPrimary)),
                  if (quest.description.isNotEmpty)
                    Text(quest.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.rajdhani(fontSize: 10, color: AppColors.textSecondary)),
                  if (quest.subquests.isNotEmpty)
                    Text('⤷ ${quest.subquests.length} sub-tasks', style: AppTypography.monoStat(fontSize: 8, color: AppColors.manaCyan)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('+${quest.xpReward} XP', style: AppTypography.monoStat(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                Text('${quest.targetDurationMinutes}M', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
