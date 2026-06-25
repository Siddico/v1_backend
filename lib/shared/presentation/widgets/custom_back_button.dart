import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_radius.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

/// A reusable custom back button with outline styling
class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? label;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;

  const CustomBackButton({
    super.key,
    required this.onTap,
    this.label,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 143,
        height: height ?? 61,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: borderColor ?? AppColors.tealP),
            borderRadius: AppRadius.button,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          (label ?? 'Back').tr(context),
          style: AppTextStyles.buttonTextTeal27ExtraBold.copyWith(
            color: textColor ?? AppColors.tealP,
          ),
        ),
      ),
    );
  }
}
