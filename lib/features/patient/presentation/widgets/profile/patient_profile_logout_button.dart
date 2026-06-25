import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class PatientProfileLogoutButton extends StatelessWidget {
  const PatientProfileLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 22.0, bottom: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: 200,
          height: 61,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1, color: AppColors.tealP),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              shadowColor: AppColors.shadowBlack25,
              elevation: 3,
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Log-out'.tr(context),
              style: AppTextStyles.buttonTextTeal27ExtraBold,
            ),
          ),
        ),
      ),
    );
  }
}
