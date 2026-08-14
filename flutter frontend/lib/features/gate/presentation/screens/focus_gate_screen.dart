import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/particle_field.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/providers/quest_provider.dart';
import '../providers/gate_provider.dart';

class FocusGateScreen extends ConsumerStatefulWidget {
  final ValueChanged<bool> onExit;

  const FocusGateScreen({super.key, required this.onExit});

  @override
  ConsumerState<FocusGateScreen> createState() => _FocusGateScreenState();
}

class _FocusGateScreenState extends ConsumerState<FocusGateScreen>
    with TickerProviderStateMixin {
  int _targetSeconds = 25 * 60;
  String? _selectedQuestId;
  bool _showExitWarning = false;

  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -5), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: -4), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -4, end: 4), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 4, end: -2), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -2, end: 2), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 2, end: 0), weight: 10),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerCollapse() {
    setState(() {
      _showExitWarning = false;
    });
    ref.read(gateNotifierProvider.notifier).collapseSession(exitReason: 'user_fled');
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final gateState = ref.watch(gateNotifierProvider);
    final questState = ref.watch(questNotifierProvider);

    if (gateState.isCleared) {
      return _buildVictoryView(gateState);
    }
    if (gateState.isCollapsed) {
      return _buildCollapseView(gateState);
    }

    final isRunning = gateState.isRunning;
    final isPaused = gateState.isPaused;
    final seconds = isRunning || isPaused
        ? gateState.secondsRemaining
        : _targetSeconds;
    final totalPlanned = isRunning || isPaused
        ? (gateState.activeSession?.plannedDurationS ?? _targetSeconds)
        : _targetSeconds;
    final pct = (seconds / totalPlanned).clamp(0.0, 1.0);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final stability = gateState.stabilityPct.round();

    final activeQuests = questState.quests.where((q) => !q.done).toList();
    final linkedQuest = _selectedQuestId != null
        ? activeQuests.where((q) => q.id == _selectedQuestId).firstOrNull
        : null;

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Stack(
        children: [
          // 1. Ambient Floating Particles Layer
          const Positioned.fill(child: ParticleField(count: 16)),

          // 2. Foreground Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '[ GATE ENTRY — FOCUS MODE ]',
                                style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled),
                              ),
                              if (gateState.activeSession?.syncStatus == 'pending') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningAmber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text('OFFLINE BUFFER', style: AppTypography.monoStat(fontSize: 7, color: AppColors.warningAmber)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            linkedQuest != null
                                ? linkedQuest.title.toUpperCase()
                                : 'DEEP WORK EXPEDITION',
                            style: AppTypography.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      AriseBackButton(
                        onPressed: () {
                          if (isRunning || isPaused) {
                            setState(() => _showExitWarning = true);
                          } else {
                            widget.onExit(false);
                          }
                        },
                        label: isRunning || isPaused ? 'ABANDON' : 'EXIT',
                        showArrow: false,
                      ),
                    ],
                  ),
                ),

                // Stability indicator banner when active
                if (isRunning || isPaused)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.manaCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GATE STABILITY', style: AppTypography.monoStat(fontSize: 9, color: AppColors.manaCyan)),
                        Text('$stability% / 100%', style: AppTypography.monoStat(fontSize: 9, color: AppColors.terminalGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                // Error / warning banner
                if (gateState.error != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.dangerRed),
                    ),
                    child: Row(
                      children: [
                        const Text('⚠ ', style: TextStyle(color: AppColors.dangerRed, fontSize: 12)),
                        Expanded(
                          child: Text(
                            gateState.error!,
                            style: AppTypography.rajdhani(fontSize: 12, color: AppColors.dangerRed),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Portal visual + timer
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 3 Alternating Rotating Portal Rings
                            const _RotatingPortalRings(),

                            // Progress ring & center glow
                            AnimatedBuilder(
                              animation: _breatheAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _breatheAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Color(0x333EE6F5),
                                              Color(0x053EE6F5),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(color: Color(0x4D3EE6F5), blurRadius: 40),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 260,
                                        height: 260,
                                        child: CustomPaint(
                                          painter: _PortalTimerPainter(pct: pct),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$mm:$ss',
                                  style: AppTypography.monoStat(
                                    fontSize: 52,
                                    color: isPaused ? AppColors.warningAmber : AppColors.textPrimary,
                                    letterSpacing: 0.05,
                                  ).copyWith(
                                    shadows: [
                                      Shadow(
                                        color: isPaused
                                            ? const Color(0x80FFB703)
                                            : const Color(0x803EE6F5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPaused
                                      ? 'GATE PAUSED'
                                      : (isRunning ? 'INSIDE THE GATE' : 'READY TO ENTER'),
                                  style: AppTypography.orbitron(
                                    fontSize: 9,
                                    color: isPaused ? AppColors.warningAmber : AppColors.textSecondary,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        isRunning || isPaused
                            ? '[ Gate Stability rising uninterrupted.\nExiting early collapses the Gate. ]'
                            : '[ Select focus duration & enter the Gate.\nMaintain focus to stabilize the barrier. ]',
                        textAlign: TextAlign.center,
                        style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled, height: 1.6),
                      ),
                    ],
                  ),
                ),

                // Controls Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      if (!isRunning && !isPaused) ...[
                        // Linked Quest Selection
                        if (activeQuests.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.voidEdge,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0D131F),
                                value: _selectedQuestId,
                                hint: Text('LINK FOCUS TO A QUEST (OPTIONAL)', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('NO LINKED QUEST (FREE FOCUS)', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textPrimary)),
                                  ),
                                  ...activeQuests.map((q) => DropdownMenuItem<String?>(
                                        value: q.id,
                                        child: Text(q.title, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.manaCyan), overflow: TextOverflow.ellipsis),
                                      )),
                                ],
                                onChanged: (val) => setState(() => _selectedQuestId = val),
                              ),
                            ),
                          ),

                        // Duration selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [15, 25, 45, 60].map((min) {
                            final isSel = _targetSeconds == min * 60;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: PressableCard(
                                onTap: () => setState(() {
                                  _targetSeconds = min * 60;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.manaCyan.withValues(alpha: 0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSel
                                          ? AppColors.manaCyan.withValues(alpha: 0.5)
                                          : AppColors.manaCyan.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Text(
                                    '${min}M',
                                    style: AppTypography.orbitron(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? AppColors.manaCyan : AppColors.textDisabled,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // CTA Buttons
                      if (!isRunning && !isPaused)
                        PressableCard(
                          onTap: () {
                            ref.read(gateNotifierProvider.notifier).startSession(
                                  questId: _selectedQuestId,
                                  durationSeconds: _targetSeconds,
                                );
                          },
                          pressedScale: 0.96,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.manaCyan,
                              gradient: const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)]),
                              boxShadow: const [
                                BoxShadow(color: Color(0x663EE6F5), blurRadius: 24),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '⚡ ENTER THE GATE',
                              style: AppTypography.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.12,
                              ),
                            ),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            if (isPaused)
                              Expanded(
                                child: PressableCard(
                                  onTap: () => ref.read(gateNotifierProvider.notifier).resumeSession(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.manaCyan),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('▶ RESUME', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: PressableCard(
                                  onTap: () => ref.read(gateNotifierProvider.notifier).pauseSession(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0x1AFFB703),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0x66FFB703)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('⏸ PAUSE', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warningAmber)),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PressableCard(
                                onTap: () => setState(() => _showExitWarning = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1AFF2E4D),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0x66FF2E4D)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('✕ ABANDON', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exit Warning Overlay Modal
          if (_showExitWarning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: GlassCard(
                      borderColor: AppColors.dangerRed.withValues(alpha: 0.4),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⚠ ABANDON GATE?',
                            style: AppTypography.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dangerRed,
                              letterSpacing: 0.12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '[ Exiting now collapses the Gate immediately.\nPenalty Protocol will deduct XP & Mana.\nHardcore Mode triggers Boss HP recovery. ]',
                            textAlign: TextAlign.center,
                            style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: PressableCard(
                                  onTap: () => setState(() => _showExitWarning = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('STAY IN GATE', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PressableCard(
                                  onTap: _triggerCollapse,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.4)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('COLLAPSE GATE', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVictoryView(GateState gateState) {
    final cascade = gateState.lastCascadeResult;
    final xpAward = (cascade?['xpDelta'] as num?)?.toInt() ?? 200;
    final manaReward = (cascade?['manaDelta'] as num?)?.toInt() ?? 10;
    final bossDamage = (cascade?['bossDamage'] as num?)?.toInt();

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('[ GATE CLEARED — 100% STABILITY ]', style: AppTypography.monoStat(fontSize: 11, color: AppColors.terminalGreen)),
              const SizedBox(height: 4),
              Text(
                'VICTORY',
                style: AppTypography.orbitron(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.manaCyan).copyWith(
                  shadows: const [Shadow(color: Color(0xCC3EE6F5), blurRadius: 40)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expedition complete. Focus sustained without interruption.\nAuthoritative rewards queued for ledger verification.',
                textAlign: TextAlign.center,
                style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              GlassCard(
                borderColor: AppColors.terminalGreen.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Text('+$xpAward EXP · Gate Clear Reward', style: AppTypography.monoStat(fontSize: 12, color: AppColors.terminalGreen)),
                    const SizedBox(height: 4),
                    Text('+$manaReward MANA · Focus Restoration', style: AppTypography.monoStat(fontSize: 12, color: AppColors.manaCyan)),
                    if (bossDamage != null && bossDamage > 0) ...[
                      const SizedBox(height: 4),
                      Text('-$bossDamage BOSS HP · Linked Quest Strike', style: AppTypography.monoStat(fontSize: 12, color: AppColors.rankA)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PressableCard(
                onTap: () => widget.onExit(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)]),
                  ),
                  child: Text('RETURN TO BASE', style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseView(GateState gateState) {
    final penalty = gateState.lastPenaltyResult;
    final xpLoss = (penalty?['xpPenalty'] as num?)?.toInt() ?? 50;
    final manaLoss = (penalty?['manaPenalty'] as num?)?.toInt() ?? 20;

    return Scaffold(
      backgroundColor: const Color(0xF8030712),
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _RedOrbitalRings(),
                const SizedBox(height: 24),

                Text(
                  'THE GATE HAS\nCOLLAPSED',
                  textAlign: TextAlign.center,
                  style: AppTypography.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dangerRed,
                    letterSpacing: 0.08,
                  ).copyWith(
                    shadows: const [Shadow(color: Color(0xCCFF2E4D), blurRadius: 30)],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '[ Focus was severed before full stabilization. ]\nThe System has applied the Penalty Protocol.',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  borderColor: AppColors.dangerRed.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '−$xpLoss EXP · Gate Abandoned\n−$manaLoss MANA · Mental Energy Depletion\nPENALTY PROTOCOL INITIATED',
                    textAlign: TextAlign.center,
                    style: AppTypography.monoStat(fontSize: 11, color: AppColors.dangerRed, height: 1.6),
                  ),
                ),
                const SizedBox(height: 28),
                PressableCard(
                  onTap: () => widget.onExit(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.4)),
                    ),
                    child: Text('ACKNOWLEDGE FAILURE', style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 Alternating Rotating Portal Rings around active Gate timer circle
class _RotatingPortalRings extends StatefulWidget {
  const _RotatingPortalRings();

  @override
  State<_RotatingPortalRings> createState() => _RotatingPortalRingsState();
}

class _RotatingPortalRingsState extends State<_RotatingPortalRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final List<Widget> _staticRings;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    const sizes = [200.0, 230.0, 250.0];
    _staticRings = sizes.asMap().entries.map((entry) {
      final idx = entry.key;
      final size = entry.value;
      final strokeWidth = 2.0 - idx * 0.5;
      final opacity = (0.30 - idx * 0.08).clamp(0.05, 1.0);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.manaCyan.withValues(alpha: opacity),
            width: strokeWidth,
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: _staticRings.asMap().entries.map((entry) {
            final idx = entry.key;
            final speedMultiplier = 1.0 + idx * 0.5;
            final angle =
                val * 2 * math.pi * speedMultiplier * (idx % 2 == 0 ? 1 : -1);

            return Transform.rotate(
              angle: angle,
              child: entry.value,
            );
          }).toList(),
        );
      },
    );
  }
}

/// 3 Continuous Rotating Red Orbital Rings on Gate Collapse Screen
class _RedOrbitalRings extends StatefulWidget {
  const _RedOrbitalRings();

  @override
  State<_RedOrbitalRings> createState() => _RedOrbitalRingsState();
}

class _RedOrbitalRingsState extends State<_RedOrbitalRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final List<Widget> _staticRedRings;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    const sizes = [80.0, 100.0, 120.0];
    _staticRedRings = sizes.map((size) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.dangerRed.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: _staticRedRings.asMap().entries.map((entry) {
            final idx = entry.key;
            final angle = val * 2 * math.pi * (idx % 2 == 0 ? 1 : -1);
            return Transform.rotate(
              angle: angle,
              child: entry.value,
            );
          }).toList(),
        );
      },
    );
  }
}

class _PortalTimerPainter extends CustomPainter {
  final double pct;

  _PortalTimerPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0x1A3EE6F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final sweepAngle = 2 * math.pi * pct;
    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PortalTimerPainter oldDelegate) =>
      oldDelegate.pct != pct;
}
