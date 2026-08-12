import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/reward_chip.dart';
import '../../../../core/design_system/components/section_header.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class BossDetailScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onFocusMode;

  const BossDetailScreen({
    super.key,
    required this.onBack,
    required this.onFocusMode,
  });

  @override
  State<BossDetailScreen> createState() => _BossDetailScreenState();
}

class _BossDetailScreenState extends State<BossDetailScreen> {
  final bool _isDefeated = false;

  static const attackLog = [
    {'action': 'Completed API integration', 'dmg': -850, 'time': '2h ago', 'rank': 'A'},
    {'action': 'Wrote test suite (32 specs)', 'dmg': -400, 'time': '5h ago', 'rank': 'B'},
    {'action': 'Design handoff finalized', 'dmg': -600, 'time': '1d ago', 'rank': 'A'},
    {'action': 'Auth flow implemented', 'dmg': -700, 'time': '2d ago', 'rank': 'A'},
    {'action': 'DB schema locked', 'dmg': -950, 'time': '3d ago', 'rank': 'S'},
  ];

  @override
  Widget build(BuildContext context) {
    if (_isDefeated) {
      return Scaffold(
        backgroundColor: AppColors.voidEdge,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.expFrom.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.expFrom, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.expFrom, blurRadius: 48)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('💀', style: TextStyle(fontSize: 44)),
                ),
                const SizedBox(height: 16),
                Text('[ BOSS DEFEATED ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom, letterSpacing: 0.2)),
                const SizedBox(height: 4),
                Text('PROJECT DEFEATED', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.expFrom)),
                const SizedBox(height: 8),
                Text('SHIP THE APP has been conquered. The System acknowledges your victory.', textAlign: TextAlign.center, style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                OrnatePanel(
                  cornerSize: 24,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('[ REWARDS DISTRIBUTED ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        const RewardChip(exp: 2000, gold: 500),
                        const DiamondDivider(),
                        ...['TITLE UNLOCKED: DELIVERER', 'NEW BOSS AVAILABLE: EXPAND USERBASE', 'STAT BONUS: +3 INT, +2 PER'].map((r) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Text('> $r', style: AppTypography.monoStat(fontSize: 11, color: AppColors.terminalGreen)),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PressableCard(
                  onTap: widget.onBack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.expFrom,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x66FFD24C), blurRadius: 20)],
                    ),
                    alignment: Alignment.center,
                    child: Text('CONTINUE →', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, AriseLayoutInsets.bottomOverlayInset(context, extra: 72.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AriseBackButton(onPressed: widget.onBack),
                      Text('[ BOSS ENCOUNTER ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.rankA)),
                      const RankBadge(rank: 'A', size: RankBadgeSize.sm),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Boss Identity Card
                  OrnatePanel(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.rankA.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.rankA, width: 2),
                            boxShadow: const [BoxShadow(color: AppColors.rankA, blurRadius: 24)],
                          ),
                          alignment: Alignment.center,
                          child: const Text('⚔', style: TextStyle(fontSize: 36, color: AppColors.rankA)),
                        ),
                        const SizedBox(height: 12),
                        Text('SHIP THE APP', style: AppTypography.orbitron(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        Text('A-RANK BOSS · PROJECT', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),

                        // HP Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('HP', style: AppTypography.orbitron(fontSize: 16, color: AppColors.hpFrom)),
                            Text('6,500 / 10,000', style: AppTypography.monoStat(fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xCC000000),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.hpFrom.withValues(alpha: 0.35)),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.65,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppColors.hpFrom, AppColors.rankA]),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // Segment ticks [20, 40, 60, 80]
                            Positioned.fill(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (i) => Container(width: 1, color: Colors.black.withValues(alpha: 0.6))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0x0000', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled)),
                            Text('65% REMAINING', style: AppTypography.monoStat(fontSize: 8, color: AppColors.hpFrom)),
                            Text('MAX', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textDisabled)),
                          ],
                        ),
                        const DiamondDivider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const RewardChip(exp: 2000, gold: 500),
                            const Text('⏱ 14D 06H', style: TextStyle(color: AppColors.dangerRed, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attack Log
                  const SectionHeader(title: 'ATTACK LOG'),
                  ...attackLog.map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            RankBadge(rank: log['rank'] as String, size: RankBadgeSize.sm),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log['action'] as String, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textPrimary)),
                                  Text(log['time'] as String, style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                                ],
                              ),
                            ),
                            Text('${log['dmg']} HP', style: AppTypography.monoStat(fontSize: 12, color: AppColors.hpFrom, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Attack CTA
            Positioned(
              left: 16,
              right: 16,
              bottom: AriseLayoutInsets.bottomOverlayInset(context),
              child: PressableCard(
                onTap: widget.onFocusMode,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.rankA,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x80FF9B3E), blurRadius: 24)],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '⚔ ENTER FOCUS GATE TO DEAL DAMAGE',
                    style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
