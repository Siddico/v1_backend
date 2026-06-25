import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.topColor = AppColors.tealPrimarySoft,
    this.bottomColor = Colors.white,
    this.borderRadius = 55,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.50, -0.00),
          end: const Alignment(0.50, 1.00),
          colors: [topColor, bottomColor],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: child,
    );
  }
}
