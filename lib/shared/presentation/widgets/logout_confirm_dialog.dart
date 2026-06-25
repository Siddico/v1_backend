import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

/// Color scheme for the logout confirmation dialog.
class LogoutDialogColors {
  const LogoutDialogColors({
    required this.borderColor,
    required this.textColor,
    required this.circleBackground,
    required this.yesButtonColor,
    required this.yesTextColor,
    required this.backBorderColor,
    required this.backTextColor,
  });

  final Color borderColor;
  final Color textColor;
  final Color circleBackground;
  final Color yesButtonColor;
  final Color yesTextColor;
  final Color backBorderColor;
  final Color backTextColor;

  /// Blue scheme — Patient role
  static const LogoutDialogColors patient = LogoutDialogColors(
    borderColor: AppColors.tealP,
    textColor: AppColors.tealPrimaryDark,
    circleBackground: AppColors.tealBorderLight,
    yesButtonColor: AppColors.tealP,
    yesTextColor: AppColors.white,
    backBorderColor: AppColors.tealP,
    backTextColor: AppColors.tealP,
  );

  /// Red scheme — Doctor role
  static const LogoutDialogColors doctor = LogoutDialogColors(
    borderColor: AppColors.redDeep,
    textColor: AppColors.redPrimary,
    circleBackground: AppColors.pinkLace,
    yesButtonColor: AppColors.redDeep,
    yesTextColor: AppColors.white,
    backBorderColor: AppColors.redDeep,
    backTextColor: AppColors.redDeep,
  );

  /// Teal scheme — Researcher role
  static const LogoutDialogColors researcher = LogoutDialogColors(
    borderColor: AppColors.tealPrimary,
    textColor: AppColors.tealGreen,
    circleBackground: AppColors.cyanLightest,
    yesButtonColor: AppColors.tealPrimary,
    yesTextColor: AppColors.white,
    backBorderColor: AppColors.tealPrimary,
    backTextColor: AppColors.tealPrimary,
  );
}

/// Shows a logout confirmation dialog and returns `true` if the user confirmed.
Future<bool?> showLogoutConfirmDialog(
  BuildContext context, {
  LogoutDialogColors colors = LogoutDialogColors.patient,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => LogoutConfirmDialog(colors: colors),
  );
}

/// Logout confirmation dialog matching the Figma design.
/// Use [LogoutDialogColors.patient], [LogoutDialogColors.doctor], or
/// [LogoutDialogColors.researcher] to apply role-specific branding.
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({
    super.key,
    this.colors = LogoutDialogColors.patient,
  });

  final LogoutDialogColors colors;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 450 ? 402.0 : screenWidth - 32;
    final isCompact = dialogWidth < 340;
    final horizontalPadding = dialogWidth > 380
        ? 61.0
        : (isCompact ? 16.0 : 24.0);
    final titleFontSize = isCompact ? 18.0 : 22.0;
    final iconSize = isCompact ? 28.0 : 34.0;
    final buttonHeight = isCompact ? 54.0 : 61.0;
    final buttonFontSize = isCompact ? 23.0 : 27.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 27,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: colors.borderColor),
            borderRadius: BorderRadius.circular(36),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 33,
              offset: Offset(0, -7),
              spreadRadius: 11,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: colors.circleBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: SvgPicture.asset(
                AppImages.logoutSvg,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  colors.textColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Are you sure that you want to log out'.tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.logoutConfirmTitle(
                  colors.textColor,
                  titleFontSize,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: buttonHeight,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: colors.yesButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: AppColors.shadowBlack25,
                            blurRadius: 6,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Yes'.tr(context),
                          style: AppTextStyles.logoutConfirmAction(
                            colors.yesTextColor,
                            buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: buttonHeight,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: colors.backBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Back'.tr(context),
                          style: AppTextStyles.logoutConfirmAction(
                            colors.backTextColor,
                            buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
