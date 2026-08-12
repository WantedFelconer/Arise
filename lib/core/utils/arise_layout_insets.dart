import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Centralized layout inset utility for ARISE navigation, safe area, and breathing space calculations.
class AriseLayoutInsets {
  AriseLayoutInsets._();

  /// Base visual height of the floating glass [NavBar] widget.
  static const double navBarBaseHeight = 68.0;

  /// Base visual height of the persistent [TopStatusBar] widget.
  static const double topStatusBarBaseHeight = 64.0;

  /// Intentional React parity breathing room above the navbar or screen bottom.
  static const double defaultBreathingSpace = 24.0;

  /// Calculates the required top content inset for main tab screens where [TopStatusBar] is present.
  static double topHeaderInset(BuildContext context, {double extra = 0.0}) {
    final topSafeArea = MediaQuery.of(context).padding.top;
    return topSafeArea + topStatusBarBaseHeight + 14.0 + extra;
  }

  /// Calculates top padding for overlay screens / standalone screens (where [TopStatusBar] is not present).
  static double topOverlayInset(BuildContext context, {double extra = 0.0}) {
    final topSafeArea = MediaQuery.of(context).padding.top;
    return topSafeArea + 16.0 + extra;
  }

  /// Calculates the required bottom content inset for main tab screens where [NavBar] is visible.
  static double bottomContentInset(BuildContext context, {double extra = 0.0}) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return navBarBaseHeight + bottomSafeArea + defaultBreathingSpace + extra;
  }

  /// Calculates bottom padding for overlay screens (where [NavBar] is not present).
  static double bottomOverlayInset(BuildContext context, {double extra = 0.0}) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return bottomSafeArea + defaultBreathingSpace + extra;
  }

  /// Calculates bottom position offset for floating action buttons (e.g., `+` FAB).
  static double fabBottomInset(BuildContext context, {double extra = 16.0}) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return navBarBaseHeight + bottomSafeArea + extra;
  }

  /// Calculates bottom margin for upward-sliding modals and bottom sheets.
  static double slidingModalBottomInset(BuildContext context, {bool isOverlay = false}) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final navHeight = isOverlay ? 0.0 : navBarBaseHeight;
    
    // When keyboard is visible, clear keyboard; otherwise clear navbar + safe area + margin
    return math.max(viewInsetsBottom, navHeight + bottomSafeArea + 12.0);
  }
}
