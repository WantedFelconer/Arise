import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class RewardChip extends StatelessWidget {
  final int? exp;
  final int? gold;

  const RewardChip({
    super.key,
    this.exp,
    this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exp != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.expFrom.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.expFrom.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '◆ ',
                  style: TextStyle(color: AppColors.expFrom, fontSize: 8),
                ),
                Text(
                  '$exp EXP',
                  style: AppTypography.monoStat(
                    fontSize: 10,
                    color: AppColors.expFrom,
                  ),
                ),
              ],
            ),
          ),
          if (gold != null) const SizedBox(width: 6),
        ],
        if (gold != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.expTo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.expTo.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⬡ ',
                  style: TextStyle(color: AppColors.expTo, fontSize: 8),
                ),
                Text(
                  '${gold}G',
                  style: AppTypography.monoStat(
                    fontSize: 10,
                    color: AppColors.expTo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
