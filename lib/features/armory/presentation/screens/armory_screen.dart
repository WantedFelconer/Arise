import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_sliding_window.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/utils/arise_layout_insets.dart';

class ArmoryItem {
  final int id;
  final String name;
  final String desc;
  final int cost;
  final String rank;
  final String type;
  final String icon;

  const ArmoryItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.cost,
    required this.rank,
    required this.type,
    required this.icon,
  });
}

class ArmoryScreen extends StatefulWidget {
  final int gold;

  const ArmoryScreen({super.key, this.gold = 1240});

  @override
  State<ArmoryScreen> createState() => _ArmoryScreenState();
}

class _ArmoryScreenState extends State<ArmoryScreen> {
  late int _currentGold;
  String _filter = 'all';
  final List<int> _ownedIds = [6];
  ArmoryItem? _selectedItem;

  static const items = [
    ArmoryItem(id: 1, name: '1HR GUILT-FREE GAMING', desc: 'Grant yourself one hour of gaming without the System judging you.', cost: 200, rank: 'D', type: 'reward', icon: '🎮'),
    ArmoryItem(id: 2, name: 'ORDER TAKEOUT', desc: 'Summon sustenance from the outside world. You have earned it.', cost: 150, rank: 'D', type: 'reward', icon: '🍜'),
    ArmoryItem(id: 3, name: 'REST DAY PASS', desc: 'One sanctioned recovery day. The System permits it — once.', cost: 500, rank: 'B', type: 'reward', icon: '💤'),
    ArmoryItem(id: 4, name: 'NEW EQUIPMENT', desc: 'Allocate gold toward real-world gear: shoes, weights, tools.', cost: 1000, rank: 'A', type: 'reward', icon: '⚔'),
    ArmoryItem(id: 5, name: 'MOVIE NIGHT', desc: 'An evening of cinematic entertainment. System-approved leisure.', cost: 100, rank: 'E', type: 'reward', icon: '🎬'),
    ArmoryItem(id: 6, name: 'GOLD BORDER THEME', desc: 'Unlock the S-Rank gold interface overlay. Cosmetic only.', cost: 800, rank: 'S', type: 'cosmetic', icon: '✨'),
    ArmoryItem(id: 7, name: 'VOID WINDOW SKIN', desc: 'Alter the System window to pure black-void aesthetic.', cost: 600, rank: 'A', type: 'cosmetic', icon: '◈'),
    ArmoryItem(id: 8, name: '"SHADOW LORD" FRAME', desc: 'Equip the Shadow Monarch title frame around your profile.', cost: 1200, rank: 'S', type: 'cosmetic', icon: '◆'),
  ];

  @override
  void initState() {
    super.initState();
    _currentGold = widget.gold;
  }

  void _handleBuy(ArmoryItem item) {
    if (_currentGold >= item.cost && !_ownedIds.contains(item.id)) {
      setState(() {
        _currentGold -= item.cost;
        _ownedIds.add(item.id);
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all' ? items : items.where((i) => i.type == _filter).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 60, 16, AriseLayoutInsets.bottomOverlayInset(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('[ REWARDS VAULT ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                      Text('ARMORY', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderColor: AppColors.expFrom.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('GOLD', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                        Text('⬡ $_currentGold', style: AppTypography.monoStat(fontSize: 16, color: AppColors.expFrom)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Tabs
              GlassCard(
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: ['all', 'reward', 'cosmetic'].map((f) {
                    final isActive = _filter == f;
                    final label = f == 'all' ? 'ALL ITEMS' : f == 'reward' ? 'REAL REWARDS' : 'COSMETICS';
                    return Expanded(
                      child: PressableCard(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.manaCyan.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(bottom: BorderSide(color: isActive ? AppColors.manaCyan : Colors.transparent, width: 2)),
                          ),
                          alignment: Alignment.center,
                          child: Text(label, style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.w700, color: isActive ? AppColors.manaCyan : AppColors.textDisabled)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Items Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: filtered.map((item) {
                  final owned = _ownedIds.contains(item.id);
                  final rankColor = AppColors.getRankColor(item.rank);

                  return PressableCard(
                    onTap: () => setState(() => _selectedItem = item),
                    pressedScale: 0.95,
                    child: GlassCard(
                      borderColor: owned ? rankColor : rankColor.withValues(alpha: 0.25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            alignment: Alignment.center,
                            color: rankColor.withValues(alpha: 0.08),
                            child: Text(item.icon, style: const TextStyle(fontSize: 36)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    RankBadge(rank: item.rank, size: RankBadgeSize.sm),
                                    if (owned) ...[
                                      const SizedBox(width: 4),
                                      Text('OWNED', style: AppTypography.monoStat(fontSize: 7, color: AppColors.terminalGreen)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.orbitron(fontSize: 9, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(owned ? '✓ ACQUIRED' : '⬡ ${item.cost}', style: AppTypography.monoStat(fontSize: 10, color: owned ? AppColors.terminalGreen : AppColors.expFrom)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Item Modal Sheet with Slide-up & Drag Gestures
        if (_selectedItem != null)
          Positioned.fill(
            child: AriseSlidingWindow(
              isOverlay: true,
              useOrnatePanel: true,
              cornerSize: 24,
              onClose: () => setState(() => _selectedItem = null),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_selectedItem!.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RankBadge(rank: _selectedItem!.rank, size: RankBadgeSize.sm),
                            Text(_selectedItem!.name, style: AppTypography.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('[ ${_selectedItem!.desc} ]', style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary)),
                  const DiamondDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('COST', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                          Text('⬡ ${_selectedItem!.cost}', style: AppTypography.monoStat(fontSize: 18, color: AppColors.expFrom)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('YOUR GOLD', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                          Text('⬡ $_currentGold', style: AppTypography.monoStat(fontSize: 14, color: _currentGold >= _selectedItem!.cost ? AppColors.terminalGreen : AppColors.dangerRed)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PressableCard(
                    onTap: _ownedIds.contains(_selectedItem!.id) || _currentGold < _selectedItem!.cost ? null : () => _handleBuy(_selectedItem!),
                    pressedScale: 0.96,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _ownedIds.contains(_selectedItem!.id)
                            ? AppColors.terminalGreen.withValues(alpha: 0.15)
                            : _currentGold < _selectedItem!.cost
                                ? AppColors.dangerRed.withValues(alpha: 0.1)
                                : AppColors.expFrom,
                        border: Border.all(
                          color: _ownedIds.contains(_selectedItem!.id)
                              ? AppColors.terminalGreen.withValues(alpha: 0.4)
                              : _currentGold < _selectedItem!.cost
                                  ? AppColors.dangerRed.withValues(alpha: 0.4)
                                  : AppColors.expFrom,
                        ),
                        boxShadow: _ownedIds.contains(_selectedItem!.id) || _currentGold < _selectedItem!.cost
                            ? null
                            : const [BoxShadow(color: Color(0x66FFD24C), blurRadius: 20)],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _ownedIds.contains(_selectedItem!.id)
                            ? '✓ ITEM ACQUIRED'
                            : _currentGold < _selectedItem!.cost
                                ? 'INSUFFICIENT GOLD'
                                : '⬡ ACQUIRE FOR ${_selectedItem!.cost} GOLD',
                        style: AppTypography.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _ownedIds.contains(_selectedItem!.id)
                              ? AppColors.terminalGreen
                              : _currentGold < _selectedItem!.cost
                                  ? AppColors.dangerRed
                                  : Colors.black,
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
