import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/design_system/components/system_progress_bar.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../infrastructure/statistics_remote_data_source.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String _activeTab = 'log';
  String _viewMode = 'week';
  int? _expandedEntry = 0;

  static const entries = [
    {
      'date': 'TODAY — LOG',
      'exp': 480,
      'maxExp': 600,
      'quests': [
        {'title': 'Morning Run', 'status': 'cleared', 'exp': 120},
        {'title': '100 Push-ups', 'status': 'cleared', 'exp': 80},
        {'title': '100 Sit-ups', 'status': 'cleared', 'exp': 80},
        {'title': 'Deep Work Session', 'status': 'cleared', 'exp': 200},
        {'title': 'Evening Meditation', 'status': 'failed', 'exp': 0},
      ],
      'mood': 4,
      'log': 'Pushed through the afternoon slump. The System doesn\'t sleep, and neither will I.',
    },
    {
      'date': 'YESTERDAY — LOG',
      'exp': 600,
      'maxExp': 600,
      'quests': [
        {'title': 'Morning Run', 'status': 'cleared', 'exp': 120},
        {'title': '100 Push-ups', 'status': 'cleared', 'exp': 80},
        {'title': 'Ship Module v2.3', 'status': 'cleared', 'exp': 300},
        {'title': 'Evening Meditation', 'status': 'cleared', 'exp': 100},
      ],
      'mood': 5,
      'log': 'Perfect quota achieved. Level ceiling breaking soon. The System rewards relentlessness.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(lifetimeStatsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        AriseLayoutInsets.topHeaderInset(context),
        16,
        AriseLayoutInsets.bottomContentInset(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[ GROWTH LOG & ANALYTICS ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
          Text('JOURNAL', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Tabs
          GlassCard(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Expanded(
                  child: PressableCard(
                    onTap: () => setState(() => _activeTab = 'log'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 'log' ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(bottom: BorderSide(color: _activeTab == 'log' ? AppColors.manaCyan : Colors.transparent, width: 2)),
                      ),
                      alignment: Alignment.center,
                      child: Text("HUNTER'S LOG", style: AppTypography.orbitron(fontSize: 10, color: _activeTab == 'log' ? AppColors.manaCyan : AppColors.textDisabled)),
                    ),
                  ),
                ),
                Expanded(
                  child: PressableCard(
                    onTap: () => setState(() => _activeTab = 'analytics'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 'analytics' ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(bottom: BorderSide(color: _activeTab == 'analytics' ? AppColors.manaCyan : Colors.transparent, width: 2)),
                      ),
                      alignment: Alignment.center,
                      child: Text('ANALYTICS', style: AppTypography.orbitron(fontSize: 10, color: _activeTab == 'analytics' ? AppColors.manaCyan : AppColors.textDisabled)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_activeTab == 'log') ...[
            // View Mode Toggle
            GlassCard(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: ['THIS WEEK', 'THIS MONTH'].map((v) {
                  final key = v == 'THIS WEEK' ? 'week' : 'month';
                  final isActive = _viewMode == key;
                  return Expanded(
                    child: PressableCard(
                      onTap: () => setState(() => _viewMode = key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(v, style: AppTypography.orbitron(fontSize: 9, color: isActive ? AppColors.manaCyan : AppColors.textDisabled)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Daily Log Entries
            ...List.generate(entries.length, (index) {
              final entry = entries[index];
              final isExpanded = _expandedEntry == index;
              final quests = entry['quests'] as List<Map<String, dynamic>>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _expandedEntry = isExpanded ? null : index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry['date'] as String, style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                Text('EXP: ${entry['exp']} / ${entry['maxExp']}', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                              ],
                            ),
                            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SystemProgressBar(
                        value: (entry['exp'] as int).toDouble(),
                        max: (entry['maxExp'] as int).toDouble(),
                        variant: ProgressBarVariant.exp,
                        height: 6,
                      ),
                      if (isExpanded) ...[
                        const DiamondDivider(),
                        ...quests.map((q) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(q['title'] as String, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textPrimary)),
                                  Text('+${q['exp']} EXP', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                                ],
                              ),
                            )),
                        const SizedBox(height: 8),
                        Text('"${entry['log']}"', style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary).copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],

          if (_activeTab == 'analytics') ...[
            statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ AUTHORITATIVE LIFETIME METRICS (§6.20) ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                  const SizedBox(height: 8),

                  // Stat Tiles Grid
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: AppColors.expFrom.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QUESTS COMPLETED', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${stats.quests.completed} / ${stats.quests.total}', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                              Text('${stats.quests.completionRatePct}% RATE', style: AppTypography.monoStat(fontSize: 8, color: AppColors.buffGreen)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: AppColors.manaCyan.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FOCUS GATES', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${stats.focus.completedSessions} CLEARED', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                              Text('${stats.focus.totalFocusMinutes} TOTAL MIN', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: AppColors.dangerRed.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BOSSES SLAIN', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${stats.bosses.defeated} DEFEATED', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                              Text('${stats.bosses.active} ACTIVE BOSSES', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: AppColors.rankD.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT STREAK', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${stats.progression.currentStreak} DAYS', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.rankD)),
                              Text('RECORD: ${stats.progression.longestStreak} DAYS', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // XP Progression Line Chart
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'XP PROGRESSION TREND'),
                        SizedBox(
                          height: 100,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 300), FlSpot(1, 450), FlSpot(2, 400),
                                    FlSpot(3, 550), FlSpot(4, 700), FlSpot(5, 600), FlSpot(6, 750),
                                  ],
                                  isCurved: true,
                                  color: AppColors.expFrom,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.expFrom.withValues(alpha: 0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Focus Hours Bar Chart
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'DAILY FOCUS LOAD'),
                        SizedBox(
                          height: 90,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 30, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 75, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 90, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 25, color: AppColors.manaCyan, width: 14)]),
                                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 50, color: AppColors.manaCyan, width: 14)]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.manaCyan),
                ),
              ),
              error: (err, _) => GlassCard(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('Failed to load lifetime stats: $err', style: AppTypography.rajdhani(fontSize: 12, color: AppColors.dangerRed)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
