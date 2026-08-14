import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? right;

  const SectionHeader({
    super.key,
    required this.title,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.manaCyan, AppColors.secondaryTeal],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTypography.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.08,
                ),
              ),
            ],
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}
