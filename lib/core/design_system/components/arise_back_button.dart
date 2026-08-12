import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import 'arise_pressable.dart';

/// Canonical ARISE Back Button component.
///
/// Features:
/// - Tab-style pill container matching ARISE futuristic design system.
/// - Tactile mechanical press-down and spring-release animation ([ArisePressable]).
/// - Cyan accent border, subtle background glow, and Orbitron typography.
class AriseBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool showArrow;

  const AriseBackButton({
    super.key,
    required this.onPressed,
    this.label = 'BACK',
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ArisePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xD10A1A3A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x403EE6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A3EE6F5),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArrow) ...[
              const Text('←', style: TextStyle(fontSize: 11, color: AppColors.manaCyan, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.orbitron(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.manaCyan,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
