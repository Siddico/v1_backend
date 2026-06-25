import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';

class DataUploadCard extends StatelessWidget {
  const DataUploadCard({
    super.key,
    required this.onUploadPressed,
    this.backgroundColor = AppColors.tealP,
    this.buttonColor = AppColors.tealP,
  });

  final VoidCallback onUploadPressed;
  final Color backgroundColor;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(bottom: 16, start: 16, end: 16),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.tealP),
          borderRadius: AppRadius.radiusMD,
        ),
        shadows: AppShadows.standardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  'Now '.tr(context),
                  style: AppTextStyles.uploadDataNowTealDark40Bold.copyWith(
                    fontFamily: isArabic ? 'Cairo' : null,
                  ),
                ),
                Text(
                  'you can upload medical data manually to predict your case'
                      .tr(context),
                  style: AppTextStyles.uploadDataDescTealDark13Medium.copyWith(
                    fontFamily: isArabic ? 'Cairo' : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: ShapeDecoration(
                    color: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: AppColors.shadowBlack25,
                        blurRadius: 6,
                        offset: Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: onUploadPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Text(
                        'Upload data'.tr(context),
                        style: AppTextStyles.buttonTextTealSurface15ExtraBold
                            .copyWith(
                          fontFamily: isArabic ? 'Cairo' : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Image.asset(
                AppImages.uploadDataCard,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: AlignmentDirectional.bottomEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
