import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class CircularStatDisplay extends StatelessWidget {
  const CircularStatDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.textColor = AppColors.neutral850,
  });

  final String value;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: 104,
            height: 104,
            decoration: ShapeDecoration(
              color: backgroundColor,
              shape: const OvalBorder(),
            ),
          ),
          // Foreground circle (partial fill effect)
          Container(
            width: 104,
            height: 104,
            decoration: ShapeDecoration(
              color: foregroundColor,
              shape: const OvalBorder(),
            ),
          ),
          // Text content
          Positioned(
            left: 24,
            top: 27,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metricLabelNeutral600_12SemiBold
                      .copyWith(height: 1.33),
                ),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metricStatusPoppins24SemiBold.copyWith(
                    color: textColor,
                    height: 1.08,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
