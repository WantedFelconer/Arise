import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Orbitron - Display & System Headers
  static TextStyle orbitron({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.08,
    double? height,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: fontSize * letterSpacing,
      height: height,
    );
  }

  // Rajdhani - Body & Descriptions
  static TextStyle rajdhani({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.02,
    double? height,
  }) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: fontSize * letterSpacing,
      height: height,
    );
  }

  // Share Tech Mono - Numerical & Terminal Readouts
  static TextStyle monoStat({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.04,
    double? height,
  }) {
    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: fontSize * letterSpacing,
      height: height,
    );
  }
}
