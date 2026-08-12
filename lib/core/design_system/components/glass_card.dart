import 'dart:ui';
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

    Widget content = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassPanel,
            borderRadius: br,
            border: Border.all(color: border, width: 1.0),
            boxShadow: boxShadow != null ? [boxShadow!] : null,
          ),
          child: child,
        ),
      ),
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
