import 'package:flutter/material.dart';

/// Standardized ARISE System Window Pop-Up Component.
///
/// Reproduces the exact React [@keyframes level-flash] motion language:
/// - 0ms (0%): scale 0.60, opacity 0.0
/// - 280ms (40%): scale 1.08, opacity 1.0 (Overshoot)
/// - 490ms (70%): scale 0.97, opacity 1.0 (Settle compression)
/// - 700ms (100%): scale 1.00, opacity 1.0 (Resting state)
/// Easing curve: [Curves.easeOutCubic] / cubic-bezier(0.16, 1, 0.3, 1).
class ArisePopupWindow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;
  final bool showBackdrop;
  final Color? backdropColor;

  const ArisePopupWindow({
    super.key,
    required this.child,
    this.onClose,
    this.showBackdrop = true,
    this.backdropColor,
  });

  @override
  State<ArisePopupWindow> createState() => _ArisePopupWindowState();
}

class _ArisePopupWindowState extends State<ArisePopupWindow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _backdropAnimation;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Multi-stage scale animation: 0.6 -> 1.08 -> 0.97 -> 1.00
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.60, end: 1.08).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.97).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.00).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30.0,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70.0,
      ),
    ]).animate(_controller);

    _backdropAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    if (_isClosing) return;
    _isClosing = true;
    _controller.animateTo(0.0, duration: const Duration(milliseconds: 220), curve: Curves.easeInQuad).then((_) {
      if (mounted && widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backdropColor = widget.backdropColor ?? Colors.black.withValues(alpha: 0.85);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.showBackdrop)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onClose != null ? dismiss : null,
                  child: Container(
                    color: backdropColor.withValues(alpha: backdropColor.a * _backdropAnimation.value),
                  ),
                ),
              ),

            RepaintBoundary(
              child: Center(
                child: Opacity(
                  opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
