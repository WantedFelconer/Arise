import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../painters/ornate_corner_painter.dart';
import '../painters/top_crest_painter.dart';

class OrnatePanel extends StatelessWidget {
  final Widget child;
  final double cornerSize;
  final bool noCrest;
  final Color? backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const OrnatePanel({
    super.key,
    required this.child,
    this.cornerSize = 36.0,
    this.noCrest = false,
    this.backgroundColor,
    this.borderColor = const Color(0x733EE6F5), // 45% cyan
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.glassPanel;
    final radius = borderRadius ?? BorderRadius.zero;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg.withValues(alpha: (bg.a * 1.05).clamp(0.0, 1.0)),
            bg.withValues(alpha: (bg.a * 0.95).clamp(0.0, 1.0)),
          ],
        ),
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F3EE6F5),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-Left Corner
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: Size(cornerSize, cornerSize),
              painter: const OrnateCornerPainter(),
            ),
          ),
          // Top-Right Corner
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(cornerSize, cornerSize),
              painter: const OrnateCornerPainter(flipX: true),
            ),
          ),
          // Bottom-Left Corner
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: Size(cornerSize, cornerSize),
              painter: const OrnateCornerPainter(flipY: true),
            ),
          ),
          // Bottom-Right Corner
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              size: Size(cornerSize, cornerSize),
              painter: const OrnateCornerPainter(flipX: true, flipY: true),
            ),
          ),
          // Top Crest
          if (!noCrest)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: CustomPaint(
                  size: Size(60, 16),
                  painter: TopCrestPainter(),
                ),
              ),
            ),
          // Content
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ],
      ),
    );
  }
}
