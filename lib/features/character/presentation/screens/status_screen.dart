import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_popup_window.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/arise_sliding_window.dart';
import '../../../../core/design_system/components/buff_tag.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/system_progress_bar.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../../shared/models/player_data.dart';

class StatusScreen extends StatefulWidget {
  final PlayerData player;
  final ValueChanged<String> onStatUp;

  const StatusScreen({
    super.key,
    required this.player,
    required this.onStatUp,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String _tab = 'stats';
  bool _showTitles = false;
  String _activeTitle = 'wolf';
  String? _pendingStat;

  static const statIcons = {
    'STR': '⚡', 'AGI': '◈', 'VIT': '♦', 'INT': '◎', 'PER': '◉',
  };

  static const titles = [
    {'id': 'wolf', 'name': 'WOLF SLAYER', 'desc': 'Defeated 10+ dungeon bosses', 'active': true},
    {'id': 'iron', 'name': 'IRON WILL', 'desc': 'Maintained a 30-day streak', 'active': true},
    {'id': 'shadow', 'name': 'SHADOW MONARCH', 'desc': 'Complete 500 quests [LOCKED]', 'active': false},
    {'id': 'arise', 'name': 'THE AWAKENED', 'desc': 'Default title upon awakening', 'active': true},
  ];

  static const achievements = [
    {'id': 'a1', 'name': 'FIRST BLOOD', 'rarity': 'common', 'icon': '⚔', 'desc': 'Complete your first quest', 'unlocked': true},
    {'id': 'a2', 'name': 'IRON STREAK', 'rarity': 'uncommon', 'icon': '🔥', 'desc': '14-day streak achieved', 'unlocked': true},
    {'id': 'a3', 'name': 'DUNGEON CRAWLER', 'rarity': 'rare', 'icon': '🏛', 'desc': 'Enter 50 Focus Gates', 'unlocked': true},
    {'id': 'a4', 'name': 'SCHOLAR', 'rarity': 'rare', 'icon': '📚', 'desc': 'Complete 100 Mind quests', 'unlocked': false},
    {'id': 'a5', 'name': 'THE SOVEREIGN', 'rarity': 'epic', 'icon': '👑', 'desc': 'Reach Rank A', 'unlocked': false},
    {'id': 'a6', 'name': 'CODE BREAKER', 'rarity': 'epic', 'icon': '💻', 'desc': '100 Craft quests cleared', 'unlocked': false},
    {'id': 'a7', 'name': 'SHADOW MONARCH', 'rarity': 'legendary', 'icon': '💀', 'desc': 'Complete 500 total quests', 'unlocked': false},
    {'id': 'a8', 'name': 'STREAKMASTER', 'rarity': 'legendary', 'icon': '⚡', 'desc': 'Maintain 100-day streak', 'unlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    final stats = {
      'STR': widget.player.str,
      'AGI': widget.player.agi,
      'VIT': widget.player.vit,
      'INT': widget.player.intStat,
      'PER': widget.player.per,
    };

    final displayTitle = titles.firstWhere((t) => t['id'] == _activeTitle, orElse: () => titles[0])['name'] as String;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, AriseLayoutInsets.topHeaderInset(context), 16, AriseLayoutInsets.bottomContentInset(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('[ HUNTER REGISTRY ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
              Text('SYSTEM STATUS', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              // Tab Switcher
              GlassCard(
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    Expanded(
                      child: PressableCard(
                        onTap: () => setState(() => _tab = 'stats'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _tab == 'stats' ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(bottom: BorderSide(color: _tab == 'stats' ? AppColors.manaCyan : Colors.transparent, width: 2)),
                          ),
                          alignment: Alignment.center,
                          child: Text('STATUS', style: AppTypography.orbitron(fontSize: 10, color: _tab == 'stats' ? AppColors.manaCyan : AppColors.textDisabled)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PressableCard(
                        onTap: () => setState(() => _tab = 'achievements'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _tab == 'achievements' ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(bottom: BorderSide(color: _tab == 'achievements' ? AppColors.manaCyan : Colors.transparent, width: 2)),
                          ),
                          alignment: Alignment.center,
                          child: Text('ACHIEVEMENTS', style: AppTypography.orbitron(fontSize: 10, color: _tab == 'achievements' ? AppColors.manaCyan : AppColors.textDisabled)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_tab == 'stats') ...[
                // Ornate System Window
                OrnatePanel(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text('STATUS', style: AppTypography.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.12)),
                      const SizedBox(height: 4),
                      Container(
                        height: 1,
                        width: 128,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.manaCyan, Colors.transparent],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldRow(label: 'NAME', value: widget.player.name.toUpperCase()),
                              _FieldRow(label: 'JOB', value: 'HUNTER'),
                              Row(
                                children: [
                                  Text('TITLE  ', style: AppTypography.orbitron(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.08)),
                                  GestureDetector(
                                    onTap: () => setState(() => _showTitles = true),
                                    child: Text('$displayTitle ▼', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RankBadge(rank: widget.player.rank, size: RankBadgeSize.md),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: 'LEVEL: ', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    TextSpan(text: '${widget.player.level}', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: 'FATIGUE: ', style: AppTypography.orbitron(fontSize: 11, color: AppColors.textSecondary)),
                                    TextSpan(text: '0', style: AppTypography.orbitron(fontSize: 11, color: AppColors.buffGreen)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: AppColors.manaCyan.withValues(alpha: 0.25)),
                      const SizedBox(height: 12),

                      // HP & MP Gauges
                      SystemProgressBar(value: widget.player.hp.toDouble(), max: widget.player.maxHp.toDouble(), variant: ProgressBarVariant.hp, label: 'HP', showNumbers: true, height: 12),
                      const SizedBox(height: 8),
                      SystemProgressBar(value: widget.player.mp.toDouble(), max: widget.player.maxMp.toDouble(), variant: ProgressBarVariant.mp, label: 'MP', showNumbers: true, height: 12),
                      const DiamondDivider(),

                      // Stat Allocation Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3.2,
                        children: stats.entries.map((entry) {
                          final stat = entry.key;
                          final val = entry.value;
                          return Row(
                            children: [
                              Text(statIcons[stat] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(width: 4),
                              Text('$stat:', style: AppTypography.orbitron(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.05)),
                              const SizedBox(width: 6),
                              Text('$val', style: AppTypography.monoStat(fontSize: 14, color: AppColors.textPrimary)),
                              if (widget.player.remainingPoints > 0) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(() => _pendingStat = stat),
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('+', style: TextStyle(fontSize: 10, color: AppColors.manaCyan, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }).toList(),
                      ),
                      const DiamondDivider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'REMAINING POINTS: ${widget.player.remainingPoints}',
                          style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.expFrom, letterSpacing: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Passive Buff Tags
                Text('[ PASSIVE SKILLS — ACTIVATING ]', style: AppTypography.orbitron(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    BuffTag(label: 'PHYSICAL DMG REDUCTION 15% — ACTIVE'),
                    BuffTag(label: 'EXP GAIN BONUS 10% — ACTIVE'),
                    BuffTag(label: 'DAILY QUEST COMPLETION +STREAK'),
                  ],
                ),
                const SizedBox(height: 16),

                // Experience Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppColors.expFrom.withValues(alpha: 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('EXPERIENCE', style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                          Text('${widget.player.exp} / ${widget.player.maxExp}', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SystemProgressBar(value: widget.player.exp.toDouble(), max: widget.player.maxExp.toDouble(), variant: ProgressBarVariant.exp, height: 10),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('TO LEVEL ${widget.player.level + 1}: ${widget.player.maxExp - widget.player.exp} EXP', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Gold Reserves Card
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  borderColor: const Color(0x40C98A1A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GOLD RESERVES', style: AppTypography.orbitron(fontSize: 10, color: const Color(0xFFC98A1A), letterSpacing: 0.12)),
                      Text('⬡ ${widget.player.gold}', style: AppTypography.monoStat(fontSize: 18, color: AppColors.expFrom)),
                    ],
                  ),
                ),
              ],

              if (_tab == 'achievements') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('[ ACHIEVEMENT REGISTRY ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled)),
                    Text('${achievements.where((a) => a['unlocked'] as bool).length} / ${achievements.length} UNLOCKED', style: AppTypography.monoStat(fontSize: 10, color: AppColors.expFrom)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  children: achievements.map((ach) {
                    final unlocked = ach['unlocked'] as bool;
                    final rarity = ach['rarity'] as String;
                    Color rc = AppColors.rankE;
                    if (rarity == 'uncommon') rc = AppColors.rankD;
                    if (rarity == 'rare') rc = AppColors.rankC;
                    if (rarity == 'epic') rc = AppColors.rankB;
                    if (rarity == 'legendary') rc = AppColors.expFrom;

                    return Opacity(
                      opacity: unlocked ? 1.0 : 0.55,
                      child: GlassCard(
                        borderColor: unlocked ? rc.withValues(alpha: 0.45) : AppColors.manaCyan.withValues(alpha: 0.08),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: unlocked ? rc.withValues(alpha: 0.15) : AppColors.manaCyan.withValues(alpha: 0.04),
                                border: Border.all(color: unlocked ? rc.withValues(alpha: 0.45) : AppColors.manaCyan.withValues(alpha: 0.1), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(unlocked ? (ach['icon'] as String) : '🔒', style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(height: 6),
                            Text(ach['name'] as String, textAlign: TextAlign.center, style: AppTypography.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: unlocked ? rc : AppColors.textDisabled)),
                            const SizedBox(height: 2),
                            Text(ach['desc'] as String, textAlign: TextAlign.center, style: AppTypography.rajdhani(fontSize: 10, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            if (unlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: rc.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: rc.withValues(alpha: 0.3)),
                                ),
                                child: Text(rarity.toUpperCase(), style: AppTypography.monoStat(fontSize: 8, color: rc)),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        // Title Selection Modal Sheet with Slide-up & Drag Gestures
        if (_showTitles)
          Positioned.fill(
            child: AriseSlidingWindow(
              onClose: () => setState(() => _showTitles = false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('SELECT TITLE', style: AppTypography.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.08)),
                  ),
                  const SizedBox(height: 12),
                  ...titles.map((t) {
                    final id = t['id'] as String;
                    final active = t['active'] as bool;
                    final isSelected = _activeTitle == id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PressableCard(
                        onTap: active ? () => setState(() { _activeTitle = id; _showTitles = false; }) : null,
                        pressedScale: 0.98,
                        child: GlassCard(
                          borderColor: isSelected ? AppColors.expFrom : AppColors.glassBorder,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t['name'] as String, style: AppTypography.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: active ? (isSelected ? AppColors.expFrom : AppColors.textPrimary) : AppColors.textDisabled)),
                                  Text(t['desc'] as String, style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                              if (isSelected) const Text('● ACTIVE', style: TextStyle(fontSize: 10, color: AppColors.manaCyan, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        // Stat Allocation Confirmation Modal Overlay with Emerge Animation
        if (_pendingStat != null)
          Positioned.fill(
            child: ArisePopupWindow(
              onClose: () => setState(() => _pendingStat = null),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OrnatePanel(
                  cornerSize: 24,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('[ SYSTEM DIRECTIVE ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('CONFIRM STAT ALLOCATION', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const DiamondDivider(),
                        Text('${statIcons[_pendingStat]} INVEST 1 POINT INTO $_pendingStat', style: AppTypography.orbitron(fontSize: 13, color: AppColors.manaCyan)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('CURRENT: ${(stats[_pendingStat] ?? 0)}', style: AppTypography.monoStat(fontSize: 11, color: AppColors.textDisabled)),
                            const SizedBox(width: 12),
                            Text('→', style: AppTypography.orbitron(fontSize: 14, color: AppColors.manaCyan)),
                            const SizedBox(width: 12),
                            Text('NEW: ${(stats[_pendingStat] ?? 0) + 1}', style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.expFrom)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: PressableCard(
                                onTap: () => setState(() => _pendingStat = null),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('CANCEL', style: AppTypography.orbitron(fontSize: 10, color: AppColors.textSecondary)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PressableCard(
                                onTap: () {
                                  final st = _pendingStat!;
                                  setState(() => _pendingStat = null);
                                  widget.onStatUp(st);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.manaCyan,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 16)],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('CONFIRM', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
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
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: AppTypography.orbitron(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
