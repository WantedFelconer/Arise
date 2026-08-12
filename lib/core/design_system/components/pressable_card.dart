import 'package:flutter/material.dart';
import 'arise_pressable.dart';

/// PressableCard delegates to [ArisePressable] for consistent global ARISE tactile press feedback.
class PressableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double pressedOffsetY;
  final Duration duration;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
    this.pressedOffsetY = 1.2,
    this.duration = const Duration(milliseconds: 100),
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    return ArisePressable(
      onTap: onTap,
      pressedScale: pressedScale,
      pressedOffsetY: pressedOffsetY,
      pressDuration: duration,
      borderRadius: borderRadius,
      behavior: behavior,
      child: child,
    );
  }
}
