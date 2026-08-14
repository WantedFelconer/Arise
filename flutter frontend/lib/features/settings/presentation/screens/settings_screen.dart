import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/custom_switch.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsScreen({super.key, required this.onClose});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  double _penaltySeverity = 2.0;
  bool _discordPost = true;
  bool _calSync = true;
  bool _sound = true;
  String _theme = 'void';

  static const severityLabels = ['LENIENT', 'STANDARD', 'BRUTAL', 'ASCETIC'];
  static const themes = [
    {'id': 'void', 'label': 'VOID SOVEREIGN', 'color': AppColors.manaCyan},
    {'id': 'gold', 'label': 'GOLD MONARCH', 'color': AppColors.expFrom},
    {'id': 'shadow', 'label': 'SHADOW THRONE', 'color': AppColors.rankB},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, AriseLayoutInsets.topOverlayInset(context, extra: 36.0), 16, AriseLayoutInsets.bottomOverlayInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ SYSTEM CONFIGURATION ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                  Text('SETTINGS', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              AriseBackButton(onPressed: widget.onClose, label: 'CLOSE', showArrow: false),
            ],
          ),
          const SizedBox(height: 16),

          // Account
          const _Section(
            title: 'ACCOUNT',
            children: [
              _InfoRow(label: 'HUNTER NAME', value: 'PLAYER ONE'),
              _InfoRow(label: 'ACTIVE TITLE', value: 'WOLF SLAYER'),
              _InfoRow(label: 'HUNTER RANK', value: 'B-RANK', valueColor: AppColors.rankB),
              _InfoRow(label: 'ACCOUNT ID', value: '#4891-ARISE', valueColor: AppColors.textDisabled),
            ],
          ),
          const SizedBox(height: 16),

          // Notifications
          _Section(
            title: 'ALARMS & NOTIFICATIONS',
            children: [
              _ToggleRow(label: 'QUEST REMINDERS', desc: 'Alert before daily reset', value: _notifications, onChange: (v) => setState(() => _notifications = v)),
              _ToggleRow(label: 'SYSTEM SOUNDS', desc: 'EXP gain & quest completion', value: _sound, onChange: (v) => setState(() => _sound = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Penalty Protocol
          _Section(
            title: 'PENALTY PROTOCOL',
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SEVERITY LEVEL', style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary)),
                        Text(
                          severityLabels[_penaltySeverity.toInt()],
                          style: AppTypography.orbitron(
                            fontSize: 12,
                            color: _penaltySeverity < 2 ? AppColors.rankD : _penaltySeverity == 2 ? AppColors.rankA : AppColors.dangerRed,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _penaltySeverity,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      activeColor: AppColors.dangerRed,
                      onChanged: (v) => setState(() => _penaltySeverity = v),
                    ),
                    Text(
                      _penaltySeverity == 0
                          ? '[ Minimal consequences for missed quests. The System is merciful. ]'
                          : _penaltySeverity == 1
                              ? '[ Standard EXP deductions and penalty quests. The System is fair. ]'
                              : _penaltySeverity == 2
                                  ? '[ Heavy penalties. Stat decay. App restrictions. The System is merciless. ]'
                                  : '[ Maximum protocol. Full streak reset. The System shows no mercy. ]',
                      style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Integrations
          _Section(
            title: 'INTEGRATIONS',
            children: [
              _ToggleRow(label: 'GOOGLE CALENDAR SYNC', desc: 'Import events as scheduled quests', value: _calSync, onChange: (v) => setState(() => _calSync = v)),
              _ToggleRow(label: 'DISCORD ACHIEVEMENTS', desc: 'Post level-ups to linked server', value: _discordPost, onChange: (v) => setState(() => _discordPost = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Themes
          _Section(
            title: 'INTERFACE THEME',
            children: themes.map((t) {
              final isSelected = _theme == t['id'];
              final color = t['color'] as Color;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _theme = t['id'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? color : AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? color : Colors.transparent, border: Border.all(color: color)),
                          alignment: Alignment.center,
                          child: isSelected ? const Text('✓', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)) : null,
                        ),
                        const SizedBox(width: 12),
                        Text(t['label'] as String, style: AppTypography.orbitron(fontSize: 10, color: isSelected ? color : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const DiamondDivider(),

          // Danger Zone
          GlassCard(
            borderColor: AppColors.dangerRed.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('RESET ALL DATA — PERMANENT', style: AppTypography.orbitron(fontSize: 10, color: AppColors.dangerRed)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('— $title', style: AppTypography.orbitron(fontSize: 9, color: AppColors.manaCyan)),
        const SizedBox(height: 6),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChange;

  const _ToggleRow({required this.label, required this.desc, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary)),
              Text(desc, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          CustomSwitch(
            value: value,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.rajdhani(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: AppTypography.orbitron(fontSize: 11, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
