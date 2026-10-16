import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_sliding_window.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/rank_badge.dart';
import '../../../../core/design_system/components/reward_chip.dart';
import '../../../../core/utils/arise_layout_insets.dart';
import '../../../../shared/models/map_node.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  static const categoryColors = {
    'body': AppColors.hpFrom,
    'mind': AppColors.mpFrom,
    'craft': AppColors.rankB,
    'discipline': AppColors.expFrom,
  };

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  MapNode? _selectedNode;

  static const nodes = [
    MapNode(id: 'b1', x: 60, y: 300, label: '30-DAY RUN', rank: 'D', category: 'body', status: MapNodeStatus.complete, exp: 300, progress: 100, desc: 'Complete 30 consecutive days of running.'),
    MapNode(id: 'b2', x: 60, y: 200, label: '10KM DAILY', rank: 'C', category: 'body', status: MapNodeStatus.active, exp: 600, progress: 65, desc: 'Maintain 10km daily run for 30 days.'),
    MapNode(id: 'b3', x: 60, y: 100, label: 'MARATHON', rank: 'A', category: 'body', status: MapNodeStatus.locked, exp: 1500, progress: 0, desc: 'Complete a full 42.195km marathon.'),
    MapNode(id: 'm1', x: 175, y: 320, label: 'READ 12 BOOKS', rank: 'C', category: 'mind', status: MapNodeStatus.active, exp: 800, progress: 25, desc: 'Read 12 books in a calendar year.'),
    MapNode(id: 'm2', x: 175, y: 210, label: 'STUDY DAILY', rank: 'B', category: 'mind', status: MapNodeStatus.available, exp: 1000, progress: 0, desc: 'Study 1 hour daily for 60 days.'),
    MapNode(id: 'm3', x: 175, y: 100, label: 'MASTER CRAFT', rank: 'S', category: 'mind', status: MapNodeStatus.locked, exp: 2500, progress: 0, desc: 'Achieve mastery in your chosen domain.'),
    MapNode(id: 'c1', x: 290, y: 310, label: 'SHIP A PROJECT', rank: 'C', category: 'craft', status: MapNodeStatus.active, exp: 1000, progress: 35, desc: 'Release a project to the public.'),
    MapNode(id: 'c2', x: 290, y: 200, label: 'SHIP THE APP', rank: 'A', category: 'craft', status: MapNodeStatus.locked, exp: 2000, progress: 0, desc: 'Launch your main project in production.'),
    MapNode(id: 'd1', x: 80, y: 420, label: '30-DAY STREAK', rank: 'D', category: 'discipline', status: MapNodeStatus.complete, exp: 200, progress: 100, desc: 'Maintain a 30-day daily quest streak.'),
    MapNode(id: 'd2', x: 175, y: 450, label: '90-DAY STREAK', rank: 'B', category: 'discipline', status: MapNodeStatus.active, exp: 600, progress: 47, desc: 'Maintain a 90-day quest streak.'),
    MapNode(id: 'd3', x: 280, y: 420, label: '1-YEAR STREAK', rank: 'S', category: 'discipline', status: MapNodeStatus.locked, exp: 5000, progress: 0, desc: 'One year. No breaks. Unbroken.'),
    MapNode(id: 'you', x: 175, y: 370, label: 'YOU ARE HERE', rank: 'E', category: 'discipline', status: MapNodeStatus.active, exp: 0, progress: 0, desc: 'Current position.'),
  ];

  static const connections = [
    ['b1', 'b2'], ['b2', 'b3'],
    ['m1', 'm2'], ['m2', 'm3'],
    ['c1', 'c2'],
    ['d1', 'you'], ['d1', 'd2'], ['d2', 'd3'],
    ['you', 'b1'], ['you', 'm1'], ['you', 'c1'],
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AriseLayoutInsets.topHeaderInset(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[ DUNGEON MAP — LONG TERM OBJECTIVES ]', style: AppTypography.monoStat(fontSize: 10, color: AppColors.textDisabled)),
                  Text('ROADMAP', style: AppTypography.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Category Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: RoadmapScreen.categoryColors.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: e.value, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(e.key.toUpperCase(), style: AppTypography.orbitron(fontSize: 8, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Map Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [Color(0xFF0B1330), Color(0xFF030712)],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const viewW = 350.0;
                    const viewH = 500.0;
                    final scaleX = constraints.maxWidth / viewW;
                    final scaleY = constraints.maxHeight / viewH;
                    final scale = scaleX < scaleY ? scaleX : scaleY;
                    final offsetX = (constraints.maxWidth - viewW * scale) / 2;
                    final offsetY = (constraints.maxHeight - viewH * scale) / 2;

                    return GestureDetector(
                      onTapUp: (details) {
                        final pos = details.localPosition;
                        final canvasX = (pos.dx - offsetX) / scale;
                        final canvasY = (pos.dy - offsetY) / scale;

                        for (final n in nodes) {
                          final dx = n.x - canvasX;
                          final dy = n.y - canvasY;
                          if (dx * dx + dy * dy < 900) {
                            setState(() => _selectedNode = n);
                            break;
                          }
                        }
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _RoadmapConstellationPainter(
                          nodes: nodes,
                          connections: connections,
                          selectedNodeId: _selectedNode?.id,
                          scale: scale,
                          offsetX: offsetX,
                          offsetY: offsetY,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // Node Detail Bottom Sheet with Slide-up & Drag Gestures
        if (_selectedNode != null)
          Positioned.fill(
            child: AriseSlidingWindow(
              onClose: () => setState(() => _selectedNode = null),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RankBadge(rank: _selectedNode!.rank, size: RankBadgeSize.md),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedNode!.label, style: AppTypography.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(
                              '${_selectedNode!.category.toUpperCase()} BRANCH — ${_selectedNode!.status.name.toUpperCase()}',
                              style: AppTypography.monoStat(fontSize: 10, color: RoadmapScreen.categoryColors[_selectedNode!.category] ?? AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_selectedNode!.desc, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PROGRESS', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                      Text('${_selectedNode!.progress}%', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(color: const Color(0xCC0A1A3A), borderRadius: BorderRadius.circular(999)),
                    child: FractionallySizedBox(
                      widthFactor: (_selectedNode!.progress / 100.0).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(color: RoadmapScreen.categoryColors[_selectedNode!.category] ?? AppColors.manaCyan, borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ),
                  const DiamondDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RewardChip(exp: _selectedNode!.exp),
                      PressableCard(
                        onTap: () => setState(() => _selectedNode = null),
                        child: Text('[ CLOSE ]', style: AppTypography.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RoadmapConstellationPainter extends CustomPainter {
  final List<MapNode> nodes;
  final List<List<String>> connections;
  final String? selectedNodeId;
  final double scale;
  final double offsetX;
  final double offsetY;

  _RoadmapConstellationPainter({
    required this.nodes,
    required this.connections,
    this.selectedNodeId,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    final nodeMap = {for (final n in nodes) n.id: n};

    // Draw connection lines
    for (final conn in connections) {
      final from = nodeMap[conn[0]];
      final to = nodeMap[conn[1]];
      if (from != null && to != null) {
        final isActive = from.status != MapNodeStatus.locked && to.status != MapNodeStatus.locked;
        final paint = Paint()
          ..color = isActive ? AppColors.manaCyan.withValues(alpha: 0.45) : AppColors.manaCyan.withValues(alpha: 0.1)
          ..strokeWidth = isActive ? 1.5 : 1.0;
        canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), paint);
      }
    }

    // Draw nodes & labels
    for (final n in nodes) {
      final color = RoadmapScreen.categoryColors[n.category] ?? AppColors.rankE;
      final isDone = n.status == MapNodeStatus.complete;
      final isLocked = n.status == MapNodeStatus.locked;
      final isBoss = n.rank == 'S';
      final radius = isBoss ? 16.0 : 11.0;

      if (n.id == 'you') {
        canvas.drawCircle(Offset(n.x, n.y), 14, Paint()..color = AppColors.manaCyan.withValues(alpha: 0.25));
        canvas.drawCircle(Offset(n.x, n.y), 6, Paint()..color = AppColors.manaCyan);
        
        final tp = TextPainter(
          text: TextSpan(text: '▲ YOU', style: AppTypography.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(n.x - tp.width / 2, n.y + 16));
        continue;
      }

      // Outer glow pulse ring
      if (n.status == MapNodeStatus.active) {
        canvas.drawCircle(Offset(n.x, n.y), radius + 6, Paint()..color = color.withValues(alpha: 0.15));
      }

      final nodePaint = Paint()
        ..color = isDone ? color.withValues(alpha: 0.3) : isLocked ? const Color(0xCC0A1A3A) : color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isLocked ? AppColors.manaCyan.withValues(alpha: 0.2) : color
        ..strokeWidth = isBoss ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(n.x, n.y), radius, nodePaint);
      canvas.drawCircle(Offset(n.x, n.y), radius, borderPaint);

      if (isDone) {
        canvas.drawCircle(Offset(n.x, n.y), 4, Paint()..color = color);
      } else if (isBoss) {
        final tp = TextPainter(
          text: TextSpan(text: 'S', style: AppTypography.orbitron(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(n.x - tp.width / 2, n.y - tp.height / 2));
      } else if (isLocked) {
        final tp = TextPainter(
          text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(n.x - tp.width / 2, n.y - tp.height / 2));
      }

      // Label below node
      final labelPainter = TextPainter(
        text: TextSpan(
          text: n.label,
          style: AppTypography.monoStat(
            fontSize: 7.5,
            fontWeight: isBoss ? FontWeight.bold : FontWeight.normal,
            color: isLocked ? AppColors.textDisabled : AppColors.textPrimary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(n.x - labelPainter.width / 2, n.y + radius + 3));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoadmapConstellationPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.scale != scale ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.nodes != nodes ||
        oldDelegate.connections != connections;
  }
}
