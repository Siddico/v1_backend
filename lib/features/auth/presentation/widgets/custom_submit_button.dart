import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom submit button
class CustomSubmitButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomSubmitButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.tealP;
    final effectiveTextColor = textColor ?? AppColors.tealSurface;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 61,
        decoration: ShapeDecoration(
          color: isLoading ? AppColors.neutral500 : effectiveBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          shadows: AppShadows.buttonShadow,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label.tr(context),
              style: AppTextStyles.submitButtonTealSurface27ExtraBold.copyWith(
                color: effectiveTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
