import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<int> _acceptedIds = [1, 2, 4];

  static const events = [
    {'id': 1, 'title': 'Team Standup', 'time': '09:00', 'duration': '30m', 'type': 'meeting', 'exp': 40},
    {'id': 2, 'title': 'Project Deadline: v2.4 Launch', 'time': '17:00', 'duration': 'ALL DAY', 'type': 'deadline', 'exp': 200},
    {'id': 3, 'title': 'Doctor Appointment', 'time': '11:30', 'duration': '1h', 'type': 'personal', 'exp': 60},
    {'id': 4, 'title': 'Code Review Session', 'time': '14:00', 'duration': '1h 30m', 'type': 'meeting', 'exp': 80},
    {'id': 5, 'title': 'Dentist', 'time': '16:30', 'duration': '45m', 'type': 'personal', 'exp': 50},
  ];

  static const typeRank = {'meeting': 'D', 'deadline': 'A', 'personal': 'C'};
  static const typeColor = {'meeting': AppColors.mpFrom, 'deadline': AppColors.rankA, 'personal': AppColors.rankD};

  void _toggleAccept(int id) {
    setState(() {
      _acceptedIds.contains(id) ? _acceptedIds.remove(id) : _acceptedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 60, 16, AriseLayoutInsets.bottomOverlayInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[ QUEST SCHEDULE — CALENDAR SYNC ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
          Text('SCHEDULE', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          // Google Calendar Banner
          GlassCard(
            borderColor: AppColors.rankD.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.rankD.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text('📅', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GOOGLE CALENDAR SYNC', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('● Connected — 5 events detected today', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.terminalGreen)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"External commitments detected in Google Calendar. Convert to System Quests to earn EXP upon completion."',
                  style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL POTENTIAL: +430 EXP', style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom)),
                    PressableCard(
                      onTap: () => setState(() => _acceptedIds.addAll([1, 2, 3, 4, 5])),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.manaCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.manaCyan),
                        ),
                        child: Text('[ CONVERT ALL TO QUESTS ]', style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Events Timeline
          ...events.map((ev) {
            final id = ev['id'] as int;
            final accepted = _acceptedIds.contains(id);
            final type = ev['type'] as String;
            final color = typeColor[type] ?? AppColors.manaCyan;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(ev['time'] as String, style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: GlassCard(
                      borderColor: accepted ? color.withValues(alpha: 0.4) : AppColors.glassBorder,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          RankBadge(rank: typeRank[type] ?? 'E', size: RankBadgeSize.sm),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ev['title'] as String, style: AppTypography.orbitron(fontSize: 11, color: AppColors.textPrimary)),
                                Text('⏱ ${ev['duration']} · +${ev['exp']} EXP', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                              ],
                            ),
                          ),
                          PressableCard(
                            onTap: () => _toggleAccept(id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: accepted ? color.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: accepted ? color : AppColors.textDisabled),
                              ),
                              child: Text(accepted ? '✓ QUEST' : 'ACCEPT', style: AppTypography.orbitron(fontSize: 8, color: accepted ? color : AppColors.textDisabled)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
