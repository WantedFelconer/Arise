import 'package:flutter/material.dart';

class RadarBackground extends StatefulWidget {
  final List<double> sizes;
  final Color color;
  final double baseOpacity;

  const RadarBackground({
    super.key,
    this.sizes = const [160, 220, 280],
    this.color = const Color(0xFF3EE6F5),
    this.baseOpacity = 0.15,
  });

  @override
  State<RadarBackground> createState() => _RadarBackgroundState();
}

class _RadarBackgroundState extends State<RadarBackground> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.sizes.asMap().entries.map((entry) {
      final idx = entry.key;
      final durationSeconds = 12 + idx * 4;
      final controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSeconds),
      );
      controller.repeat();
      return controller;
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: widget.sizes.asMap().entries.map((entry) {
              final i = entry.key;
              final size = entry.value;
              final opacity = (widget.baseOpacity - i * 0.04).clamp(0.02, 1.0);
              final reverse = i % 2 != 0;

              final ringContainer = Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: opacity),
                    width: 1.0,
                  ),
                ),
              );

              return AnimatedBuilder(
                animation: _controllers[i],
                child: ringContainer,
                builder: (context, child) {
                  final angle = _controllers[i].value * 2 * 3.141592653589793 * (reverse ? -1 : 1);
                  return Transform.rotate(
                    angle: angle,
                    child: child,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
