import 'package:flutter/material.dart';

class OrnateCornerPainter extends CustomPainter {
  final Color color;
  final bool flipX;
  final bool flipY;

  const OrnateCornerPainter({
    this.color = const Color(0xFF3EE6F5),
    this.flipX = false,
    this.flipY = false,
  });

  static final Path _p1 = Path()..moveTo(2, 20)..lineTo(2, 2)..lineTo(20, 2);
  static final Path _p2 = Path()..moveTo(5, 18)..lineTo(5, 5)..lineTo(18, 5);
  static final Path _h1 = Path()..moveTo(22, 2)..cubicTo(26, 2, 28, 4, 30, 2);
  static final Path _h2 = Path()..moveTo(30, 2)..cubicTo(33, 2, 34, 3.5, 36, 2);
  static final Path _v1 = Path()..moveTo(2, 22)..cubicTo(2, 26, 4, 28, 2, 30);
  static final Path _v2 = Path()..moveTo(2, 30)..cubicTo(2, 33, 3.5, 34, 2, 36);
  static final Path _c1 = Path()..moveTo(22, 5)..cubicTo(24, 5, 25, 7, 23, 8)..cubicTo(21, 9, 20, 7, 22, 6.5);
  static final Path _c2 = Path()..moveTo(5, 22)..cubicTo(5, 24, 7, 25, 8, 23)..cubicTo(9, 21, 7, 20, 6.5, 22);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (flipX) {
      canvas.translate(size.width, 0);
      canvas.scale(-1.0, 1.0);
    }
    if (flipY) {
      canvas.translate(0, size.height);
      canvas.scale(1.0, -1.0);
    }

    final double scale = size.width / 40.0;
    canvas.scale(scale, scale);

    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main L-border
    cyanPaint.strokeWidth = 1.5;
    cyanPaint.color = color.withValues(alpha: 0.9);
    canvas.drawPath(_p1, cyanPaint);

    // Inner parallel track
    cyanPaint.strokeWidth = 0.6;
    cyanPaint.color = color.withValues(alpha: 0.4);
    canvas.drawPath(_p2, cyanPaint);

    // Corner diamond
    final rectPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final rectBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 5, 5), const Radius.circular(0.5)), rectPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 5, 5), const Radius.circular(0.5)), rectBorderPaint);

    final innerRectPaint = Paint()..color = color.withValues(alpha: 0.8);
    canvas.drawRect(const Rect.fromLTWH(1.5, 1.5, 2, 2), innerRectPaint);

    // Horizontal flourish
    cyanPaint.strokeWidth = 0.8;
    cyanPaint.color = color.withValues(alpha: 0.55);
    canvas.drawPath(_h1, cyanPaint);

    cyanPaint.strokeWidth = 0.6;
    cyanPaint.color = color.withValues(alpha: 0.3);
    canvas.drawPath(_h2, cyanPaint);
    canvas.drawCircle(const Offset(36, 2), 1.0, Paint()..color = color.withValues(alpha: 0.4));

    // Vertical flourish
    cyanPaint.strokeWidth = 0.8;
    cyanPaint.color = color.withValues(alpha: 0.55);
    canvas.drawPath(_v1, cyanPaint);

    cyanPaint.strokeWidth = 0.6;
    cyanPaint.color = color.withValues(alpha: 0.3);
    canvas.drawPath(_v2, cyanPaint);
    canvas.drawCircle(const Offset(2, 36), 1.0, Paint()..color = color.withValues(alpha: 0.4));

    // Scroll curl horizontal
    cyanPaint.strokeWidth = 0.7;
    cyanPaint.color = color.withValues(alpha: 0.5);
    canvas.drawPath(_c1, cyanPaint);

    // Scroll curl vertical
    canvas.drawPath(_c2, cyanPaint);

    // Tick marks on border
    cyanPaint.strokeWidth = 0.8;
    cyanPaint.color = color.withValues(alpha: 0.5);
    canvas.drawLine(const Offset(12, 2), const Offset(12, 4.5), cyanPaint);
    canvas.drawLine(const Offset(2, 12), const Offset(4.5, 12), cyanPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OrnateCornerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.flipX != flipX || oldDelegate.flipY != flipY;
  }
}
