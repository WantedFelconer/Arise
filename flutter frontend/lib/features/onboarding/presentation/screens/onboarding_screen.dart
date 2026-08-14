import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_popup_window.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/glitch_text.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/particle_field.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/radar_background.dart';
import '../../../../shared/models/player_data.dart';

class OnboardingScreen extends StatefulWidget {
  final ValueChanged<PlayerData> onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  int _bootLine = 0;
  bool _showWindow = false;
  final List<String> _selectedClasses = [];
  String _chronotype = '';
  String _difficulty = '';
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  bool _ariseReady = false;

  static const bootLines = [
    '> SYSTEM INITIALIZING...',
    '> SCANNING FOR DIMENSIONAL RIFT...',
    '> DETECTING LIFE SIGNATURE...',
    '> NEURAL INTERFACE CALIBRATION: 100%',
    '> ANOMALY DETECTED — IRREGULAR SOUL DETECTED',
    '> EVALUATING QUALIFICATION...',
    '> ...',
  ];

  static const statClasses = [
    {'id': 'body', 'label': 'BODY', 'stat': 'STR / VIT', 'desc': 'Physical training. The body is the vessel of the hunter.', 'color': AppColors.hpFrom, 'icon': '⚡'},
    {'id': 'mind', 'label': 'MIND', 'stat': 'INT / PER', 'desc': 'Cognition and awareness. Knowledge is the sharpest blade.', 'color': AppColors.mpFrom, 'icon': '◈'},
    {'id': 'craft', 'label': 'CRAFT', 'stat': 'AGI / INT', 'desc': 'Creation and mastery of skills. The forge of power.', 'color': AppColors.rankB, 'icon': '⚙'},
    {'id': 'discipline', 'label': 'DISCIPLINE', 'stat': 'ALL STATS', 'desc': 'Consistency forges legends. The System rewards dedication.', 'color': AppColors.expFrom, 'icon': '◆'},
  ];

  static const chronotypes = [
    {'id': 'early', 'label': 'EARLY BIRD', 'subtitle': 'PEAK: 06:00–10:00', 'desc': 'Dawn is your gate. Clarity, raw power, uncontested hours.', 'color': AppColors.expFrom, 'icon': '☀'},
    {'id': 'night', 'label': 'NIGHT OWL', 'subtitle': 'PEAK: 22:00–02:00', 'desc': 'Darkness is your dungeon. Deep focus, zero interruptions, infinite hours.', 'color': AppColors.rankB, 'icon': '🌙'},
    {'id': 'custom', 'label': 'CUSTOM WINDOW', 'subtitle': 'SET YOUR OWN PEAK', 'desc': 'The System adapts. Define your own optimal gate hours.', 'color': AppColors.manaCyan, 'icon': '◈'},
  ];

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  void _runBootSequence() {
    int i = 0;
    Timer.periodic(const Duration(milliseconds: 340), (t) {
      if (i < bootLines.length - 1) {
        if (mounted) setState(() => _bootLine++);
        i++;
      } else {
        t.cancel();
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _showWindow = true);
        });
      }
    });
  }

  void _handleArise() {
    final name = _nameController.text.trim().isEmpty ? 'HUNTER' : _nameController.text.trim();
    final title = _titleController.text.trim().isEmpty ? 'THE AWAKENED' : _titleController.text.trim();

    widget.onComplete(
      PlayerData.defaultPlayer.copyWith(
        name: name,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0Boot();
      case 1:
        return _buildStep1Class();
      case 2:
        return _buildStep2Chronotype();
      case 3:
        return _buildStep3Difficulty();
      case 4:
        return _buildStep4Name();
      case 5:
      default:
        return _buildStep5Arise();
    }
  }

  Widget _buildStep0Boot() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_bootLine + 1, (i) {
          final isCurrent = i == _bootLine;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              bootLines[i] + (isCurrent ? ' █' : ''),
              style: AppTypography.monoStat(
                fontSize: 13,
                color: isCurrent ? AppColors.manaCyan : AppColors.textDisabled,
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        if (_showWindow)
          ArisePopupWindow(
            showBackdrop: false,
            child: OrnatePanel(
              cornerSize: 28,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '⚠ SYSTEM MESSAGE',
                    style: AppTypography.orbitron(fontSize: 11, color: AppColors.manaCyan),
                  ),
                  const DiamondDivider(),
                  Text(
                    'YOU HAVE ACQUIRED THE QUALIFICATION TO BECOME A PLAYER.',
                    textAlign: TextAlign.center,
                    style: AppTypography.orbitron(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3),
                  ),
                  const DiamondDivider(),
                  Text(
                    '[ The System has recognized your potential.\nFrom this moment forward, your life will be\nmeasured, scored, and judged accordingly. ]',
                    textAlign: TextAlign.center,
                    style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  PressableCard(
                    onTap: () => setState(() => _step = 1),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.manaCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.manaCyan),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '[ ACCEPT DESIGNATION ]',
                        style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.manaCyan),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep1Class() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const _StepHeader(current: 1, total: 5, label: 'CLASS ASSESSMENT', sub: 'Choose the domains you wish to conquer.'),
        Expanded(
          child: ListView.builder(
            itemCount: statClasses.length,
            itemBuilder: (context, idx) {
              final cls = statClasses[idx];
              final id = cls['id'] as String;
              final selected = _selectedClasses.contains(id);
              final color = cls['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () {
                    setState(() {
                      selected ? _selectedClasses.remove(id) : _selectedClasses.add(id);
                    });
                  },
                  borderColor: selected ? color : AppColors.glassBorder,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(cls['icon'] as String, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  cls['label'] as String,
                                  style: AppTypography.orbitron(fontSize: 14, color: selected ? color : AppColors.textPrimary),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${cls['stat']}',
                                  style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cls['desc'] as String,
                              style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: selected ? color : AppColors.textDisabled, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: selected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        PressableCard(
          onTap: _selectedClasses.isNotEmpty ? () => setState(() => _step = 2) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: _selectedClasses.isNotEmpty
                  ? const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)])
                  : null,
              color: _selectedClasses.isEmpty ? AppColors.manaCyan.withValues(alpha: 0.05) : null,
              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
              boxShadow: _selectedClasses.isNotEmpty
                  ? const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 20)]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              'CONFIRM ASSESSMENT →',
              style: AppTypography.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _selectedClasses.isNotEmpty ? const Color(0xFF000000) : AppColors.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep2Chronotype() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const _StepHeader(current: 2, total: 5, label: 'CHRONOTYPE SCAN', sub: 'WHEN DOES YOUR ENERGY PEAK?'),
        Expanded(
          child: ListView.builder(
            itemCount: chronotypes.length,
            itemBuilder: (context, idx) {
              final ct = chronotypes[idx];
              final id = ct['id'] as String;
              final selected = _chronotype == id;
              final color = ct['color'] as Color;

              final sparklines = {
                'early': [20, 60, 100, 95, 80, 60, 40, 30, 25, 20, 18, 15],
                'night': [15, 10, 8, 12, 20, 30, 40, 50, 55, 75, 95, 100],
                'custom': [30, 50, 70, 60, 80, 100, 90, 70, 55, 40, 30, 20],
              }[id] ?? [30, 50, 70, 60, 80, 100, 90, 70, 55, 40, 30, 20];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () => setState(() => _chronotype = id),
                  borderColor: selected ? color : AppColors.glassBorder,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withValues(alpha: 0.35)),
                            ),
                            alignment: Alignment.center,
                            child: Text(ct['icon'] as String, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ct['label'] as String, style: AppTypography.orbitron(fontSize: 13, color: selected ? color : AppColors.textPrimary)),
                                Text(ct['subtitle'] as String, style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(ct['desc'] as String, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: selected ? color : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: selected ? color : AppColors.textDisabled, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: selected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Sparkline energy curve bar graph
                      SizedBox(
                        height: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: sparklines.map((v) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                child: Container(
                                  height: (v / 100.0) * 24,
                                  decoration: BoxDecoration(
                                    color: selected ? color.withValues(alpha: 0.8) : AppColors.manaCyan.withValues(alpha: 0.2),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('00:00', style: AppTypography.monoStat(fontSize: 7, color: AppColors.textDisabled)),
                          Text('ENERGY CURVE', style: AppTypography.monoStat(fontSize: 7, color: AppColors.textDisabled)),
                          Text('24:00', style: AppTypography.monoStat(fontSize: 7, color: AppColors.textDisabled)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        PressableCard(
          onTap: _chronotype.isNotEmpty ? () => setState(() => _step = 3) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: _chronotype.isNotEmpty
                  ? const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)])
                  : null,
              color: _chronotype.isEmpty ? AppColors.manaCyan.withValues(alpha: 0.05) : null,
              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
              boxShadow: _chronotype.isNotEmpty
                  ? const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 20)]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              'SYNC CHRONOTYPE →',
              style: AppTypography.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _chronotype.isNotEmpty ? const Color(0xFF000000) : AppColors.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep3Difficulty() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const _StepHeader(current: 3, total: 5, label: 'DIFFICULTY MODE', sub: 'Choose your terms with the System.'),
        Expanded(
          child: ListView(
            children: [
              GlassCard(
                onTap: () => setState(() => _difficulty = 'casual'),
                borderColor: _difficulty == 'casual' ? AppColors.terminalGreen : AppColors.glassBorder,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🛡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CASUAL', style: AppTypography.orbitron(fontSize: 15, color: _difficulty == 'casual' ? AppColors.terminalGreen : AppColors.textPrimary)),
                              Text('FOR THE AWAKENING HUNTER', style: AppTypography.monoStat(fontSize: 9, color: AppColors.terminalGreen)),
                            ],
                          ),
                        ),
                        if (_difficulty == 'casual') const Icon(Icons.check, color: AppColors.terminalGreen),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The System is forgiving. Miss a quest — lose XP, no stat decay. Penalties are soft.',
                      style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const DiamondDivider(),
                    ...['Missed quests: EXP loss only', 'No stat decay', 'Penalties: optional', 'Encouragement over punishment'].map((t) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('> $t', style: AppTypography.monoStat(fontSize: 10, color: AppColors.terminalGreen)),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                onTap: () => setState(() => _difficulty = 'hardcore'),
                borderColor: _difficulty == 'hardcore' ? AppColors.dangerRed : AppColors.glassBorder,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⚔', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HARDCORE RPG', style: AppTypography.orbitron(fontSize: 15, color: _difficulty == 'hardcore' ? AppColors.dangerRed : AppColors.textPrimary)),
                              Text('FOR THE SOVEREIGN HUNTER', style: AppTypography.monoStat(fontSize: 9, color: AppColors.dangerRed)),
                            ],
                          ),
                        ),
                        if (_difficulty == 'hardcore') const Icon(Icons.warning, color: AppColors.dangerRed),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No mercy. Miss a quest — stat decay, penalty assignments, dungeon lockout. The System forges or breaks you.',
                      style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const DiamondDivider(),
                    ...['Missed quests: stat decay + penalty quest', 'Full penalty protocol active', 'Dungeon lockout on 3-day miss', 'No compromises. No excuses.'].map((t) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('! $t', style: AppTypography.monoStat(fontSize: 10, color: AppColors.dangerRed)),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        PressableCard(
          onTap: _difficulty.isNotEmpty ? () => setState(() => _step = 4) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: _difficulty.isNotEmpty
                  ? const LinearGradient(colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)])
                  : null,
              color: _difficulty.isEmpty ? AppColors.manaCyan.withValues(alpha: 0.05) : null,
              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
              boxShadow: _difficulty.isNotEmpty
                  ? const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 20)]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              'LOCK IN MODE →',
              style: AppTypography.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _difficulty.isNotEmpty ? const Color(0xFF000000) : AppColors.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep4Name() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _StepHeader(current: 4, total: 5, label: 'DESIGNATION', sub: 'Your name will be recorded in the System.'),
        OrnatePanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NAME:', style: AppTypography.orbitron(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ENTER HUNTER NAME',
                  hintStyle: TextStyle(color: AppColors.manaCyan.withValues(alpha: 0.25)),
                  filled: true,
                  fillColor: AppColors.glassPanel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.manaCyan)),
                ),
              ),
              const DiamondDivider(),
              Text('PLAYER TITLE:', style: AppTypography.orbitron(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: AppTypography.orbitron(fontSize: 13, color: AppColors.expFrom),
                decoration: InputDecoration(
                  hintText: 'THE AWAKENED',
                  hintStyle: TextStyle(color: AppColors.expFrom.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: AppColors.glassPanel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.expFrom)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '[ This designation will be recorded permanently\nin the System\'s registry. ]',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textDisabled),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PressableCard(
          onTap: () {
            setState(() => _step = 5);
            Timer(const Duration(milliseconds: 800), () {
              if (mounted) setState(() => _ariseReady = true);
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.manaCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.manaCyan),
            ),
            alignment: Alignment.center,
            child: Text(
              'REGISTER IDENTITY →',
              style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.manaCyan),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep5Arise() {
    final name = _nameController.text.trim().isEmpty ? 'HUNTER' : _nameController.text.trim().toUpperCase();

    return Stack(
      children: [
        // Upward floating particle field
        const Positioned.fill(child: ParticleField(count: 14)),

        // Concentric spinning radar background
        const Positioned.fill(
          child: RadarBackground(
            sizes: [160, 220, 280],
            color: AppColors.manaCyan,
            baseOpacity: 0.15,
          ),
        ),

        // Center content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlitchText(
                  text: '[ THE SYSTEM IS READY ]',
                  style: AppTypography.monoStat(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.12),
                ),
                const SizedBox(height: 12),
                Text(
                  'ARISE',
                  style: AppTypography.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.15,
                  ).copyWith(
                    shadows: const [
                      Shadow(color: Color(0x993EE6F5), blurRadius: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hunter $name — your journey begins.',
                  textAlign: TextAlign.center,
                  style: AppTypography.rajdhani(fontSize: 15, color: AppColors.textSecondary, letterSpacing: 0.05),
                ),
                const SizedBox(height: 36),
                if (_ariseReady)
                  PressableCard(
                    onTap: _handleArise,
                    pressedScale: 0.95,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.manaCyan, width: 2.0),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3EE6F5), Color(0xFF1FA9C2)],
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x993EE6F5), blurRadius: 32),
                          BoxShadow(color: Color(0x333EE6F5), blurRadius: 64),
                        ],
                      ),
                      child: Text(
                        'ENTER THE SYSTEM',
                        style: AppTypography.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF030712),
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int current;
  final int total;
  final String label;
  final String sub;

  const _StepHeader({
    required this.current,
    required this.total,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('STEP $current OF $total', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
        const SizedBox(height: 2),
        Text('[ $label ]', style: AppTypography.monoStat(fontSize: 11, color: AppColors.manaCyan)),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: AppTypography.orbitron(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
