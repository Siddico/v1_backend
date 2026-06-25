import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

class CircularLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const CircularLoadingIndicator({
    super.key,
    this.size = 100,
    this.color = AppColors.tealP,
  });

  @override
  State<CircularLoadingIndicator> createState() =>
      _CircularLoadingIndicatorState();
}

class _CircularLoadingIndicatorState extends State<CircularLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ArcPainter(color: widget.color, sizeValue: widget.size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double sizeValue;

  _ArcPainter({required this.color, required this.sizeValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Make stroke width proportional to the size to look good at any scale
    final double maxStrokeWidth = (sizeValue * 0.11).clamp(2.0, 15.0);
    final double bgStrokeWidth = (sizeValue * 0.025).clamp(1.0, 4.0);
    final double inset = maxStrokeWidth / 2;
    // Both lines share the exact same bounds, making them perfectly centered on each other
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - maxStrokeWidth,
      size.height - maxStrokeWidth,
    );

    // 1. Draw the Background Fixed Line
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = bgStrokeWidth;

    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // 2. Draw the Rotating Arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = maxStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      3.8, // start angle (~218°)
      1.68, // sweep angle (~96°)
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.color != color;
}
