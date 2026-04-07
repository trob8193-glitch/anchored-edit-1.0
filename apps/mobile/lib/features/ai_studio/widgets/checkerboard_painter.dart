import 'package:flutter/material.dart';

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
        final isLight = ((x / tileSize).floor() + (y / tileSize).floor()) % 2 == 0;
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
