import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../design_system/components/glass_card.dart';

import '../../design_system/components/pressable_card.dart';

class NavBarItemData {
  final String id;
  final String label;
  final IconData icon;

  const NavBarItemData({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class NavBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onNavigate;

  static const items = [
    NavBarItemData(id: 'home', label: 'HOME', icon: Icons.home_outlined),
    NavBarItemData(id: 'quests', label: 'QUESTS', icon: Icons.description_outlined),
    NavBarItemData(id: 'status', label: 'STATUS', icon: Icons.shield_outlined),
    NavBarItemData(id: 'journal', label: 'JOURNAL', icon: Icons.menu_book_outlined),
    NavBarItemData(id: 'roadmap', label: 'ROADMAP', icon: Icons.alt_route_outlined),
  ];

  const NavBar({
    super.key,
    required this.activeTab,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: GlassCard(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            borderColor: const Color(0x383EE6F5),
            boxShadow: const BoxShadow(
              color: Color(0x80000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((item) {
                final isActive = activeTab == item.id;
                final color = isActive ? AppColors.manaCyan : AppColors.textDisabled;

                return PressableCard(
                  onTap: () => onNavigate(item.id),
                  pressedScale: 0.90,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.manaCyan.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 20, color: color),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTypography.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

