import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../application/reminders_notifier.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showAddModal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(remindersNotifierProvider.notifier).loadAll());
  }

  static const tabColors = {
    'PRODUCTIVITY': AppColors.manaCyan,
    'WELLNESS': AppColors.mpFrom,
    'BEHAVIORAL': AppColors.rankD,
    'SYSTEM': AppColors.rankB,
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersNotifierProvider);
    final notifier = ref.read(remindersNotifierProvider.notifier);
    final activeTab = state.activeTab;

    // Filter reminders by active category tab
    final filtered = state.reminders.where((r) => r.category.toUpperCase() == activeTab).toList();
    final activeColor = tabColors[activeTab] ?? AppColors.manaCyan;

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
                          Text('[ ALERT & REMINDER REGISTRY ]', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                          Text('NOTIFICATIONS & ALERTS', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text(
                        '${filtered.where((r) => r.isActive).length}/${filtered.length}',
                        style: AppTypography.monoStat(fontSize: 10, color: activeColor),
                      ),
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
                        final isActive = activeTab == tab;
                        final col = tabColors[tab] ?? AppColors.manaCyan;
                        final label = tab == 'PRODUCTIVITY' ? 'PROD' : tab == 'BEHAVIORAL' ? 'BEHAV' : tab;

                        return Expanded(
                          child: PressableCard(
                            onTap: () => notifier.setActiveTab(tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? col.withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(bottom: BorderSide(color: isActive ? col : Colors.transparent, width: 2)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: AppTypography.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? col : AppColors.textDisabled,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Reminder List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('◈', style: TextStyle(fontSize: 24, color: activeColor.withValues(alpha: 0.5))),
                              const SizedBox(height: 6),
                              Text('NO REMINDERS IN $activeTab', style: AppTypography.orbitron(fontSize: 10, color: AppColors.textDisabled)),
                              const SizedBox(height: 2),
                              Text('Tap + below to register a new system alert.', style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, AriseLayoutInsets.bottomOverlayInset(context, extra: 56.0)),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final item = filtered[idx];
                            final isActive = item.isActive;
                            final color = activeColor;
                            final scheduleStr = item.recurrence.toUpperCase();

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
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(item.icon, style: const TextStyle(fontSize: 18)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: AppTypography.orbitron(
                                              fontSize: 11,
                                              color: isActive ? AppColors.textPrimary : AppColors.textDisabled,
                                            ),
                                          ),
                                          Text(
                                            '⏱ $scheduleStr${item.snoozeCount > 0 ? ' · SNOOZED (${item.snoozeCount}x)' : ''}',
                                            style: AppTypography.monoStat(fontSize: 8, color: color),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isActive)
                                      ArisePressable(
                                        onTap: () => notifier.snoozeReminder(item.id, snoozeMinutes: 15),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.rankA.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('ZZZ', style: AppTypography.monoStat(fontSize: 8, color: AppColors.rankA)),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    CustomSwitch(
                                      value: isActive,
                                      activeColor: color,
                                      onChanged: (_) => notifier.toggleReminder(item.id),
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
                  defaultCategory: activeTab,
                  onClose: () => setState(() => _showAddModal = false),
                  onSave: (title, cat, icon, rec) {
                    notifier.createReminder(
                      title: title,
                      category: cat,
                      icon: icon,
                      recurrence: rec,
                    );
                    setState(() => _showAddModal = false);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddReminderModal extends StatefulWidget {
  final String defaultCategory;
  final VoidCallback onClose;
  final Function(String title, String category, String icon, String recurrence) onSave;

  const _AddReminderModal({
    required this.defaultCategory,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<_AddReminderModal> {
  final _titleController = TextEditingController();
  late String _tab;
  String _icon = '⚔';
  String _recurrence = 'daily';

  static const icons = ['⚔', '🏆', '📋', '💧', '🧘', '🌙', '🔥', '📵', '◈', '⚠', '🏅'];

  @override
  void initState() {
    super.initState();
    _tab = widget.defaultCategory;
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onSave(
      _titleController.text.trim().toUpperCase(),
      _tab,
      _icon,
      _recurrence,
    );
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
                        child: Text(
                          label,
                          style: AppTypography.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? col : AppColors.textDisabled,
                          ),
                        ),
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

            // Cadence input
            Text('CADENCE', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
            const SizedBox(height: 6),
            Row(
              children: ['daily', 'weekdays', 'weekly'].map((cad) {
                final isSel = _recurrence == cad;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: PressableCard(
                      onTap: () => setState(() => _recurrence = cad),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? themeColor.withValues(alpha: 0.15) : AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSel ? themeColor : AppColors.glassBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(cad.toUpperCase(), style: AppTypography.monoStat(fontSize: 8, color: isSel ? themeColor : AppColors.textDisabled)),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
