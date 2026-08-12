import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../design_system/components/arise_pressable.dart';
import '../../design_system/components/glass_card.dart';
import '../../design_system/components/uplink_chip.dart';

class TopStatusBar extends StatelessWidget {
  final int hp;
  final int maxHp;
  final int mp;
  final int maxMp;
  final int level;
  final int streak;
  final bool uplinkStable;
  final VoidCallback onManaCoreClick;
  final VoidCallback? onNotificationsClick;
  final VoidCallback? onSettingsClick;
  final VoidCallback? onAiCoachClick;
  final VoidCallback? onPenaltyClick;

  const TopStatusBar({
    super.key,
    required this.hp,
    required this.maxHp,
    required this.mp,
    required this.maxMp,
    required this.level,
    required this.streak,
    this.uplinkStable = true,
    required this.onManaCoreClick,
    this.onNotificationsClick,
    this.onSettingsClick,
    this.onAiCoachClick,
    this.onPenaltyClick,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 4.0, 10, 6),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFA030712),
              Color(0x99030712),
              Color(0x00030712),
            ],
            stops: [0.0, 0.8, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Level Badge + HP Pill + MP Pill
            Row(
              children: [
                GlassCard(
                  borderRadius: BorderRadius.circular(999),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  borderColor: AppColors.expFrom.withValues(alpha: 0.3),
                  child: Text(
                    'LV.$level',
                    style: AppTypography.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.expFrom,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    label: 'HP',
                    value: hp,
                    max: maxHp,
                    color: AppColors.hpFrom,
                    gradient: const LinearGradient(colors: [AppColors.hpFrom, AppColors.hpTo]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    label: 'MP',
                    value: mp,
                    max: maxMp,
                    color: AppColors.mpFrom,
                    gradient: const LinearGradient(colors: [AppColors.mpFrom, AppColors.mpTo]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: System Status (Uplink, Penalty) on left; Action Shortcuts (Streak, Mana Ring, Notifications, AI Coach, Settings) on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Uplink Chip & Demo Penalty Trigger
                Row(
                  children: [
                    UplinkChip(stable: uplinkStable),
                    if (onPenaltyClick != null) ...[
                      const SizedBox(width: 6),
                      ArisePressable(
                        onTap: onPenaltyClick,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
                          ),
                          child: const Text('⚠', style: TextStyle(fontSize: 10, color: AppColors.dangerRed)),
                        ),
                      ),
                    ],
                  ],
                ),

                // Right side: Streak, Mana Ring, Notifications, AI Coach, Settings
                Row(
                  children: [
                    // Streak
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 2),
                        Text(
                          '$streak',
                          style: AppTypography.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.rankA,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Mini Mana Ring button
                    ArisePressable(
                      onTap: onManaCoreClick,
                      borderRadius: BorderRadius.circular(12),
                      child: const _MiniManaRing(pct: 0.65),
                    ),

                    // Notifications shortcut (Single & authoritative)
                    if (onNotificationsClick != null) ...[
                      const SizedBox(width: 8),
                      ArisePressable(
                        onTap: onNotificationsClick,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.manaCyan.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🔔', style: TextStyle(fontSize: 10, color: AppColors.manaCyan)),
                        ),
                      ),
                    ],

                    // AI Coach shortcut
                    if (onAiCoachClick != null) ...[
                      const SizedBox(width: 8),
                      ArisePressable(
                        onTap: onAiCoachClick,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.manaCyan.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('◈', style: TextStyle(fontSize: 11, color: AppColors.manaCyan)),
                        ),
                      ),
                    ],

                    // Settings gear shortcut
                    if (onSettingsClick != null) ...[
                      const SizedBox(width: 8),
                      ArisePressable(
                        onTap: onSettingsClick,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.manaCyan.withValues(alpha: 0.08),
                            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('⚙', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final LinearGradient gradient;

  const _StatPill({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (max > 0 ? value / max : 0.0).clamp(0.0, 1.0);

    return GlassCard(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.monoStat(fontSize: 8, color: color),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0x80000000),
                borderRadius: BorderRadius.circular(999),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth * pct,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: AppTypography.monoStat(
              fontSize: 7,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniManaRing extends StatelessWidget {
  final double pct;

  const _MiniManaRing({required this.pct});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _ManaRingPainter(pct: pct),
      ),
    );
  }
}

class _ManaRingPainter extends CustomPainter {
  final double pct;

  _ManaRingPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5) / 2;

    final bgPaint = Paint()
      ..color = AppColors.manaCyan.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fgPaint = Paint()
      ..color = AppColors.manaCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ManaRingPainter oldDelegate) => oldDelegate.pct != pct;
}
