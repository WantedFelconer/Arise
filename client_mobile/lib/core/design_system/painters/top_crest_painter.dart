import 'package:flutter/material.dart';

class TopCrestPainter extends CustomPainter {
  final Color color;

  const TopCrestPainter({this.color = const Color(0xFF3EE6F5)});

  static final Paint _fillPaint = Paint()
    ..color = const Color(0xF30A1A3A)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2.0;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(cx - 18, 16)
      ..lineTo(cx - 10, 4)
      ..lineTo(cx, 1)
      ..lineTo(cx + 10, 4)
      ..lineTo(cx + 18, 16)
      ..close();

    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, strokePaint);

    // Inner circle
    canvas.drawCircle(Offset(cx, 4), 2.0, Paint()..color = color.withValues(alpha: 0.9));
    canvas.drawCircle(
      Offset(cx, 4),
      3.5,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..strokeWidth = 0.6
        ..style = PaintingStyle.stroke,
    );

    // Side lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(cx - 8, 9), Offset(cx - 5, 6), linePaint);
    canvas.drawLine(Offset(cx + 8, 9), Offset(cx + 5, 6), linePaint);
  }

  @override
  bool shouldRepaint(covariant TopCrestPainter oldDelegate) => oldDelegate.color != color;
}
