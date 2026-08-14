import 'package:flutter/material.dart';

abstract final class AppColors {
  // Void background
  static const Color voidCenter = Color(0xFF0B1330);
  static const Color voidEdge = Color(0xFF030712);
  
  // Glass panel
  static const Color glassPanel = Color(0xD10A1A3A); // 82% opacity #0A1A3A
  static const Color glassBorder = Color(0x383EE6F5); // 22% cyan border
  static const Color glassBorderLight = Color(0x733EE6F5); // 45% cyan border

  // Mana Cyan & Accents
  static const Color manaCyan = Color(0xFF3EE6F5);
  static const Color secondaryTeal = Color(0xFF1FA9C2);
  static const Color cyanGlow = Color(0x593EE6F5); // 35% opacity cyan

  // Text Colors
  static const Color textPrimary = Color(0xFFEAF6FF);
  static const Color textSecondary = Color(0xFF7FA0C9);
  static const Color textDisabled = Color(0xFF3E5578);

  // Status & Gauges
  static const Color terminalGreen = Color(0xFF39FF88);
  static const Color buffGreen = Color(0xFF39FF88);
  static const Color hpFrom = Color(0xFFFF5A36);
  static const Color hpTo = Color(0xFFC4171C);
  static const Color mpFrom = Color(0xFF2E9BFF);
  static const Color mpTo = Color(0xFF1560C4);
  static const Color expFrom = Color(0xFFFFD24C);
  static const Color expTo = Color(0xFFC98A1A);
  static const Color dangerRed = Color(0xFFFF2E4D);

  // Hunter Ranks E -> S
  static const Color rankE = Color(0xFF8A94A6);
  static const Color rankD = Color(0xFF39D98A);
  static const Color rankC = Color(0xFF2E9BFF);
  static const Color rankB = Color(0xFFB26EFF);
  static const Color rankA = Color(0xFFFF9B3E);
  static const Color rankS = Color(0xFFFFD24C);

  static Color getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S': return rankS;
      case 'A': return rankA;
      case 'B': return rankB;
      case 'C': return rankC;
      case 'D': return rankD;
      case 'E':
      default:
        return rankE;
    }
  }
}
