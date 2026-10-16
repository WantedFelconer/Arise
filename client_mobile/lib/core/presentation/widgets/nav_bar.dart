import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Diffuse Ambient Gradient Scrim (simulates light refraction of objects behind glass)
          IgnorePointer(
            child: Container(
              height: 18,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x55030712),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Floating Frosted Capsule
          Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset > 0 ? bottomInset + 2 : 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Pseudo-Blur Smoked Glass Gradient with angled specular refraction
                gradient: const LinearGradient(
                  begin: Alignment(-0.8, -1.0),
                  end: Alignment(0.8, 1.0),
                  colors: [
                    Color(0xF20D1B2E), // Top-left high refraction specular tone
                    Color(0xEB060D1A), // Deep smoked core
                    Color(0xF0081426), // Mid-reflection
                    Color(0xFA030712), // Deep base void
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
                // Multi-stop optical diffusion shadows
                boxShadow: const [
                  // Deep occlusion drop shadow
                  BoxShadow(
                    color: Color(0xD9000000),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                  // Ambient scatter shadow
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                  // Chromatic cyan rim scatter glow
                  BoxShadow(
                    color: Color(0x243EE6F5),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: Offset(0, 0),
                  ),
                ],
                // Top-lit frosted bevel border
                border: Border.all(
                  color: const Color(0x403EE6F5), // 25% cyan edge highlight
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Specular Top Rim Light Bar (1px hairline highlight)
                    Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      height: 1.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0x803EE6F5),
                              Color(0xB3FFFFFF),
                              Color(0x803EE6F5),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Navigation Items Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: items.map((item) {
                          final isActive = activeTab == item.id;
                          final color = isActive ? AppColors.manaCyan : AppColors.textDisabled;

                          return Expanded(
                            child: PressableCard(
                              onTap: () => onNavigate(item.id),
                              pressedScale: 0.92,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  // Active Tab Inner Radiant Capsule
                                  color: isActive
                                      ? AppColors.manaCyan.withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.manaCyan.withValues(alpha: 0.45)
                                        : Colors.transparent,
                                    width: 0.8,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.manaCyan.withValues(alpha: 0.25),
                                            blurRadius: 10,
                                            spreadRadius: -1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Top Micro Indicator (Glowing Pip for active tab)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 2.0,
                                      width: isActive ? 16.0 : 0.0,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.manaCyan,
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: isActive
                                            ? const [
                                                BoxShadow(
                                                  color: AppColors.manaCyan,
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),

                                    // Icon with dynamic glow on active
                                    Icon(
                                      item.icon,
                                      size: 20,
                                      color: color,
                                      shadows: isActive
                                          ? [
                                              const Shadow(
                                                color: Color(0x993EE6F5),
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    const SizedBox(height: 3),

                                    // Label with HUD letterSpacing
                                    Text(
                                      item.label,
                                      style: AppTypography.orbitron(
                                        fontSize: 8,
                                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                        color: color,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
