import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.voidEdge,
      primaryColor: AppColors.manaCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.manaCyan,
        secondary: AppColors.secondaryTeal,
        surface: AppColors.glassPanel,
        error: AppColors.dangerRed,
        onPrimary: AppColors.voidEdge,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        bodyMedium: AppTypography.rajdhani(fontSize: 14, color: AppColors.textPrimary),
        bodySmall: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
        titleLarge: AppTypography.orbitron(fontSize: 22, color: AppColors.textPrimary),
        titleMedium: AppTypography.orbitron(fontSize: 16, color: AppColors.textPrimary),
      ),
      iconTheme: const IconThemeData(color: AppColors.manaCyan),
    );
  }
}
