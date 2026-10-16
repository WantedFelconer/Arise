import 'package:flutter/material.dart';

/// Standard global ARISE interactive press component.
/// Replaces default Android ripple feedback with tactile mechanical press-down
/// (scale compression + subtle vertical shift) and spring-release pop-up animation.
class ArisePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double pressedOffsetY;
  final Duration pressDuration;
  final Duration releaseDuration;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const ArisePressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
    this.pressedOffsetY = 1.2,
    this.pressDuration = const Duration(milliseconds: 100),
    this.releaseDuration = const Duration(milliseconds: 140),
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<ArisePressable> createState() => _ArisePressableState();
}

class _ArisePressableState extends State<ArisePressable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _offsetAnim;
  int _pressStartTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressDuration,
      reverseDuration: widget.releaseDuration,
    );

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _offsetAnim = Tween<double>(
      begin: 0.0,
      end: widget.pressedOffsetY,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _pressStartTime = DateTime.now().millisecondsSinceEpoch;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _releaseAndAction();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  Future<void> _releaseAndAction() async {
    final elapsed = DateTime.now().millisecondsSinceEpoch - _pressStartTime;
    // Guarantee minimum down visual state (~70ms) for quick taps
    const minDownMs = 70;
    if (elapsed < minDownMs) {
      await Future.delayed(Duration(milliseconds: minDownMs - elapsed));
    }
    if (mounted) {
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: Transform.scale(
            scale: _scaleAnim.value,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: content,
    );
  }
}
