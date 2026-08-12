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

  const PenaltyScreen({
    super.key,
    required this.onAcknowledge,
    this.missedQuest = '10KM RUN',
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
                      Text('SYSTEM ALERT — PENALTY PROTOCOL INITIATED', style: AppTypography.monoStat(fontSize: 11, color: AppColors.dangerRed)),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PENALTY QUEST ASSIGNED',
                    style: AppTypography.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dangerRed),
                  ),
                  const DiamondDivider(color: AppColors.dangerRed),
                  const SizedBox(height: 12),

                  // Missed Quest Card
                  GlassCard(
                    borderColor: AppColors.dangerRed.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FAILED QUEST', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        Text(widget.missedQuest, style: AppTypography.orbitron(fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Daily quota not met. The System does not tolerate inaction.', style: AppTypography.rajdhani(fontSize: 12, color: AppColors.dangerRed)),
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
                        Text('CONSEQUENCE ISSUED', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        _ConsequenceRow(icon: '−', label: '−150 EXP', desc: 'Immediate deduction', color: AppColors.dangerRed),
                        _ConsequenceRow(icon: '○', label: 'PENALTY QUEST', desc: '200 Squats — complete within 24H', color: AppColors.rankA),
                        _ConsequenceRow(icon: '⚡', label: 'STAT DECAY', desc: 'STR −1 if quest not cleared', color: AppColors.dangerRed),
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
                        boxShadow: const [BoxShadow(color: Color(0x66FF2E4D), blurRadius: 20)],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '[ I UNDERSTAND. I WILL NOT FAIL AGAIN. ]',
                        style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dangerRed),
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
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(color: color, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.orbitron(fontSize: 11, color: color)),
              Text(desc, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
