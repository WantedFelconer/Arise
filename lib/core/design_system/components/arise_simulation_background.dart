import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Global ARISE Matrix / Computational Simulation Background reproducing React's [.void-bg] and [.circuit-overlay].
/// Features a deep #0B1330 to #030712 radial void gradient with a subtle 24px x 24px cyan grid pattern (2.2% opacity).
class AriseSimulationBackground extends StatelessWidget {
  final Widget? child;

  const AriseSimulationBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.voidEdge,
        gradient: RadialGradient(
          center: Alignment(0.0, -0.4),
          radius: 1.0,
          colors: [
            AppColors.voidCenter,
            AppColors.voidEdge,
          ],
          stops: [0.0, 0.7],
        ),
      ),
      child: Stack(
        children: [
          // Full-screen 24px Matrix Grid Overlay
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CircuitGridPainter(
                  gridSize: 24.0,
                  color: AppColors.manaCyan,
                  opacity: 0.022,
                ),
              ),
            ),
          ),

          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

class _CircuitGridPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  final double opacity;

  const _CircuitGridPainter({
    required this.gridSize,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitGridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}
