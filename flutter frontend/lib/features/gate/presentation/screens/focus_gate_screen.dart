import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/particle_field.dart';
import '../../../../core/design_system/components/pressable_card.dart';

class FocusGateScreen extends StatefulWidget {
  final ValueChanged<bool> onExit;

  const FocusGateScreen({super.key, required this.onExit});

  @override
  State<FocusGateScreen> createState() => _FocusGateScreenState();
}

class _FocusGateScreenState extends State<FocusGateScreen> with TickerProviderStateMixin {
  late final ValueNotifier<int> _secondsNotifier = ValueNotifier<int>(25 * 60);
  int _targetSeconds = 25 * 60;
  bool _running = false;
  bool _collapsed = false;
  bool _showExitWarning = false;
  bool _sessionDone = false;
  Timer? _timer;

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
    _timer?.cancel();
    _secondsNotifier.dispose();
    _breatheController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _running = !_running;
      if (_running) {
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (_secondsNotifier.value > 0) {
            _secondsNotifier.value--;
          } else {
            t.cancel();
            if (mounted) {
              setState(() {
                _running = false;
                _sessionDone = true;
              });
            }
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _triggerCollapse() {
    setState(() {
      _showExitWarning = false;
      _collapsed = true;
    });
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionDone) {
      return _buildVictoryView();
    }
    if (_collapsed) {
      return _buildCollapseView();
    }

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Stack(
        children: [
          // 1. Ambient Floating Particles Layer (Always visible behind controls)
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
                          Text('[ GATE ENTRY — FOCUS MODE ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                          const SizedBox(height: 2),
                          Text('DEEP WORK SESSION', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      AriseBackButton(
                        onPressed: () => setState(() => _showExitWarning = true),
                        label: 'EXIT',
                        showArrow: false,
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
                            ValueListenableBuilder<int>(
                              valueListenable: _secondsNotifier,
                              builder: (context, seconds, child) {
                                final pct = seconds / _targetSeconds;
                                final mm = (seconds ~/ 60).toString().padLeft(2, '0');
                                final ss = (seconds % 60).toString().padLeft(2, '0');

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
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
                                            color: AppColors.textPrimary,
                                            letterSpacing: 0.05,
                                          ).copyWith(
                                            shadows: const [
                                              Shadow(color: Color(0x803EE6F5), blurRadius: 20),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _running ? 'INSIDE THE GATE' : 'READY TO ENTER',
                                          style: AppTypography.orbitron(fontSize: 9, color: AppColors.textSecondary, letterSpacing: 0.12),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '[ Leaving the Gate before clearing it\nwill trigger a Penalty. ]',
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
                      if (!_running) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [15, 25, 45, 60].map((min) {
                            final isSel = _secondsNotifier.value == min * 60;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: PressableCard(
                                onTap: () => setState(() {
                                  _targetSeconds = min * 60;
                                  _secondsNotifier.value = min * 60;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.manaCyan.withValues(alpha: 0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSel ? AppColors.manaCyan.withValues(alpha: 0.5) : AppColors.manaCyan.withValues(alpha: 0.1)),
                                  ),
                                  child: Text('${min}M', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? AppColors.manaCyan : AppColors.textDisabled)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Translucent Pause / Active Start CTA (Particle drift remains visible through button)
                      PressableCard(
                        onTap: _toggleTimer,
                        pressedScale: 0.96,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            // Translucent dark red background when running (10% opacity)
                            color: _running ? const Color(0x1AFF2E4D) : AppColors.manaCyan,
                            border: _running ? Border.all(color: const Color(0x66FF2E4D)) : null,
                            gradient: _running ? null : const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)]),
                            boxShadow: [
                              BoxShadow(
                                color: _running ? const Color(0x33FF2E4D) : const Color(0x663EE6F5),
                                blurRadius: _running ? 16 : 24,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _running ? '⏸ PAUSE SESSION' : '⚡ ENTER THE GATE',
                            style: AppTypography.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _running ? AppColors.dangerRed : Colors.black,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ),
                      ),
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
                          Text('⚠ ABANDON GATE?', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.dangerRed, letterSpacing: 0.12)),
                          const SizedBox(height: 12),
                          Text(
                            '[ Exiting now will trigger the Penalty Protocol.\nYour streak will be compromised.\nThe System does not forgive. ]',
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
                                    child: Text('CONTINUE', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
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
                                    child: Text('FLEE', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
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

  Widget _buildVictoryView() {
    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('[ GATE CLEARED ]', style: AppTypography.monoStat(fontSize: 11, color: AppColors.terminalGreen)),
              const SizedBox(height: 4),
              Text(
                'VICTORY',
                style: AppTypography.orbitron(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.manaCyan).copyWith(
                  shadows: const [Shadow(color: Color(0xCC3EE6F5), blurRadius: 40)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have returned from the Gate.\nThe System has recorded your effort.',
                textAlign: TextAlign.center,
                style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              GlassCard(
                borderColor: AppColors.terminalGreen.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('+200 EXP · Gate Complete', style: AppTypography.monoStat(fontSize: 12, color: AppColors.terminalGreen)),
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

  Widget _buildCollapseView() {
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
                // Gate collapse 3 red rotating orbital rings visual
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
                  '[ You abandoned the Gate before clearing it. ]\nThe System has registered your failure.',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  borderColor: AppColors.dangerRed.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '−150 EXP · Gate Abandoned\nSTREAK RESET TO 0\nPENALTY QUEST ASSIGNED',
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

class _RotatingPortalRingsState extends State<_RotatingPortalRings> with SingleTickerProviderStateMixin {
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
            final angle = val * 2 * math.pi * speedMultiplier * (idx % 2 == 0 ? 1 : -1);

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

class _RedOrbitalRingsState extends State<_RedOrbitalRings> with SingleTickerProviderStateMixin {
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
            color: AppColors.dangerRed.withValues(alpha: 0.4),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80FF2E4D),
              blurRadius: 6,
            ),
          ],
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
    return SizedBox(
      width: 128,
      height: 128,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final val = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              ..._staticRedRings.asMap().entries.map((entry) {
                final idx = entry.key;
                final speedMultiplier = 1.0 + idx * 0.33;
                final angle = val * 2 * math.pi * speedMultiplier * (idx % 2 == 0 ? 1 : -1);

                return Transform.rotate(
                  angle: angle,
                  child: entry.value,
                );
              }),
              Text(
                '⬡',
                style: AppTypography.orbitron(
                  fontSize: 32,
                  color: AppColors.dangerRed,
                ).copyWith(
                  shadows: const [
                    Shadow(color: Color(0x80FF2E4D), blurRadius: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PortalTimerPainter extends CustomPainter {
  final double pct;

  _PortalTimerPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.manaCyan.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      Paint()
        ..color = AppColors.manaCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PortalTimerPainter oldDelegate) => oldDelegate.pct != pct;
}
