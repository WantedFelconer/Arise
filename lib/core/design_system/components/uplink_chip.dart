import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import 'glass_card.dart';

class UplinkChip extends StatelessWidget {
  final bool stable;

  const UplinkChip({super.key, this.stable = true});

  @override
  Widget build(BuildContext context) {
    final color = stable ? AppColors.terminalGreen : AppColors.dangerRed;

    return GlassCard(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderColor: color.withValues(alpha: stable ? 0.25 : 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            stable ? 'UPLINK: STABLE' : 'UPLINK: SEVERED',
            style: AppTypography.monoStat(
              fontSize: 8,
              color: color,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}
