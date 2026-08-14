import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/decrypt_text.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/particle_field.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/scanline_sweep.dart';
import '../../../../core/design_system/components/terminal_readout.dart';
import '../../../../core/design_system/components/uplink_chip.dart';
import '../../application/auth_notifier.dart';

enum AuthSubScreen { login, register, recovery, verifying }

class AuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const AuthScreen({super.key, required this.onComplete});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthSubScreen _screen = AuthSubScreen.login;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  static const bootLines = [
    TerminalLineItem(text: 'ARISE SYSTEM v2.0 — INITIALIZING...', status: 'INIT'),
    TerminalLineItem(text: 'Scanning dimensional frequency...', status: '...'),
    TerminalLineItem(text: 'Hunter database: ONLINE', status: 'OK'),
    TerminalLineItem(text: 'Uplink established', status: 'SYNC'),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter hunter email and access code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _screen = AuthSubScreen.verifying;
    });

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: email,
          password: password,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onComplete();
      } else {
        setState(() => _screen = AuthSubScreen.login);
      }
    }
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _screen = AuthSubScreen.verifying;
    });

    final success = await ref.read(authNotifierProvider.notifier).signup(
          email: email,
          password: password,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onComplete();
      } else {
        setState(() => _screen = AuthSubScreen.register);
      }
    }
  }

  Future<void> _handleRecovery() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter registered hunter frequency')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _screen = AuthSubScreen.verifying;
    });

    final success = await ref.read(authNotifierProvider.notifier).requestPasswordReset(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        await Future.delayed(const Duration(milliseconds: 1600));
        if (mounted) setState(() => _screen = AuthSubScreen.login);
      } else {
        setState(() => _screen = AuthSubScreen.recovery);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    if (_screen == AuthSubScreen.verifying) {
      return _VerifyingScreen(
        isRecovery: !_isLoading && authState.successMessage != null,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x143EE6F5), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const UplinkChip(stable: true),
                  const SizedBox(height: 12),
                  Text(
                    'ARISE',
                    style: AppTypography.orbitron(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HUNTER SYSTEM v2.0',
                    style: AppTypography.monoStat(
                      fontSize: 10,
                      color: AppColors.manaCyan,
                      letterSpacing: 0.18,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Boot terminal
                  const GlassCard(
                    padding: EdgeInsets.all(12),
                    child: TerminalReadout(lines: bootLines),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Error/Status Banner
                  if (authState.errorMessage != null) ...[
                    _SystemAlertBanner(
                      message: authState.errorMessage!,
                      isError: true,
                      details: authState.validationErrors,
                      onDismiss: () => ref.read(authNotifierProvider.notifier).clearError(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (authState.successMessage != null) ...[
                    _SystemAlertBanner(
                      message: authState.successMessage!,
                      isError: false,
                      onDismiss: () => ref.read(authNotifierProvider.notifier).clearError(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_screen == AuthSubScreen.login)
                    _LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onLogin: _handleLogin,
                      onGoRegister: () {
                        ref.read(authNotifierProvider.notifier).clearError();
                        setState(() => _screen = AuthSubScreen.register);
                      },
                      onGoRecovery: () {
                        ref.read(authNotifierProvider.notifier).clearError();
                        setState(() => _screen = AuthSubScreen.recovery);
                      },
                    ),

                  if (_screen == AuthSubScreen.register)
                    _RegisterForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      nameController: _nameController,
                      onRegister: _handleRegister,
                      onGoLogin: () {
                        ref.read(authNotifierProvider.notifier).clearError();
                        setState(() => _screen = AuthSubScreen.login);
                      },
                    ),

                  if (_screen == AuthSubScreen.recovery)
                    _RecoveryForm(
                      emailController: _emailController,
                      onSend: _handleRecovery,
                      onGoLogin: () {
                        ref.read(authNotifierProvider.notifier).clearError();
                        setState(() => _screen = AuthSubScreen.login);
                      },
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

class _SystemAlertBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final List<String>? details;
  final VoidCallback onDismiss;

  const _SystemAlertBanner({
    required this.message,
    required this.isError,
    this.details,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.dangerRed : AppColors.terminalGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isError ? '⚠ SYSTEM WARNING' : '◈ SYSTEM TRANSMISSION',
                style: AppTypography.monoStat(fontSize: 10, color: color),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.rajdhani(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...details!.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  '> $d',
                  style: AppTypography.monoStat(fontSize: 10, color: color),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onGoRegister;
  final VoidCallback onGoRecovery;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onGoRegister,
    required this.onGoRecovery,
  });

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      cornerSize: 28,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '[ AUTHENTICATION PROTOCOL ]',
                  style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'ESTABLISH UPLINK',
                  style: AppTypography.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Input fields
          _TerminalInput(
            label: '> HUNTER ID (EMAIL)',
            controller: emailController,
            hintText: 'hunter@arise.sys',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _TerminalInput(
            label: '> ACCESS CODE',
            controller: passwordController,
            hintText: '••••••••',
            obscureText: true,
          ),
          const SizedBox(height: 16),

          PressableCard(
            onTap: onLogin,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.manaCyan,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 16)],
              ),
              alignment: Alignment.center,
              child: Text(
                '[ INITIATE UPLINK ]',
                style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ),
          ),

          const DiamondDivider(),

          _SSOButton(
            icon: 'G',
            label: 'CONTINUE VIA GOOGLE NETWORK',
            onTap: () {
              emailController.text = 'hunter@arise.sys';
              passwordController.text = 'Password123!';
              onLogin();
            },
          ),
          const SizedBox(height: 8),
          _SSOButton(
            icon: '⬡',
            label: 'CONTINUE VIA APPLE NEXUS',
            onTap: () {
              emailController.text = 'hunter@arise.sys';
              passwordController.text = 'Password123!';
              onLogin();
            },
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArisePressable(
                onTap: onGoRecovery,
                child: Text(
                  'UPLINK LOST?',
                  style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled),
                ),
              ),
              ArisePressable(
                onTap: onGoRegister,
                child: Text(
                  'NEW HUNTER →',
                  style: AppTypography.monoStat(fontSize: 10, color: AppColors.manaCyan),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final VoidCallback onRegister;
  final VoidCallback onGoLogin;

  const _RegisterForm({
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.onRegister,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      cornerSize: 28,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '[ NEW ENTITY DETECTED ]',
                  style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'REGISTER HUNTER',
                  style: AppTypography.orbitron(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your title awaits. Begin the awakening.',
                  style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _TerminalInput(
            label: '> HUNTER DESIGNATION',
            controller: nameController,
            hintText: 'SHADOW MONARCH',
            isCyan: true,
          ),
          const SizedBox(height: 12),
          _TerminalInput(
            label: '> UPLINK ADDRESS (EMAIL)',
            controller: emailController,
            hintText: 'hunter@arise.sys',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _TerminalInput(
            label: '> ENCRYPTION KEY (PASSWORD)',
            controller: passwordController,
            hintText: 'min 8 characters',
            obscureText: true,
          ),
          const SizedBox(height: 16),

          PressableCard(
            onTap: onRegister,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.terminalGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Color(0x6639FF88), blurRadius: 16)],
              ),
              alignment: Alignment.center,
              child: Text(
                '[ INITIALIZE AWAKENING ]',
                style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ArisePressable(
            onTap: onGoLogin,
            child: Center(
              child: Text(
                '← RETURNING HUNTER',
                style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryForm extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSend;
  final VoidCallback onGoLogin;

  const _RecoveryForm({
    required this.emailController,
    required this.onSend,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      cornerSize: 28,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '[ UPLINK SEVERED ]',
                  style: AppTypography.monoStat(fontSize: 9, color: AppColors.rankA),
                ),
                const SizedBox(height: 4),
                Text(
                  'UPLINK LOST?',
                  style: AppTypography.orbitron(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Transmit your registered frequency. The System will reestablish contact.',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _TerminalInput(
            label: '> REGISTERED FREQUENCY (EMAIL)',
            controller: emailController,
            hintText: 'hunter@arise.sys',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          PressableCard(
            onTap: onSend,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.rankA.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.rankA),
              ),
              alignment: Alignment.center,
              child: Text(
                '[ TRANSMIT RECOVERY SIGNAL ]',
                style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.rankA),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ArisePressable(
            onTap: onGoLogin,
            child: Center(
              child: Text(
                '← ABORT — RETURN TO UPLINK',
                style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isCyan;
  final TextInputType? keyboardType;

  const _TerminalInput({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.isCyan = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.monoStat(fontSize: 10, color: AppColors.terminalGreen.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: isCyan
              ? AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
              : AppTypography.monoStat(fontSize: 13, color: AppColors.terminalGreen),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isCyan ? AppColors.manaCyan.withValues(alpha: 0.25) : AppColors.terminalGreen.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: isCyan ? const Color(0xCC0A1A3A) : const Color(0x80000000),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isCyan ? AppColors.manaCyan.withValues(alpha: 0.35) : AppColors.terminalGreen.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isCyan ? AppColors.manaCyan : AppColors.terminalGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SSOButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SSOButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(icon, style: AppTypography.orbitron(fontSize: 16, color: AppColors.manaCyan)),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.orbitron(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VerifyingScreen extends StatefulWidget {
  final bool isRecovery;

  const _VerifyingScreen({required this.isRecovery});

  @override
  State<_VerifyingScreen> createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<_VerifyingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheScale;
  late Animation<double> _breatheOpacity;

  int _visibleLines = 0;
  Timer? _timer1;
  Timer? _timer2;
  Timer? _timer3;

  static const _allLines = [
    TerminalLineItem(text: 'Verifying hunter credentials...', status: '...'),
    TerminalLineItem(text: 'Cross-referencing Hunter registry...', status: '...'),
    TerminalLineItem(text: 'Dimensional sync: ESTABLISHED', status: 'SYNC'),
  ];

  static const _recoveryLines = [
    TerminalLineItem(text: 'Recovery signal transmitted', status: 'OK'),
    TerminalLineItem(text: 'Awaiting System response...', status: '...'),
  ];

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breatheScale = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _breatheOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _timer1 = Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visibleLines = 1);
    });
    _timer2 = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _visibleLines = 2);
    });
    _timer3 = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _visibleLines = 3);
    });
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _timer1?.cancel();
    _timer2?.cancel();
    _timer3?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLines = widget.isRecovery ? _recoveryLines : _allLines;
    final displayedLines = activeLines.take(_visibleLines).toList();

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: Stack(
        children: [
          // 1. One-shot Laser Scanline Sweep
          const ScanlineSweep(),

          // 2. Floating Ambient Particles
          const Positioned.fill(
            child: ParticleField(count: 14),
          ),

          // 4. Central Breathing Ambient Radial Glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 260 * _breatheScale.value,
                    height: 260 * _breatheScale.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.manaCyan.withValues(alpha: 0.12 * _breatheOpacity.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 5. Hero Content Stack
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing Hero Badge
                    AnimatedBuilder(
                      animation: _breatheController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _breatheScale.value,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.manaCyan.withValues(alpha: 0.1),
                              border: Border.all(color: AppColors.manaCyan, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.manaCyan.withValues(alpha: 0.4 * _breatheOpacity.value),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '◈',
                              style: AppTypography.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.manaCyan,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Decrypted Heading Reveal
                    DecryptText(
                      text: widget.isRecovery ? 'SIGNAL SENT' : 'AUTHENTICATING...',
                      style: AppTypography.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.12,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Framed Glass System Status Card
                    GlassCard(
                      borderColor: AppColors.manaCyan.withValues(alpha: 0.25),
                      padding: const EdgeInsets.all(18),
                      child: TerminalReadout(lines: displayedLines),
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
