import 'package:flutter/material.dart';

/// Background decorative circle
class BackgroundCircle extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final List<BoxShadow>? shadows;

  const BackgroundCircle({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: color,
        shape: OvalBorder(),
        shadows: shadows,
      ),
    );
  }
}
