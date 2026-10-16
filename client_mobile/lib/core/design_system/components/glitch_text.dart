import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration interval;
  final Duration glitchDuration;

  const GlitchText({
    super.key,
    required this.text,
    required this.style,
    this.interval = const Duration(seconds: 6),
    this.glitchDuration = const Duration(milliseconds: 400),
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  Timer? _timer;
  bool _isGlitching = false;
  double _dx = 0;
  double _dy = 0;
  double _opacity = 1.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.interval, (_) => _triggerGlitch());
  }

  void _triggerGlitch() async {
    if (!mounted) return;
    setState(() => _isGlitching = true);

    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() {
        _dx = (_random.nextDouble() - 0.5) * 6;
        _dy = (_random.nextDouble() - 0.5) * 3;
        _opacity = _random.nextDouble() > 0.5 ? 0.1 : 0.8;
      });
      await Future.delayed(Duration(milliseconds: widget.glitchDuration.inMilliseconds ~/ 4));
    }

    if (mounted) {
      setState(() {
        _isGlitching = false;
        _dx = 0;
        _dy = 0;
        _opacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGlitching) {
      return Text(widget.text, style: widget.style);
    }

    return Stack(
      children: [
        // Main text with opacity flicker
        Opacity(
          opacity: _opacity,
          child: Text(widget.text, style: widget.style),
        ),
        // Red offset slice
        Transform.translate(
          offset: Offset(_dx, _dy),
          child: Opacity(
            opacity: 0.7,
            child: Text(
              widget.text,
              style: widget.style.copyWith(
                color: const Color(0xFFFF2E4D).withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        // Cyan offset slice
        Transform.translate(
          offset: Offset(-_dx * 0.7, -_dy * 0.7),
          child: Opacity(
            opacity: 0.7,
            child: Text(
              widget.text,
              style: widget.style.copyWith(
                color: const Color(0xFF3EE6F5).withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
