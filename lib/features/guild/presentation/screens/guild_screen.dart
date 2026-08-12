import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class GuildScreen extends StatefulWidget {
  const GuildScreen({super.key});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  String _tab = 'party';

  static const partyMembers = [
    {'id': 1, 'name': 'KIRA', 'title': 'The Ironclad', 'rank': 'B', 'level': 18, 'hp': 85, 'streak': 22, 'online': true, 'score': 2840},
    {'id': 2, 'name': 'JIN-SOO', 'title': 'Shadow Walker', 'rank': 'A', 'level': 23, 'hp': 92, 'streak': 31, 'online': true, 'score': 4120},
    {'id': 3, 'name': 'MIRAE', 'title': 'The Scholar', 'rank': 'C', 'level': 12, 'hp': 60, 'streak': 8, 'online': false, 'score': 1480},
    {'id': 4, 'name': 'CHUL-SU', 'title': 'Crimson Blade', 'rank': 'B', 'level': 16, 'hp': 78, 'streak': 14, 'online': false, 'score': 2190},
  ];

  static const raidQuests = [
    {'id': 1, 'name': 'PARTY RUN — 50KM WEEK', 'rank': 'A', 'desc': '4 members must collectively run 50km this week.', 'progress': 37, 'target': 50, 'unit': 'km', 'reward': 800},
    {'id': 2, 'name': 'GUILD DEEP WORK', 'rank': 'B', 'desc': 'Each member completes 4 focused sessions this week.', 'progress': 10, 'target': 16, 'unit': 'sessions', 'reward': 500},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 60, 16, AriseLayoutInsets.bottomOverlayInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ PARTY INTERFACE ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                  Text('GUILD', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderColor: AppColors.rankD.withValues(alpha: 0.3),
                child: Text('DISCORD: LINKED', style: AppTypography.monoStat(fontSize: 8, color: AppColors.rankD)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Discord Header
          GlassCard(
            borderColor: AppColors.rankD.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.rankD.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: const Text('◆', style: TextStyle(color: AppColors.rankD, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ARISE HUNTERS #general', style: AppTypography.orbitron(fontSize: 11, color: AppColors.textPrimary)),
                      Text('4 members · Achievements posted automatically', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tabs
          GlassCard(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: ['party', 'leaderboard', 'raids'].map((t) {
                final isActive = _tab == t;
                final label = t == 'raids' ? 'RAIDS' : t == 'party' ? 'PARTY' : 'BOARD';
                return Expanded(
                  child: PressableCard(
                    onTap: () => setState(() => _tab = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(bottom: BorderSide(color: isActive ? AppColors.manaCyan : Colors.transparent, width: 2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(label, style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.w700, color: isActive ? AppColors.manaCyan : AppColors.textDisabled)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (_tab == 'party') ...[
            ...partyMembers.map((m) {
              final online = m['online'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GlassCard(
                  borderColor: online ? AppColors.manaCyan.withValues(alpha: 0.2) : AppColors.glassBorder,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.manaCyan.withValues(alpha: 0.1),
                        child: Text(m['name'].toString()[0], style: AppTypography.orbitron(fontSize: 14, color: AppColors.manaCyan)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(m['name'] as String, style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary)),
                                const SizedBox(width: 6),
                                RankBadge(rank: m['rank'] as String, size: RankBadgeSize.sm),
                              ],
                            ),
                            Text('${m['title']} · LV.${m['level']}', style: AppTypography.rajdhani(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${m['score']} PTS', style: AppTypography.monoStat(fontSize: 12, color: AppColors.expFrom)),
                          Text(online ? '● ONLINE' : '○ OFFLINE', style: AppTypography.monoStat(fontSize: 8, color: online ? AppColors.terminalGreen : AppColors.textDisabled)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ DISCORD PARTY CHAT STREAM ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('KIRA: Cleared 10km run! +240 EXP', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textPrimary)),
                  Text('JIN-SOO: Raid boss objective at 74%. Keep pushing!', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.manaCyan)),
                ],
              ),
            ),
          ],

          if (_tab == 'leaderboard') ...[
            Text('[ GUILD LEADERBOARD — WEEK 31 ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 12),
            ...partyMembers.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              final medal = idx == 0 ? '🥇' : idx == 1 ? '🥈' : idx == 2 ? '🥉' : '#${idx + 1}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GlassCard(
                  borderColor: idx == 0 ? AppColors.expFrom.withValues(alpha: 0.4) : AppColors.glassBorder,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(width: 32, child: Text(medal, style: TextStyle(fontSize: idx < 3 ? 18 : 12, color: AppColors.textPrimary))),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.manaCyan.withValues(alpha: 0.1),
                        child: Text(m['name'].toString()[0], style: AppTypography.orbitron(fontSize: 12, color: AppColors.manaCyan)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name'] as String, style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary)),
                            Text('${m['streak']} DAY STREAK', style: AppTypography.monoStat(fontSize: 8, color: AppColors.terminalGreen)),
                          ],
                        ),
                      ),
                      Text('${m['score']} EXP', style: AppTypography.monoStat(fontSize: 13, color: AppColors.expFrom, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }),
          ],

          if (_tab == 'raids')
            ...raidQuests.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  borderColor: AppColors.rankB.withValues(alpha: 0.25),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RankBadge(rank: r['rank'] as String, size: RankBadgeSize.sm),
                          const SizedBox(width: 8),
                          Text(r['name'] as String, style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r['desc'] as String, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PROGRESS', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                          Text('${r['progress']} / ${r['target']} ${r['unit']}', style: AppTypography.monoStat(fontSize: 9, color: AppColors.manaCyan)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(color: const Color(0x800A1A3A), borderRadius: BorderRadius.circular(999)),
                        child: FractionallySizedBox(
                          widthFactor: ((r['progress'] as int) / (r['target'] as int)).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.manaCyan, borderRadius: BorderRadius.circular(999)),
                          ),
                        ),
                      ),
                      const DiamondDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PARTY REWARD', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                          Text('+${r['reward']} EXP EACH', style: AppTypography.monoStat(fontSize: 12, color: AppColors.expFrom)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
