import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class DecryptText extends StatefulWidget {
  final String text;
  final Duration delay;
  final Duration speed;
  final TextStyle? style;

  const DecryptText({
    super.key,
    required this.text,
    this.delay = Duration.zero,
    this.speed = const Duration(milliseconds: 40),
    this.style,
  });

  @override
  State<DecryptText> createState() => _DecryptTextState();
}

class _DecryptTextState extends State<DecryptText> {
  String _displayed = '';
  bool _done = false;
  Timer? _timer;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _startTimer = Timer(widget.delay, () {
      int index = 0;
      _timer = Timer.periodic(widget.speed, (t) {
        if (index < widget.text.length) {
          index++;
          if (mounted) {
            setState(() {
              _displayed = widget.text.substring(0, index);
            });
          }
        } else {
          t.cancel();
          if (mounted) {
            setState(() {
              _done = true;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _displayed, style: widget.style),
          if (!_done)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: _BlinkingCursor(),
            ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 14,
        margin: const EdgeInsets.only(left: 2),
        color: AppColors.terminalGreen,
      ),
    );
  }
}
