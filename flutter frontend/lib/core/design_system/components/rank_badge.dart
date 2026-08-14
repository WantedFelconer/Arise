import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

enum RankBadgeSize { sm, md, lg }

class RankBadge extends StatelessWidget {
  final String rank;
  final RankBadgeSize size;

  const RankBadge({
    super.key,
    required this.rank,
    this.size = RankBadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final r = rank.toUpperCase();
    final color = AppColors.getRankColor(r);

    double wh = 32.0;
    double fontSize = 14.0;
    switch (size) {
      case RankBadgeSize.sm:
        wh = 24.0;
        fontSize = 11.0;
        break;
      case RankBadgeSize.md:
        wh = 32.0;
        fontSize = 14.0;
        break;
      case RankBadgeSize.lg:
        wh = 40.0;
        fontSize = 18.0;
        break;
    }

    return Container(
      width: wh,
      height: wh,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: r == 'S' || r == 'E' ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        r,
        style: AppTypography.orbitron(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
