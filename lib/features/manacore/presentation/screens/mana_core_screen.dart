import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class ManaCoreScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ManaCoreScreen({super.key, required this.onBack});

  static const appBreakdown = [
    {'name': 'Instagram', 'drain': 48, 'limit': 30, 'icon': '📸', 'color': AppColors.rankA},
    {'name': 'YouTube', 'drain': 34, 'limit': 20, 'icon': '▶', 'color': AppColors.dangerRed},
    {'name': 'Reddit', 'drain': 22, 'limit': 15, 'icon': '◈', 'color': AppColors.rankA},
    {'name': 'Twitter/X', 'drain': 18, 'limit': 15, 'icon': '⚡', 'color': AppColors.expFrom},
    {'name': 'Discord', 'drain': 10, 'limit': 60, 'icon': '◆', 'color': AppColors.rankD},
    {'name': 'Notion (work)', 'drain': 35, 'limit': 120, 'icon': '◉', 'color': AppColors.terminalGreen},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, AriseLayoutInsets.topOverlayInset(context), 16, AriseLayoutInsets.bottomOverlayInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AriseBackButton(onPressed: onBack),
          const SizedBox(height: 16),
          Text('[ MANA ECONOMY — SCREEN TIME ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
          Text('MANA CORE', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          // Main Ring Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _ManaCoreRingPainter(pct: 0.65),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('65%', style: AppTypography.monoStat(fontSize: 36, color: AppColors.manaCyan)),
                          Text('MANA REMAINING', style: AppTypography.orbitron(fontSize: 8, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('65%', style: AppTypography.monoStat(fontSize: 16, color: AppColors.manaCyan)),
                        Text('AVAILABLE', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Container(width: 1, height: 24, color: AppColors.manaCyan.withValues(alpha: 0.2)),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        Text('35%', style: AppTypography.monoStat(fontSize: 16, color: AppColors.hpFrom)),
                        Text('CONSUMED', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Depletion Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rankA.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.rankA.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('⚠', style: TextStyle(fontSize: 20, color: AppColors.rankA)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MANA DEPLETES IN 2H 14M', style: AppTypography.orbitron(fontSize: 11, color: AppColors.rankA)),
                      Text('At current consumption rate. Reduce drain to preserve focus.', style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const DiamondDivider(),

          // Breakdown List
          const SectionHeader(title: 'MANA DRAIN BY APP'),
          ...appBreakdown.map((app) {
            final drain = app['drain'] as int;
            final limit = app['limit'] as int;
            final overLimit = drain > limit;
            final color = app['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassCard(
                borderColor: overLimit ? AppColors.dangerRed.withValues(alpha: 0.3) : AppColors.glassBorder,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(app['icon'] as String, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(app['name'] as String, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary)),
                            if (overLimit) ...[
                              const SizedBox(width: 6),
                              Text('OVER LIMIT', style: AppTypography.monoStat(fontSize: 7, color: AppColors.dangerRed)),
                            ],
                          ],
                        ),
                        Text('$drain m / $limit m', style: AppTypography.monoStat(fontSize: 10, color: overLimit ? AppColors.dangerRed : AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(color: const Color(0x800A1A3A), borderRadius: BorderRadius.circular(999)),
                      child: FractionallySizedBox(
                        widthFactor: (drain / limit).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Zero Mana Depletion Protocol Warning
          const SizedBox(height: 16),
          GlassCard(
            borderColor: AppColors.dangerRed.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠ MANA DEPLETION PROTOCOL', style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                const SizedBox(height: 6),
                Text(
                  'When Mana reaches 0%, distracting applications are restricted by the System. Complete quests to restore Mana reserves.',
                  style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔒 ', style: TextStyle(fontSize: 14)),
                      Text('LOCK OVERLAY — ACTIVATES AT 0% MANA', style: AppTypography.monoStat(fontSize: 9, color: AppColors.dangerRed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManaCoreRingPainter extends CustomPainter {
  final double pct;

  _ManaCoreRingPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 82.0;

    final bgPaint = Paint()
      ..color = AppColors.manaCyan.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Drained portion (red gradient)
    final drainedPaint = Paint()
      ..shader = const LinearGradient(colors: [AppColors.hpFrom, AppColors.hpTo]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Remaining portion (cyan gradient)
    final remainingPaint = Paint()
      ..shader = const LinearGradient(colors: [AppColors.manaCyan, AppColors.secondaryTeal]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * (1.0 - pct), false, drainedPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * pct, false, remainingPaint);
  }

  @override
  bool shouldRepaint(covariant _ManaCoreRingPainter oldDelegate) => oldDelegate.pct != pct;
}
