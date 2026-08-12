import 'dart:math';
import 'package:flutter/material.dart';

class ParticleField extends StatefulWidget {
  final int count;
  final Color color;

  const ParticleField({
    super.key,
    this.count = 14,
    this.color = const Color(0xFF3EE6F5),
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ParticleData> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _particles = List.generate(widget.count, (i) {
      return _ParticleData(
        leftPct: (10 + (i * 7)) % 90 / 100.0,
        drift: (i % 2 == 0 ? 1 : -1) * (10 + i * 4).toDouble(),
        speedFactor: 0.8 + _random.nextDouble() * 0.5,
        delayFactor: (i * 0.1) % 1.0,
        size: 1.5 + _random.nextDouble() * 1.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ParticlePainter(
          animation: _controller,
          particles: _particles,
          color: widget.color,
        ),
      ),
    );
  }
}

class _ParticleData {
  final double leftPct;
  final double drift;
  final double speedFactor;
  final double delayFactor;
  final double size;

  _ParticleData({
    required this.leftPct,
    required this.drift,
    required this.speedFactor,
    required this.delayFactor,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_ParticleData> particles;
  final Color color;
  final Paint _particlePaint = Paint()..style = PaintingStyle.fill;

  _ParticlePainter({
    required this.animation,
    required this.particles,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    for (final p in particles) {
      final t = (progress * p.speedFactor + p.delayFactor) % 1.0;
      final x = (size.width * p.leftPct) + (p.drift * t);
      final y = size.height * (1.0 - t);
      final opacity = (t < 0.1)
          ? t / 0.1 * 0.8
          : (t > 0.8)
              ? (1.0 - t) / 0.2 * 0.8
              : 0.8;

      _particlePaint.color = color.withValues(alpha: opacity.clamp(0.0, 0.9));
      canvas.drawCircle(Offset(x, y), p.size, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.particles != particles;
  }
}
