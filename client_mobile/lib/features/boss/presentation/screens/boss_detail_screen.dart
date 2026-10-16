import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/reward_chip.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/providers/quest_provider.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../providers/boss_provider.dart';

class BossDetailScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onFocusMode;

  const BossDetailScreen({
    super.key,
    required this.onBack,
    required this.onFocusMode,
  });

  @override
  ConsumerState<BossDetailScreen> createState() => _BossDetailScreenState();
}

class _BossDetailScreenState extends ConsumerState<BossDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final bossState = ref.watch(bossNotifierProvider);
    final questState = ref.watch(questNotifierProvider);

    if (bossState.isLoading && bossState.activeBoss == null) {
      return Scaffold(
        backgroundColor: AppColors.voidEdge,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.rankA),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING BOSS ENCOUNTER...',
                style: AppTypography.monoStat(
                  fontSize: 12,
                  color: AppColors.rankA,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final boss = bossState.activeBoss;

    if (boss == null) {
      return Scaffold(
        backgroundColor: AppColors.voidEdge,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AriseBackButton(onPressed: widget.onBack),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      const Text('⚔', style: TextStyle(fontSize: 48, color: AppColors.textDisabled)),
                      const SizedBox(height: 12),
                      Text(
                        'NO ACTIVE BOSS ENCOUNTER',
                        style: AppTypography.orbitron(fontSize: 16, color: AppColors.textDisabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a project boss in your quests to unlock boss battles.',
                        textAlign: TextAlign.center,
                        style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    // Check defeat condition
    final isDefeated = boss.isDefeated || bossState.isDefeatedModalVisible;

    if (isDefeated) {
      final rewards = bossState.defeatRewards;
      final rewardExp = (rewards?['xp'] as num?)?.toInt() ?? 2000;
      final rewardGold = (rewards?['coins'] as num?)?.toInt() ?? 500;

      return Scaffold(
        backgroundColor: AppColors.voidEdge,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.expFrom.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.expFrom, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.expFrom, blurRadius: 48)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('💀', style: TextStyle(fontSize: 44)),
                ),
                const SizedBox(height: 16),
                Text(
                  '[ BOSS DEFEATED ]',
                  style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom, letterSpacing: 0.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'PROJECT CONQUERED',
                  style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.expFrom),
                ),
                const SizedBox(height: 8),
                Text(
                  '${boss.title} has been eradicated. The System acknowledges your victory.',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                OrnatePanel(
                  cornerSize: 24,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('[ REWARDS DISTRIBUTED ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        RewardChip(exp: rewardExp, gold: rewardGold),
                        const DiamondDivider(),
                        ...[
                          'AUTHORITATIVE XP & COINS DELIVERED',
                          'STATUS UPDATED TO DEFEATED',
                          'ACHIEVEMENTS EVALUATED & UNLOCKED',
                        ].map((r) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Text('> $r', style: AppTypography.monoStat(fontSize: 11, color: AppColors.terminalGreen)),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PressableCard(
                  onTap: () {
                    ref.read(bossNotifierProvider.notifier).hideDefeatModal();
                    widget.onBack();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.expFrom,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x66FFD24C), blurRadius: 20)],
                    ),
                    alignment: Alignment.center,
                    child: Text('CONTINUE →', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Dynamic Attack Log from completed quests linked to this boss
    final linkedCompletedQuests = questState.quests
        .where((q) => q.bossId == boss.id && q.done)
        .toList();

    final hpFraction = boss.hpPercent;
    final hpRemainingPct = (hpFraction * 100).round();

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                AriseLayoutInsets.bottomOverlayInset(context, extra: 72.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AriseBackButton(onPressed: widget.onBack),
                      Row(
                        children: [
                          if (boss.syncStatus == 'pending') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warningAmber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.warningAmber, width: 0.5),
                              ),
                              child: Text('PENDING SYNC', style: AppTypography.monoStat(fontSize: 8, color: AppColors.warningAmber)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text('[ BOSS ENCOUNTER ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.rankA)),
                        ],
                      ),
                      RankBadge(rank: boss.rank, size: RankBadgeSize.sm),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Boss Identity Card
                  OrnatePanel(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.rankA.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.rankA, width: 2),
                            boxShadow: const [BoxShadow(color: AppColors.rankA, blurRadius: 24)],
                          ),
                          alignment: Alignment.center,
                          child: const Text('⚔', style: TextStyle(fontSize: 36, color: AppColors.rankA)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          boss.title,
                          style: AppTypography.orbitron(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${boss.rank}-RANK BOSS · ${boss.difficulty.toUpperCase()}',
                          style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary),
                        ),
                        if (boss.description != null && boss.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            boss.description!,
                            style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),

                        // HP Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('HP', style: AppTypography.orbitron(fontSize: 16, color: AppColors.hpFrom)),
                            Text(
                              '${boss.hpCurrent} / ${boss.hpMax}',
                              style: AppTypography.monoStat(fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xCC000000),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.hpFrom.withValues(alpha: 0.35)),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: hpFraction,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppColors.hpFrom, AppColors.rankA]),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // Segment ticks
                            Positioned.fill(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (i) => Container(width: 1, color: Colors.black.withValues(alpha: 0.6))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0 HP', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled)),
                            Text('$hpRemainingPct% REMAINING', style: AppTypography.monoStat(fontSize: 8, color: AppColors.hpFrom)),
                            Text('${boss.hpMax} MAX', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled)),
                          ],
                        ),
                        const DiamondDivider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const RewardChip(exp: 2000, gold: 500),
                            if (boss.deadline != null)
                              Text(
                                '⏱ DEADLINE: ${boss.deadline!.toLocal().toString().substring(0, 10)}',
                                style: const TextStyle(color: AppColors.dangerRed, fontSize: 10),
                              )
                            else
                              Text('⏱ NO EXPIRATION', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attack Log
                  const SectionHeader(title: 'ATTACK LOG (COMPLETED QUESTS)'),
                  if (linkedCompletedQuests.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No strikes landed yet. Complete quests linked to this boss to deal damage.',
                          style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textDisabled),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...linkedCompletedQuests.map((quest) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              RankBadge(rank: quest.rank, size: RankBadgeSize.sm),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(quest.title, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textPrimary)),
                                    Text('Completed • ${quest.exp} XP awarded', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                                  ],
                                ),
                              ),
                              Text(
                                '-${quest.exp * 2} HP',
                                style: AppTypography.monoStat(fontSize: 12, color: AppColors.hpFrom, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Attack CTA
            Positioned(
              left: 16,
              right: 16,
              bottom: AriseLayoutInsets.bottomOverlayInset(context),
              child: PressableCard(
                onTap: widget.onFocusMode,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.rankA,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x80FF9B3E), blurRadius: 24)],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '⚔ ENTER FOCUS GATE TO DEAL DAMAGE',
                    style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
