import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import 'arise_pressable.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    final border = borderColor ?? const Color(0x2E3EE6F5); // 18% opacity cyan
    final bg = backgroundColor ?? AppColors.glassPanel;

    // Fake Glass: GPU-optimized Container with subtle highlight gradient and border
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg.withValues(alpha: (bg.a * 1.05).clamp(0.0, 1.0)),
            bg.withValues(alpha: (bg.a * 0.95).clamp(0.0, 1.0)),
          ],
        ),
        borderRadius: br,
        border: Border.all(color: border, width: 1.0),
        boxShadow: boxShadow != null
            ? [boxShadow!]
            : const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return ArisePressable(
        onTap: onTap,
        borderRadius: br,
        child: content,
      );
    }
    return content;
  }
}
