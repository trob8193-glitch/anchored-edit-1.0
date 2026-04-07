// lib/features/ai_studio/widgets/animation_preview_widget.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Plays a sequence of raw image bytes as a looping animation.
class AnimationPreviewWidget extends StatefulWidget {
  const AnimationPreviewWidget({
    super.key,
    required this.frames,
    this.fps = 8.0,
    this.showControls = true,
    this.showCheckerboard = false,
    this.height = 320,
  });

  final List<Uint8List> frames;
  final double fps;
  final bool showControls;
  final bool showCheckerboard;
  final double height;

  @override
  State<AnimationPreviewWidget> createState() => _AnimationPreviewWidgetState();
}

class CheckerboardBackground extends StatelessWidget {
  const CheckerboardBackground({
    super.key,
    required this.child,
    this.tileSize = 16,
  });

  final Widget child;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(tileSize: tileSize),
      child: child,
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  _CheckerboardPainter({required this.tileSize});

  final double tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFF262626);
    final dark = Paint()..color = const Color(0xFF1A1A1A);

    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        final isLight =
            ((x / tileSize).floor() + (y / tileSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, tileSize, tileSize),
          isLight ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerboardPainter oldDelegate) {
    return oldDelegate.tileSize != tileSize;
  }
}

class _AnimationPreviewWidgetState extends State<AnimationPreviewWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _frameIndex = 0;
  bool _playing = true;

  double get _safeFps {
    if (widget.fps.isNaN || widget.fps.isInfinite || widget.fps <= 0) {
      return 8.0;
    }
    return widget.fps.clamp(1.0, 60.0);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: _frameDuration,
    )..addListener(_onTick);

    if (widget.frames.length > 1) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(AnimationPreviewWidget old) {
    super.didUpdateWidget(old);
    if (old.frames != widget.frames || old.fps != widget.fps) {
      _ctrl.duration = _frameDuration;
      if (_frameIndex >= widget.frames.length && widget.frames.isNotEmpty) {
        _frameIndex = widget.frames.length - 1;
      }

      if (widget.frames.length <= 1) {
        _ctrl.stop();
        _playing = false;
        _frameIndex = 0;
      } else if (_playing) {
        _syncControllerToFrame();
        _ctrl.repeat();
      } else {
        _syncControllerToFrame();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Duration get _frameDuration {
    if (widget.frames.isEmpty) return const Duration(milliseconds: 125);
    return Duration(
        milliseconds: (1000 / _safeFps * widget.frames.length).round());
  }

  void _syncControllerToFrame() {
    if (widget.frames.isEmpty) return;
    final frameSpan = widget.frames.length;
    _ctrl.value = (_frameIndex / frameSpan).clamp(0.0, 0.999999);
  }

  void _onTick() {
    if (widget.frames.isEmpty) return;
    final idx =
        (_ctrl.value * widget.frames.length).floor() % widget.frames.length;
    if (idx != _frameIndex) {
      setState(() => _frameIndex = idx);
    }
  }

  void _togglePlay() {
    if (widget.frames.length <= 1) return;
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _syncControllerToFrame();
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    });
  }

  void _stepFrame(int delta) {
    if (widget.frames.isEmpty) return;
    _ctrl.stop();
    setState(() {
      _playing = false;
      _frameIndex = (_frameIndex + delta) % widget.frames.length;
      _syncControllerToFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('No frames', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    Widget image = Image.memory(
      widget.frames[_frameIndex],
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );

    if (widget.showCheckerboard) {
      image = CheckerboardBackground(tileSize: 16, child: image);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: widget.height, child: image),
        ),
        if (widget.showControls && widget.frames.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white70),
                onPressed: () => _stepFrame(-1),
                tooltip: 'Previous frame',
              ),
              IconButton(
                icon: Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white70),
                onPressed: () => _stepFrame(1),
                tooltip: 'Next frame',
              ),
              const SizedBox(width: 8),
              Text(
                '${_frameIndex + 1} / ${widget.frames.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
