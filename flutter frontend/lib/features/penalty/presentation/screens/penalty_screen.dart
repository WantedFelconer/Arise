import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/pressable_card.dart';

class PenaltyScreen extends StatefulWidget {
  final VoidCallback onAcknowledge;
  final String missedQuest;
  final int xpPenalty;
  final int manaPenalty;
  final String? reason;
  final String difficultyMode;

  const PenaltyScreen({
    super.key,
    required this.onAcknowledge,
    this.missedQuest = 'FAILED OBJECTIVE',
    this.xpPenalty = 150,
    this.manaPenalty = 50,
    this.reason,
    this.difficultyMode = 'casual',
  });

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  bool _acknowledged = false;
  int _countdown = 23 * 3600 + 59 * 60 + 47;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = (_countdown ~/ 3600).toString().padLeft(2, '0');
    final mm = ((_countdown % 3600) ~/ 60).toString().padLeft(2, '0');
    final ss = (_countdown % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF1A0008),
      body: Stack(
        children: [
          // Red Vignette
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Color(0x00FF2E4D), Color(0x40FF2E4D)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM ALERT — PENALTY PROTOCOL INITIATED [${widget.difficultyMode.toUpperCase()} MODE]',
                        style: AppTypography.monoStat(fontSize: 10, color: AppColors.dangerRed),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PENALTY ASSIGNED',
                    style: AppTypography.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dangerRed),
                  ),
                  const DiamondDivider(color: AppColors.dangerRed),
                  const SizedBox(height: 12),

                  // Missed Quest / Gate Card
                  GlassCard(
                    borderColor: AppColors.dangerRed.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FAILED OBJECTIVE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        Text(widget.missedQuest, style: AppTypography.orbitron(fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          widget.reason ?? 'Daily quota or Gate expedition collapsed. The System does not tolerate inaction.',
                          style: AppTypography.rajdhani(fontSize: 12, color: AppColors.dangerRed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Consequence Card
                  GlassCard(
                    borderColor: AppColors.dangerRed.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONSEQUENCES APPLIED', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        _ConsequenceRow(icon: '−', label: '−${widget.xpPenalty} EXP', desc: 'Progression ledger penalty', color: AppColors.dangerRed),
                        _ConsequenceRow(icon: '⚡', label: '−${widget.manaPenalty} MANA', desc: 'Mental exhaustion penalty', color: AppColors.dangerRed),
                        if (widget.difficultyMode == 'hardcore')
                          const _ConsequenceRow(icon: '💀', label: 'BOSS RECOVERY', desc: '+15% Boss HP regeneration triggered', color: AppColors.rankA)
                        else
                          const _ConsequenceRow(icon: '○', label: 'RECOVERY QUEST', desc: 'Complete 1 quest to restore stability', color: AppColors.rankA),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('TIME REMAINING TO CLEAR PENALTY', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                  Text('$hh:$mm:$ss', style: AppTypography.monoStat(fontSize: 36, color: AppColors.dangerRed)),
                  const SizedBox(height: 16),

                  Text(
                    '"There is no room for excuses."\n— THE SYSTEM',
                    textAlign: TextAlign.center,
                    style: AppTypography.orbitron(fontSize: 11, color: AppColors.textDisabled, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  PressableCard(
                    onTap: _acknowledged
                        ? null
                        : () {
                            setState(() => _acknowledged = true);
                            Timer(const Duration(milliseconds: 300), widget.onAcknowledge);
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dangerRed),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _acknowledged ? 'ACKNOWLEDGED' : 'ACCEPT PENALTY PROTOCOL',
                        style: AppTypography.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dangerRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  final String icon;
  final String label;
  final String desc;
  final Color color;

  const _ConsequenceRow({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 20,
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                Text(desc, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
