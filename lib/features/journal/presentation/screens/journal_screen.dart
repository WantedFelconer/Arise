import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/design_system/components/system_progress_bar.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _activeTab = 'log';
  String _viewMode = 'week';
  int? _expandedEntry = 0;

  static const entries = [
    {
      'date': 'TODAY — JUL 31',
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
      'log': 'Pushed through the afternoon slump. The System doesn\'t sleep, and neither will I. Still need to fix the meditation streak.',
    },
    {
      'date': 'JUL 30',
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
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, AriseLayoutInsets.topHeaderInset(context), 16, AriseLayoutInsets.bottomContentInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[ GROWTH LOG ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
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
                          border: Border(bottom: BorderSide(color: isActive ? AppColors.manaCyan : Colors.transparent, width: 2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(v, style: AppTypography.orbitron(fontSize: 9, color: isActive ? AppColors.manaCyan : AppColors.textDisabled)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Heatmap Grid
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SectionHeader(title: 'QUEST ACTIVITY'),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(28, (i) {
                      final intensity = (i % 5) * 0.25;
                      return Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.manaCyan.withValues(alpha: intensity == 0 ? 0.06 : intensity),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: i == 27 ? AppColors.manaCyan : AppColors.manaCyan.withValues(alpha: 0.1)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Month Report
            GlassCard(
              borderColor: AppColors.expFrom.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'MONTH REPORT — JULY'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatTile(label: 'TOTAL EXP', value: '14,820', color: AppColors.expFrom),
                      _StatTile(label: 'CLEARED', value: '94', color: AppColors.buffGreen),
                      _StatTile(label: 'PENALTIES', value: '7', color: AppColors.dangerRed),
                    ],
                  ),
                  const DiamondDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('14 DAY STREAK', style: AppTypography.orbitron(fontSize: 14, color: AppColors.rankA)),
                              Text('CURRENT RUN', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('480 EXP/DAY', style: AppTypography.monoStat(fontSize: 13, color: AppColors.manaCyan)),
                          Text('AVERAGE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Growth Log Entries
            const SectionHeader(title: "HUNTER'S LOG"),
            ...entries.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              final isExpanded = _expandedEntry == idx;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () => setState(() => _expandedEntry = isExpanded ? null : idx),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry['date'] as String, style: AppTypography.orbitron(fontSize: 11, color: idx == 0 ? AppColors.manaCyan : AppColors.textPrimary)),
                              Text('+${entry['exp']} EXP', style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom)),
                            ],
                          ),
                          SizedBox(
                            width: 80,
                            child: SystemProgressBar(value: (entry['exp'] as int).toDouble(), max: (entry['maxExp'] as int).toDouble(), variant: ProgressBarVariant.exp, height: 6),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const DiamondDivider(),
                        ...((entry['quests'] as List).map((q) {
                          final isCleared = q['status'] == 'cleared';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${isCleared ? "✓" : "✗"} ${q['title']}', style: AppTypography.rajdhani(fontSize: 12, color: isCleared ? AppColors.textPrimary : AppColors.textDisabled)),
                                if (q['exp'] > 0) Text('+${q['exp']}', style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom)),
                              ],
                            ),
                          );
                        })),
                        const SizedBox(height: 8),
                        Text('"[ ${entry['log']} ]"', style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassPanel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📷 ', style: TextStyle(fontSize: 14)),
                              Text('[ ATTACH PROOF PHOTO ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.manaCyan)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],

          if (_activeTab == 'analytics') ...[
            Text('[ PERFORMANCE ANALYTICS — JULY 2025 ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 12),

            // XP Progression Line Chart
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'XP PROGRESSION'),
                  SizedBox(
                    height: 100,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Text(days[idx], style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 480), FlSpot(1, 600), FlSpot(2, 320), FlSpot(3, 550),
                              FlSpot(4, 700), FlSpot(5, 280), FlSpot(6, 600),
                            ],
                            isCurved: true,
                            color: AppColors.manaCyan,
                            barWidth: 2,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.manaCyan.withValues(alpha: 0.1),
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
                  const SectionHeader(title: 'FOCUS HOURS'),
                  SizedBox(
                    height: 100,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Text(days[idx], style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3.5, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5.0, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2.0, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4.5, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6.0, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 1.5, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3.0, color: AppColors.manaCyan.withValues(alpha: 0.6), width: 14)]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category Radar Chart
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'CATEGORY BREAKDOWN'),
                  SizedBox(
                    height: 160,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        radarBorderData: const BorderSide(color: AppColors.glassBorder),
                        gridBorderData: const BorderSide(color: Color(0x1F3EE6F5)),
                        tickBorderData: const BorderSide(color: Colors.transparent),
                        ticksTextStyle: const TextStyle(color: Colors.transparent),
                        dataSets: [
                          RadarDataSet(
                            fillColor: AppColors.manaCyan.withValues(alpha: 0.15),
                            borderColor: AppColors.manaCyan,
                            entryRadius: 3,
                            dataEntries: const [
                              RadarEntry(value: 78), // BODY
                              RadarEntry(value: 62), // MIND
                              RadarEntry(value: 85), // CRAFT
                              RadarEntry(value: 70), // DISC
                              RadarEntry(value: 35), // SOCIAL
                            ],
                          ),
                        ],
                        getTitle: (index, angle) {
                          const titles = ['BODY', 'MIND', 'CRAFT', 'DISC', 'SOCIAL'];
                          return RadarChartTitle(text: titles[index % titles.length]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Mana & Energy Dual Trend Chart
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'MANA & ENERGY TREND'),
                  SizedBox(
                    height: 100,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Text(days[idx], style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Mana (Blue)
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 80), FlSpot(1, 75), FlSpot(2, 60),
                              FlSpot(3, 85), FlSpot(4, 90), FlSpot(5, 50), FlSpot(6, 72),
                            ],
                            isCurved: true,
                            color: AppColors.mpFrom,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                          // Energy (Green)
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 65), FlSpot(1, 78), FlSpot(2, 55),
                              FlSpot(3, 72), FlSpot(4, 88), FlSpot(5, 45), FlSpot(6, 80),
                            ],
                            isCurved: true,
                            color: AppColors.buffGreen,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 12, height: 2, color: AppColors.mpFrom),
                      const SizedBox(width: 4),
                      Text('MANA', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      Container(width: 12, height: 2, color: AppColors.buffGreen),
                      const SizedBox(width: 4),
                      Text('ENERGY', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Monthly Summary Ornate Panel
            OrnatePanel(
              cornerSize: 22,
              noCrest: true,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[ SYSTEM AI — MONTHLY ANALYSIS ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      '"Hunter, July was a decisive month. Your Craft stat surged to 85% efficiency while Social tasks remain critically underinvested at 35%. You averaged 480 EXP/day — 20% below your theoretical peak. The System recommends: increase Mind quest allocation by 15%, add one Social quest per week. You are 7 penalties away from automatic dungeon lock — recalibrate immediately."',
                      style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textPrimary, height: 1.5),
                    ),
                    const DiamondDivider(),
                    PressableCard(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.manaCyan.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.25)),
                        ),
                        alignment: Alignment.center,
                        child: Text('[ EXPORT REPORT AS PDF ]', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.monoStat(fontSize: 16, color: color)),
        Text(label, style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
      ],
    );
  }
}
