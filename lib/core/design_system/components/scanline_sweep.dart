import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Single-shot hero scanline sweep overlay reproducing React's [.scanline-hero].
/// Sweeps a 2px glowing cyan line from top (0%) to bottom (110%) over 1 second.
class ScanlineSweep extends StatefulWidget {
  final Duration duration;

  const ScanlineSweep({
    super.key,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<ScanlineSweep> createState() => _ScanlineSweepState();
}

class _ScanlineSweepState extends State<ScanlineSweep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _topAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _topAnimation = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.8),
        weight: 70.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.0),
        weight: 30.0,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCompleted) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) return const SizedBox.shrink();

        final screenHeight = MediaQuery.of(context).size.height;
        final topPos = _topAnimation.value * screenHeight;

        return Positioned(
          top: topPos,
          left: 0,
          right: 0,
          height: 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacityAnimation.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.manaCyan,
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.manaCyan.withValues(alpha: 0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.manaCyan.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
