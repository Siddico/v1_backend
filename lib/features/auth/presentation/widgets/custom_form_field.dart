import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom form field with Material Design styling
class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helperText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool readOnly;
  final Color focusedBorderColor;
  final ValueChanged<String>? onChanged;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
    this.focusedBorderColor = AppColors.tealP,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TextFormField(
        clipBehavior: Clip.none,
        controller: controller,
        validator: (value) {
          final err = validator(value);
          return err?.tr(context);
        },
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label.tr(context),
          labelStyle: AppTextStyles.formLabelNeutral16Medium,
          helperText: helperText.tr(context),
          helperStyle: AppTextStyles.formHelperNeutral12Regular,
          helperMaxLines: 2,
          errorStyle: AppTextStyles.formErrorRed12Roboto,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: const BorderSide(width: 1, color: AppColors.neutral300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: const BorderSide(width: 1, color: AppColors.neutral300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: BorderSide(width: 2, color: focusedBorderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: const BorderSide(width: 1, color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: const BorderSide(width: 2, color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
