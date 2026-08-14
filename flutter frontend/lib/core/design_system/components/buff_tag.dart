import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class BuffTag extends StatelessWidget {
  final String label;

  const BuffTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.buffGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.buffGreen.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2639FF88),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.rajdhani(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.buffGreen,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}
