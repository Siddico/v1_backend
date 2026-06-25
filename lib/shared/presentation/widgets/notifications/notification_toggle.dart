import 'package:flutter/material.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Reusable custom toggle widget for notification settings
class NotificationToggle extends StatelessWidget {
  const NotificationToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.toggleLabelTealDark22Bold),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 52,
            height: 32,
            decoration: ShapeDecoration(
              color: value ? AppColors.tealPrimaryLight : AppColors.neutral250,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
            ),
            child: AnimatedAlign(
              duration: AppDurations.fast,
              curve: Curves.easeInOut,
              alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 28,
                height: 28,
                decoration: const ShapeDecoration(
                  color: AppColors.tealBorderLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(23)),
                  ),
                  shadows: [
                    BoxShadow(
                      color: AppColors.shadowBlack25,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
