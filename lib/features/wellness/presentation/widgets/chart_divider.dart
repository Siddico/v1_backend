import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

class ChartDivider extends StatelessWidget {
  const ChartDivider({
    super.key,
    this.width = double.infinity,
    this.color = AppColors.neutral200,
    this.thickness = 1.5,
  });

  final double width;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: thickness,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: color,
          ),
        ),
      ),
    );
  }
}
