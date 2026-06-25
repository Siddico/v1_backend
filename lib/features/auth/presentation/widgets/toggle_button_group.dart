import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Toggle button group for dual options (e.g., Male/Female, Sign up/Login)
class ToggleButtonGroup extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final bool isFirstSelected;
  final VoidCallback onFirstTap;
  final VoidCallback onSecondTap;
  final BorderRadius? firstBorderRadius;
  final BorderRadius? secondBorderRadius;
  final Color? borderColor;
  final Color? activeBackgroundColor;
  final Color? inactiveBackgroundColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;

  const ToggleButtonGroup({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.isFirstSelected,
    required this.onFirstTap,
    required this.onSecondTap,
    this.firstBorderRadius,
    this.secondBorderRadius,
    this.borderColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = borderColor ?? AppColors.redNearBlack;
    final Color effectiveActiveBackground =
        activeBackgroundColor ?? AppColors.redButton;
    final Color effectiveInactiveBackground =
        inactiveBackgroundColor ?? AppColors.white;
    final Color effectiveActiveText = activeTextColor ?? AppColors.redSurface;
    final Color effectiveInactiveText =
        inactiveTextColor ?? Colors.black.withValues(alpha: 0.20);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onFirstTap,
              child: Container(
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      color: AppColors.shadowBlack25,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                  color: isFirstSelected
                      ? effectiveActiveBackground
                      : effectiveInactiveBackground,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: effectiveBorderColor),
                    borderRadius:
                        firstBorderRadius ??
                        const BorderRadiusDirectional.only(
                          topStart: Radius.circular(100),
                          bottomStart: Radius.circular(100),
                        ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  firstLabel.tr(context),
                  style: AppTextStyles.toggleOptionText14Roboto500(
                    isFirstSelected
                        ? effectiveActiveText
                        : effectiveInactiveText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSecondTap,
              child: Container(
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      color: AppColors.shadowBlack25,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                  color: !isFirstSelected
                      ? effectiveActiveBackground
                      : effectiveInactiveBackground,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: effectiveBorderColor),
                    borderRadius:
                        secondBorderRadius ??
                        const BorderRadiusDirectional.only(
                          topEnd: Radius.circular(100),
                          bottomEnd: Radius.circular(100),
                        ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  secondLabel.tr(context),
                  style: AppTextStyles.toggleOptionText14Roboto500(
                    !isFirstSelected
                        ? effectiveActiveText
                        : effectiveInactiveText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
