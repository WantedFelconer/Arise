import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/arise_sliding_window.dart';
import '../../../../core/design_system/components/custom_switch.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/glow_fab.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeTab = 'PRODUCTIVITY';
  final List<int> _snoozedIds = [];
  bool _showAddModal = false;

  static const tabColors = {
    'PRODUCTIVITY': AppColors.manaCyan,
    'WELLNESS': AppColors.mpFrom,
    'BEHAVIORAL': AppColors.rankD,
    'SYSTEM': AppColors.rankB,
  };

  final List<Map<String, dynamic>> _reminders = [
    {'id': 1, 'icon': '⚔', 'title': 'DAILY QUEST CHECK-IN', 'schedule': '08:00 · DAILY', 'active': true, 'tab': 'PRODUCTIVITY', 'color': AppColors.manaCyan},
    {'id': 2, 'icon': '🏆', 'title': 'FOCUS SESSION — NOON', 'schedule': '12:00 · MON-FRI', 'active': true, 'tab': 'PRODUCTIVITY', 'color': AppColors.manaCyan},
    {'id': 3, 'icon': '📋', 'title': 'QUEST LOG REVIEW', 'schedule': '20:00 · DAILY', 'active': false, 'tab': 'PRODUCTIVITY', 'color': AppColors.manaCyan},
    {'id': 4, 'icon': '💧', 'title': 'HYDRATION REMINDER', 'schedule': 'EVERY 2H', 'active': true, 'tab': 'WELLNESS', 'color': AppColors.mpFrom},
    {'id': 5, 'icon': '🧘', 'title': 'MINDFULNESS WINDOW', 'schedule': '07:30 · DAILY', 'active': true, 'tab': 'WELLNESS', 'color': AppColors.mpFrom},
    {'id': 6, 'icon': '🌙', 'title': 'SLEEP PROTOCOL INIT', 'schedule': '22:30 · DAILY', 'active': true, 'tab': 'WELLNESS', 'color': AppColors.mpFrom},
    {'id': 7, 'icon': '🔥', 'title': 'STREAK GUARD', 'schedule': '21:00 · DAILY', 'active': true, 'tab': 'BEHAVIORAL', 'color': AppColors.rankD},
    {'id': 8, 'icon': '📵', 'title': 'SCREEN LIMIT ENFORCE', 'schedule': '23:00 · DAILY', 'active': false, 'tab': 'BEHAVIORAL', 'color': AppColors.rankD},
    {'id': 9, 'icon': '◈', 'title': 'SYSTEM UPLINK CHECK', 'schedule': 'ON APP OPEN', 'active': true, 'tab': 'SYSTEM', 'color': AppColors.rankB},
    {'id': 10, 'icon': '⚠', 'title': 'PENALTY ALERT', 'schedule': 'OVERDUE TRIGGER', 'active': true, 'tab': 'SYSTEM', 'color': AppColors.rankA},
    {'id': 11, 'icon': '🏅', 'title': 'LEVEL UP BROADCAST', 'schedule': 'ON ACHIEVEMENT', 'active': true, 'tab': 'SYSTEM', 'color': AppColors.rankB},
  ];

  void _toggle(int id) {
    setState(() {
      for (final r in _reminders) {
        if (r['id'] == id) r['active'] = !(r['active'] as bool);
      }
    });
  }

  void _snooze(int id) {
    setState(() => _snoozedIds.add(id));
  }

  void _addReminder(Map<String, dynamic> newReminder) {
    setState(() {
      _reminders.add(newReminder);
      _activeTab = newReminder['tab'] as String;
      _showAddModal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _reminders.where((r) => r['tab'] == _activeTab).toList();
    final activeColor = tabColors[_activeTab] ?? AppColors.manaCyan;

    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AriseBackButton(onPressed: widget.onBack),
                      Column(
                        children: [
                          Text('[ ALERT REGISTRY ]', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                          Text('NOTIFICATIONS', style: AppTypography.orbitron(fontSize: 13, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text('${filtered.where((r) => r['active'] as bool).length}/${filtered.length}', style: AppTypography.monoStat(fontSize: 10, color: activeColor)),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: ['PRODUCTIVITY', 'WELLNESS', 'BEHAVIORAL', 'SYSTEM'].map((tab) {
                        final isActive = _activeTab == tab;
                        final col = tabColors[tab] ?? AppColors.manaCyan;
                        final label = tab == 'PRODUCTIVITY' ? 'PROD' : tab == 'BEHAVIORAL' ? 'BEHAV' : tab;

                        return Expanded(
                          child: PressableCard(
                            onTap: () => setState(() => _activeTab = tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? col.withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(bottom: BorderSide(color: isActive ? col : Colors.transparent, width: 2)),
                              ),
                              alignment: Alignment.center,
                              child: Text(label, style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.w700, color: isActive ? col : AppColors.textDisabled)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, AriseLayoutInsets.bottomOverlayInset(context, extra: 56.0)),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      final id = item['id'] as int;
                      final isActive = item['active'] as bool;
                      final isSnoozed = _snoozedIds.contains(id);
                      final color = item['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GlassCard(
                          borderColor: isActive ? color.withValues(alpha: 0.25) : AppColors.glassBorder,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                alignment: Alignment.center,
                                child: Text(item['icon'] as String, style: const TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'] as String, style: AppTypography.orbitron(fontSize: 11, color: isActive ? AppColors.textPrimary : AppColors.textDisabled)),
                                    Text('⏱ ${item['schedule']}', style: AppTypography.monoStat(fontSize: 8, color: color)),
                                  ],
                                ),
                              ),
                              if (isActive && !isSnoozed)
                                ArisePressable(
                                  onTap: () => _snooze(id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.rankA.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('ZZZ', style: AppTypography.monoStat(fontSize: 8, color: AppColors.rankA)),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              CustomSwitch(
                                value: isActive,
                                activeColor: color,
                                onChanged: (v) => _toggle(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: GlowFab(
                color: activeColor,
                onPressed: () => setState(() => _showAddModal = true),
              ),
            ),

            // Add Reminder Sliding Window Modal Overlay
            if (_showAddModal)
              Positioned.fill(
                child: _AddReminderModal(
                  onClose: () => setState(() => _showAddModal = false),
                  onSave: _addReminder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddReminderModal extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _AddReminderModal({
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<_AddReminderModal> {
  final _titleController = TextEditingController();
  final _scheduleController = TextEditingController(text: '08:00 · DAILY');
  String _tab = 'PRODUCTIVITY';
  String _icon = '⚔';

  static const icons = ['⚔', '🏆', '📋', '💧', '🧘', '🌙', '🔥', '📵', '◈', '⚠', '🏅'];

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;
    final color = _NotificationsScreenState.tabColors[_tab] ?? AppColors.manaCyan;
    final newReminder = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'icon': _icon,
      'title': _titleController.text.trim().toUpperCase(),
      'schedule': _scheduleController.text.trim().isEmpty ? '08:00 · DAILY' : _scheduleController.text.trim().toUpperCase(),
      'active': true,
      'tab': _tab,
      'color': color,
    };
    widget.onSave(newReminder);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _NotificationsScreenState.tabColors[_tab] ?? AppColors.manaCyan;

    return AriseSlidingWindow(
      onClose: widget.onClose,
      isOverlay: true,
      useOrnatePanel: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[ NEW ALERT REGISTRY ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                    Text('REGISTER REMINDER', style: AppTypography.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                ArisePressable(
                  onTap: widget.onClose,
                  child: Text('✕', style: AppTypography.monoStat(fontSize: 18, color: AppColors.textDisabled)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title input
            Text('REMINDER TITLE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _titleController,
                style: AppTypography.orbitron(fontSize: 13, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'E.G. HYDRATION CHECK',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Category Selection
            Text('CATEGORY', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 6),
            Row(
              children: ['PRODUCTIVITY', 'WELLNESS', 'BEHAVIORAL', 'SYSTEM'].map((tab) {
                final isSelected = _tab == tab;
                final col = _NotificationsScreenState.tabColors[tab] ?? AppColors.manaCyan;
                final label = tab == 'PRODUCTIVITY' ? 'PROD' : tab == 'BEHAVIORAL' ? 'BEHAV' : tab;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: PressableCard(
                      onTap: () => setState(() => _tab = tab),
                      pressedScale: 0.96,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? col.withValues(alpha: 0.15) : AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? col : AppColors.glassBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(label, style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: isSelected ? col : AppColors.textDisabled)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Icon Picker
            Text('SYMBOL / ICON', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: icons.map((ic) {
                  final isSelected = _icon == ic;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: PressableCard(
                      onTap: () => setState(() => _icon = ic),
                      pressedScale: 0.94,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor.withValues(alpha: 0.2) : AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? themeColor : AppColors.glassBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(ic, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Schedule input
            Text('SCHEDULE / CADENCE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _scheduleController,
                style: AppTypography.monoStat(fontSize: 12, color: themeColor),
                decoration: const InputDecoration(
                  hintText: '08:00 · DAILY or EVERY 2H',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CTA Button
            PressableCard(
              onTap: _handleSave,
              pressedScale: 0.96,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(color: themeColor.withValues(alpha: 0.4), blurRadius: 20),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '[ REGISTER REMINDER ]',
                  style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
