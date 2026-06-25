import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class MetricInline extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MetricInline({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.patientDetailLabelBlack14SemiBold.copyWith(
            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            color: AppColors.neutral500,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.patientDetailValueBlack14Light.copyWith(
            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
