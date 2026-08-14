import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import 'shimmer_effect.dart';

enum ProgressBarVariant { hp, mp, exp, cyan, green }

class SystemProgressBar extends StatelessWidget {
  final double value;
  final double max;
  final ProgressBarVariant variant;
  final bool showNumbers;
  final String? label;
  final double height;

  const SystemProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.variant = ProgressBarVariant.cyan,
    this.showNumbers = false,
    this.label,
    this.height = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (max > 0 ? (value / max) : 0.0).clamp(0.0, 1.0);

    LinearGradient gradient;
    Color glowColor;

    switch (variant) {
      case ProgressBarVariant.hp:
        gradient = const LinearGradient(colors: [AppColors.hpFrom, AppColors.hpTo]);
        glowColor = const Color(0x99FF5A36);
        break;
      case ProgressBarVariant.mp:
        gradient = const LinearGradient(colors: [AppColors.mpFrom, AppColors.mpTo]);
        glowColor = const Color(0x992E9BFF);
        break;
      case ProgressBarVariant.exp:
        gradient = const LinearGradient(colors: [AppColors.expFrom, AppColors.expTo]);
        glowColor = const Color(0x99FFD24C);
        break;
      case ProgressBarVariant.cyan:
        gradient = const LinearGradient(colors: [AppColors.manaCyan, AppColors.secondaryTeal]);
        glowColor = const Color(0x993EE6F5);
        break;
      case ProgressBarVariant.green:
        gradient = const LinearGradient(colors: [AppColors.terminalGreen, Color(0xFF1AA855)]);
        glowColor = const Color(0x8039FF88);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showNumbers) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: AppTypography.monoStat(fontSize: 12, color: AppColors.textSecondary),
                ),
              if (showNumbers)
                Text(
                  '${value.toInt()} / ${max.toInt()}',
                  style: AppTypography.monoStat(fontSize: 12, color: AppColors.textPrimary),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xCC0A1A3A),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x143EE6F5), width: 1.0),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * pct;
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    width: barWidth,
                    height: height,
                    child: ShimmerEffect(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor,
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
