import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/radar_background.dart';
import '../../../../core/design_system/components/system_progress_bar.dart';
import '../../../../core/providers/player_provider.dart';
import '../../../../core/providers/quest_provider.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../../shared/models/quest.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onEnterFocus;
  final ValueChanged<String> onNavigate;

  const HomeScreen({
    super.key,
    required this.onEnterFocus,
    required this.onNavigate,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const logLines = [
    {'type': 'exp', 'text': '[+120 EXP] Quest Cleared: Morning Run', 'time': '08:32'},
    {'type': 'gold', 'text': '[+50 GOLD] Daily Login Bonus', 'time': '07:00'},
    {'type': 'penalty', 'text': '[−30 EXP] Missed: Evening Meditation', 'time': 'YESTERDAY'},
    {'type': 'exp', 'text': '[+200 EXP] Quest Cleared: Cold Shower Protocol', 'time': 'YESTERDAY'},
    {'type': 'level', 'text': '[LEVEL UP] Reached Level 14', 'time': '2 DAYS AGO'},
  ];

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider.select((s) => s.quests));
    final questNotifier = ref.read(questProvider.notifier);

    final todayQuests = quests.take(5).toList();
    final doneCount = todayQuests.where((q) => q.done).length;
    final totalCount = todayQuests.length;

    final now = DateTime.now();
    final dateStr = DateFormat('EEE, MMM d').format(now).toUpperCase();

    final manaPct = player.maxMp > 0 ? (player.mp / player.maxMp * 100).clamp(0, 100).round() : 100;
    final manaStatusText = manaPct > 50
        ? 'Reserves stable · Normal consumption'
        : (manaPct > 20 ? 'Reserves low · Exercise moderation' : '⚠ Critical depletion imminent');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, AriseLayoutInsets.topHeaderInset(context), 16, AriseLayoutInsets.bottomContentInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            '[ SYSTEM ONLINE — $dateStr ]',
            style: AppTypography.monoStat(fontSize: 11, color: AppColors.textDisabled),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'WELCOME BACK,\n',
                  style: AppTypography.orbitron(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: 'HUNTER ${player.name.toUpperCase()}',
                  style: AppTypography.orbitron(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.manaCyan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${player.title} · Rank ${player.rank}',
            style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // EXP Bar Card
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL ${player.level}',
                      style: AppTypography.orbitron(fontSize: 11, color: AppColors.expFrom),
                    ),
                    Text(
                      '${player.exp} / ${player.maxExp} EXP',
                      style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SystemProgressBar(
                  value: player.exp.toDouble(),
                  max: player.maxExp.toDouble(),
                  variant: ProgressBarVariant.exp,
                  height: 8,
                ),
                const SizedBox(height: 6),
                Text(
                  '${player.maxExp - player.exp} EXP TO LEVEL ${player.level + 1}',
                  style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Today's Quests Header
          SectionHeader(
            title: "TODAY'S QUESTS",
            right: Row(
              children: [
                Text('$doneCount/$totalCount', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => widget.onNavigate('quests'),
                  child: Text('VIEW ALL →', style: AppTypography.monoStat(fontSize: 11, color: AppColors.manaCyan)),
                ),
              ],
            ),
          ),

          // Daily Reset Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.manaCyan.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DAILY RESET', style: AppTypography.orbitron(fontSize: 9, color: AppColors.textSecondary)),
                Text('23:14:07', style: AppTypography.monoStat(fontSize: 13, color: AppColors.manaCyan)),
              ],
            ),
          ),

          // Horizontal Quest Card Scroll
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todayQuests.length,
              itemBuilder: (context, idx) {
                final q = todayQuests[idx];
                final isDone = q.done;
                final isOverdue = q.overdue && !isDone;

                Color typeColor = AppColors.manaCyan;
                if (q.type == QuestType.main) typeColor = AppColors.expFrom;
                if (q.type == QuestType.side) typeColor = AppColors.rankB;

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Opacity(
                    opacity: isDone ? 0.55 : 1.0,
                    child: GlassCard(
                      borderColor: isOverdue ? AppColors.dangerRed : typeColor.withValues(alpha: 0.25),
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RankBadge(rank: q.rank, size: RankBadgeSize.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: typeColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    q.type.name.toUpperCase(),
                                    style: AppTypography.monoStat(fontSize: 8, color: typeColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              q.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.orbitron(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDone ? AppColors.textDisabled : AppColors.textPrimary,
                              ),
                            ),
                            if (isOverdue)
                              Text('⚠ PENALTY IMMINENT', style: AppTypography.monoStat(fontSize: 8, color: AppColors.dangerRed)),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('+${q.exp} EXP', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                                GestureDetector(
                                  onTap: () => questNotifier.toggleQuest(q.id),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDone ? AppColors.buffGreen.withValues(alpha: 0.2) : Colors.transparent,
                                      border: Border.all(
                                        color: isDone ? AppColors.buffGreen : AppColors.manaCyan.withValues(alpha: 0.4),
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: isDone ? const Text('✓', style: TextStyle(fontSize: 10, color: AppColors.buffGreen, fontWeight: FontWeight.bold)) : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Gate Access / Focus Mode
          const SectionHeader(title: 'GATE ACCESS'),
          PressableCard(
            onTap: widget.onEnterFocus,
            pressedScale: 0.98,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A3EE6F5), blurRadius: 16),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Void background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [Color(0xFF0B1330), Color(0xFF030712)],
                          ),
                        ),
                      ),
                    ),
                    // Rotating portal rings
                    const Positioned.fill(
                      child: Center(
                        child: RadarBackground(
                          sizes: [70, 95],
                          color: AppColors.manaCyan,
                          baseOpacity: 0.4,
                        ),
                      ),
                    ),
                    // Center hexagonal icon
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.manaCyan.withValues(alpha: 0.2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x803EE6F5), blurRadius: 24),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('⬡', style: TextStyle(fontSize: 20, color: AppColors.manaCyan)),
                      ),
                    ),
                    // Text overlay on right
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('ENTER THE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                            Text('GATE', style: AppTypography.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.manaCyan, letterSpacing: 0.1)),
                            Text('Focus Mode · No Escape', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mana Core Widget
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SectionHeader(
                  title: 'MANA CORE',
                  right: GestureDetector(
                    onTap: () => widget.onNavigate('manacore'),
                    child: Text('DETAILS →', style: AppTypography.monoStat(fontSize: 11, color: AppColors.manaCyan)),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.manaCyan, width: 3),
                        boxShadow: [
                          BoxShadow(color: AppColors.manaCyan.withValues(alpha: 0.4), blurRadius: 12),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('$manaPct%', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$manaPct% MANA (${player.mp}/${player.maxMp})', style: AppTypography.orbitron(fontSize: 13, color: AppColors.manaCyan)),
                          Text(manaStatusText, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                          Text(manaPct > 50 ? '✦ Optimal cognitive reserves' : '⚠ Depletion pacing active', style: AppTypography.monoStat(fontSize: 9, color: manaPct > 50 ? AppColors.terminalGreen : AppColors.rankA)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              _QuickAction(label: 'ARMORY', icon: '⚔', color: AppColors.rankB, onTap: () => widget.onNavigate('armory')),
              _QuickAction(label: 'GUILD', icon: '◈', color: AppColors.rankD, onTap: () => widget.onNavigate('guild')),
              _QuickAction(label: 'CALENDAR', icon: '◆', color: AppColors.rankA, onTap: () => widget.onNavigate('calendar')),
              _QuickAction(label: 'AI COACH', icon: '◈', color: AppColors.manaCyan, onTap: () => widget.onNavigate('aicoach')),
              _QuickAction(label: 'BOSS RAID', icon: '⚔', color: AppColors.hpFrom, onTap: () => widget.onNavigate('boss')),
              _QuickAction(label: 'ALERTS', icon: '◉', color: AppColors.expFrom, onTap: () => widget.onNavigate('notifications')),
            ],
          ),
          const SizedBox(height: 20),

          // System Log
          const SectionHeader(title: 'SYSTEM LOG'),
          ...logLines.map((line) {
            Color c = AppColors.manaCyan;
            if (line['type'] == 'exp') c = AppColors.terminalGreen;
            if (line['type'] == 'gold') c = AppColors.expFrom;
            if (line['type'] == 'penalty') c = AppColors.dangerRed;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Container(width: 2, height: 16, color: c),
                  const SizedBox(width: 8),
                  Text(line['time']!, style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(line['text']!, style: AppTypography.monoStat(fontSize: 11, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor: color.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: TextStyle(fontSize: 20, color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
