import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

class ChartBar extends StatelessWidget {
  const ChartBar({
    super.key,
    required this.width,
    required this.height,
    this.color = AppColors.redSoft,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ChartBarGroup extends StatelessWidget {
  const ChartBarGroup({super.key, required this.bars, this.spacing = 26});

  final List<({double width, double height, Color color})> bars;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: spacing,
      children: bars
          .map(
            (bar) => ChartBar(
              width: bar.width,
              height: bar.height,
              color: bar.color,
            ),
          )
          .toList(),
    );
  }
}
