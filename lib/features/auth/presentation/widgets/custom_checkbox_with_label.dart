import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom checkbox with label and description
class CustomCheckboxWithLabel extends StatelessWidget {
  final bool value;
  final VoidCallback onChanged;
  final String label;
  final String? description;
  final Widget? linkWidget;
  final Color? activeColor;

  const CustomCheckboxWithLabel({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    this.linkWidget,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onChanged,
              child: Container(
                width: 20,
                height: 20,
                decoration: ShapeDecoration(
                  color: value ? (activeColor ?? AppColors.tealP) : AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: AppColors.neutral500,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.tr(context), style: AppTextStyles.checkboxLabelNeutral850_16),
                  if (description != null)
                    Text(
                      description!.tr(context),
                      style: AppTextStyles.checkboxDescriptionNeutral500_16,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (linkWidget != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 32, top: 4),
            child: linkWidget,
          ),
      ],
    );
  }
}
