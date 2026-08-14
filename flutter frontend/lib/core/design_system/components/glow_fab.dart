import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import 'arise_pressable.dart';

class GlowFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconText;
  final Color color;
  final double size;

  const GlowFab({
    super.key,
    required this.onPressed,
    this.iconText = '+',
    this.color = AppColors.manaCyan,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ArisePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 2,
            )
          ],
          border: Border.all(color: color, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          iconText,
          style: AppTypography.orbitron(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
