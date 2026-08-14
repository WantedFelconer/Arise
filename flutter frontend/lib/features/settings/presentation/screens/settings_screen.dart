import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/custom_switch.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/providers/player_provider.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../application/settings_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const SettingsScreen({super.key, required this.onClose});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const themes = [
    {'id': 'void', 'label': 'VOID SOVEREIGN', 'color': AppColors.manaCyan},
    {'id': 'gold', 'label': 'GOLD MONARCH', 'color': AppColors.expFrom},
    {'id': 'shadow', 'label': 'SHADOW THRONE', 'color': AppColors.rankB},
  ];

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.manaCyan),
        ),
        title: Text(
          'SEVER SYSTEM UPLINK',
          style: AppTypography.orbitron(fontSize: 16, color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you wish to disconnect your hunter neural interface and logout?',
          style: AppTypography.rajdhani(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: AppTypography.monoStat(fontSize: 12, color: AppColors.textDisabled),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'SEVER UPLINK',
              style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onClose();
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  void _handleExport() async {
    final data = await ref.read(settingsNotifierProvider.notifier).exportData();
    if (data != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.voidEdge,
          content: Text(
            'DATA EXPORT READY: ${data.keys.length} tables exported.',
            style: AppTypography.monoStat(fontSize: 11, color: AppColors.manaCyan),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final settingsState = ref.watch(settingsNotifierProvider);
    final settings = settingsState.settings;
    final notifier = ref.read(settingsNotifierProvider.notifier);

    final isHardcore = settings.isHardcore;
    final selectedTheme = settings.theme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        AriseLayoutInsets.topOverlayInset(context, extra: 36.0),
        16,
        AriseLayoutInsets.bottomOverlayInset(context),
      ),
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

          // Account Section
          _Section(
            title: 'ACCOUNT',
            children: [
              _InfoRow(label: 'HUNTER NAME', value: player.name.isNotEmpty ? player.name : 'PLAYER ONE'),
              _InfoRow(label: 'ACTIVE TITLE', value: player.title.isNotEmpty ? player.title : 'THE AWAKENED'),
              _InfoRow(label: 'HUNTER RANK', value: '${player.rank}-RANK', valueColor: AppColors.rankB),
              _InfoRow(
                label: 'ACCOUNT FREQUENCY',
                value: player.email ?? (player.id != null ? '#${player.id!.substring(0, 8)}-ARISE' : '#LOCAL-ARISE'),
                valueColor: AppColors.textDisabled,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Alarms & Notifications
          _Section(
            title: 'ALARMS & NOTIFICATIONS',
            children: [
              _ToggleRow(
                label: 'QUEST REMINDERS',
                desc: 'Alert before daily reset',
                value: settings.notificationPreferences['questReminders'] ?? true,
                onChange: (v) => notifier.toggleNotification('questReminders', v),
              ),
              _ToggleRow(
                label: 'SYSTEM SOUNDS',
                desc: 'EXP gain & quest completion audio',
                value: settings.soundEnabled,
                onChange: (v) => notifier.updateSound(v),
              ),
              _ToggleRow(
                label: 'GATE EXPEDITION ALERTS',
                desc: 'Stability warnings and countdown notifications',
                value: settings.notificationPreferences['gateAlerts'] ?? true,
                onChange: (v) => notifier.toggleNotification('gateAlerts', v),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Penalty Protocol / Difficulty Modes (§6.24)
          _Section(
            title: 'DIFFICULTY & PENALTY PROTOCOL (§6.24)',
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DIFFICULTY MODE', style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary)),
                        Text(
                          isHardcore ? 'HARDCORE' : 'CASUAL',
                          style: AppTypography.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isHardcore ? AppColors.dangerRed : AppColors.manaCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: PressableCard(
                            onTap: () => notifier.updateDifficultyMode('casual'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isHardcore ? AppColors.manaCyan.withValues(alpha: 0.15) : AppColors.glassPanel,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: !isHardcore ? AppColors.manaCyan : AppColors.glassBorder),
                              ),
                              alignment: Alignment.center,
                              child: Text('CASUAL (1 PAUSE)', style: AppTypography.orbitron(fontSize: 9, color: !isHardcore ? AppColors.manaCyan : AppColors.textDisabled)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PressableCard(
                            onTap: () => notifier.updateDifficultyMode('hardcore'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isHardcore ? AppColors.dangerRed.withValues(alpha: 0.15) : AppColors.glassPanel,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isHardcore ? AppColors.dangerRed : AppColors.glassBorder),
                              ),
                              alignment: Alignment.center,
                              child: Text('HARDCORE (0 PAUSE)', style: AppTypography.orbitron(fontSize: 9, color: isHardcore ? AppColors.dangerRed : AppColors.textDisabled)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHardcore
                          ? '[ Hardcore Mode: 0 gate pauses allowed, full streak reset, +15% boss HP on gate collapse. ]'
                          : '[ Casual Mode: 1 gate pause permitted, standard EXP decay on collapse. ]',
                      style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Themes
          _Section(
            title: 'INTERFACE THEME',
            children: themes.map((t) {
              final isSelected = selectedTheme == t['id'];
              final color = t['color'] as Color;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => notifier.updateTheme(t['id'] as String),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.transparent,
                            border: Border.all(color: color),
                          ),
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
          const SizedBox(height: 16),

          // Data Management & Export (§6.23)
          _Section(
            title: 'DATA MANAGEMENT & EXPORT (§6.23)',
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GDPR / DATA EXPORT', style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary)),
                        Text('Download full account records JSON', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    PressableCard(
                      onTap: _handleExport,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.manaCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.manaCyan),
                        ),
                        child: Text('EXPORT JSON', style: AppTypography.orbitron(fontSize: 9, color: AppColors.manaCyan)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const DiamondDivider(),

          // Danger Zone / Logout
          GlassCard(
            onTap: _handleLogout,
            borderColor: AppColors.dangerRed.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(14),
            child: Center(
              child: Text(
                'LOGOUT — SEVER SYSTEM UPLINK',
                style: AppTypography.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dangerRed,
                  letterSpacing: 0.1,
                ),
              ),
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
