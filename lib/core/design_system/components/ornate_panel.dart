import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../painters/ornate_corner_painter.dart';
import '../painters/top_crest_painter.dart';

class OrnatePanel extends StatelessWidget {
  static final ImageFilter _blurFilter = ImageFilter.blur(sigmaX: 16, sigmaY: 16);

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
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x263EE6F5),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x800A1A3A),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: _blurFilter,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Stack(
              children: [
                // Top-Left Corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: CustomPaint(
                    size: Size(cornerSize, cornerSize),
                    painter: OrnateCornerPainter(),
                  ),
                ),
                // Top-Right Corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(cornerSize, cornerSize),
                    painter: OrnateCornerPainter(flipX: true),
                  ),
                ),
                // Bottom-Left Corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: CustomPaint(
                    size: Size(cornerSize, cornerSize),
                    painter: OrnateCornerPainter(flipY: true),
                  ),
                ),
                // Bottom-Right Corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(cornerSize, cornerSize),
                    painter: OrnateCornerPainter(flipX: true, flipY: true),
                  ),
                ),
                // Top Crest
                if (!noCrest)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CustomPaint(
                        size: const Size(60, 16),
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
          ),
        ),
      ),
    );
  }
}
