import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_popup_window.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';

class LevelUpScreen extends StatefulWidget {
  final int oldLevel;
  final int newLevel;
  final int newPoints;
  final VoidCallback onContinue;

  const LevelUpScreen({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    this.newPoints = 5,
    required this.onContinue,
  });

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen> {
  String _phase = 'flash';

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _phase = 'reveal');
    });
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _phase = 'done');
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedSkill = widget.newLevel % 5 == 0 ? 'SHADOW STEP LV.1' : null;
    final unlockedTitle = widget.newLevel == 15 ? 'IRON WILL' : null;

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Stack(
        children: [
          if (_phase == 'flash')
            Container(color: AppColors.manaCyan.withValues(alpha: 0.3)),

          if (_phase != 'flash')
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ArisePopupWindow(
                  showBackdrop: false,
                  child: OrnatePanel(
                    cornerSize: 32,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('[ SYSTEM NOTIFICATION ]', style: AppTypography.monoStat(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          'LEVEL UP!',
                          style: AppTypography.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.manaCyan,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const DiamondDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('${widget.oldLevel}', style: AppTypography.orbitron(fontSize: 36, color: AppColors.textDisabled)),
                                Text('PREVIOUS', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Text('→', style: AppTypography.orbitron(fontSize: 22, color: AppColors.manaCyan)),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                Text('${widget.newLevel}', style: AppTypography.orbitron(fontSize: 52, fontWeight: FontWeight.w900, color: AppColors.expFrom)),
                                Text('NEW LEVEL', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                              ],
                            ),
                          ],
                        ),
                        const DiamondDivider(),

                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text('STAT POINTS AWARDED', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('+${widget.newPoints} POINTS', style: AppTypography.orbitron(fontSize: 22, color: AppColors.manaCyan)),
                              Text('Allocate via STATUS screen', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (unlockedSkill != null)
                          GlassCard(
                            borderColor: AppColors.rankB,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text('NEW SKILL UNLOCKED', style: AppTypography.monoStat(fontSize: 9, color: AppColors.rankB)),
                                Text('⚡ $unlockedSkill', style: AppTypography.orbitron(fontSize: 13, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),

                        if (unlockedTitle != null)
                          GlassCard(
                            borderColor: AppColors.expFrom,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text('TITLE UNLOCKED', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
                                Text('◆ $unlockedTitle', style: AppTypography.orbitron(fontSize: 13, color: AppColors.expFrom)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        if (_phase == 'done')
                          PressableCard(
                            onTap: widget.onContinue,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.manaCyan,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 20)],
                              ),
                              alignment: Alignment.center,
                              child: Text('CONTINUE', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
