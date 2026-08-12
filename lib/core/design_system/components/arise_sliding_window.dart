import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../utils/arise_layout_insets.dart';
import 'glass_card.dart';
import 'ornate_panel.dart';

/// Standardized ARISE bottom-sliding window component.
///
/// Features:
/// - Full-height window geometry extending to physical screen bottom ([bottom: 0]).
/// - Inner content padding using [AriseLayoutInsets] to clear navbar and safe areas.
/// - Interactive vertical swipe/drag tracking with finger-following physics and fling-velocity dismiss.
/// - Smooth opening and closing slide animations with backdrop fade.
class AriseSlidingWindow extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  final bool isOverlay;
  final bool useOrnatePanel;
  final double cornerSize;

  const AriseSlidingWindow({
    super.key,
    required this.child,
    required this.onClose,
    this.isOverlay = false,
    this.useOrnatePanel = false,
    this.cornerSize = 20.0,
  });

  @override
  State<AriseSlidingWindow> createState() => _AriseSlidingWindowState();
}

class _AriseSlidingWindowState extends State<AriseSlidingWindow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _backdropAnimation;
  final ValueNotifier<double> _dragNotifier = ValueNotifier<double>(0.0);
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _backdropAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isClosing) return;
    _isClosing = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isClosing) return;
    final delta = details.delta.dy;
    double current = _dragNotifier.value;
    if (current < 0 && delta < 0) {
      current += delta * 0.25;
    } else {
      current += delta;
    }
    _dragNotifier.value = math.max(-40.0, current);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isClosing) return;
    final velocity = details.primaryVelocity ?? 0.0;
    if (_dragNotifier.value > 100.0 || velocity > 350.0) {
      _dismiss();
    } else {
      _dragNotifier.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = widget.isOverlay
        ? AriseLayoutInsets.bottomOverlayInset(context)
        : AriseLayoutInsets.bottomContentInset(context);
    final maxWindowHeight = MediaQuery.of(context).size.height * 0.88;

    final windowInnerContent = widget.useOrnatePanel
        ? OrnatePanel(
            cornerSize: widget.cornerSize,
            noCrest: true,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 12),
                  Flexible(child: widget.child),
                ],
              ),
            ),
          )
        : GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            borderColor: const Color(0x403EE6F5),
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildHandle()),
                const SizedBox(height: 12),
                Flexible(child: widget.child),
              ],
            ),
          );

    final windowShell = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxWindowHeight),
      child: windowInnerContent,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _dragNotifier]),
      child: windowShell,
      builder: (context, child) {
        final animatedOffsetY = _slideAnimation.value * 350.0 + _dragNotifier.value;

        return Stack(
          children: [
            // Dark Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withValues(alpha: _backdropAnimation.value),
                ),
              ),
            ),

            // Sliding Window Container extending to screen bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0, animatedOffsetY),
                child: GestureDetector(
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  behavior: HitTestBehavior.opaque,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.manaCyan.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
