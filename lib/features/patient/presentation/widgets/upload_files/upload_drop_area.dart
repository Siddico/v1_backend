import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';

class UploadDropArea extends StatelessWidget {
  const UploadDropArea({
    super.key,
    required this.onFilePick,
    required this.supportedFormatsText,
  });

  final VoidCallback onFilePick;
  final String supportedFormatsText;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return GestureDetector(
      onTap: onFilePick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 40),
        decoration: ShapeDecoration(
          color: AppColors.grayLight,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: AppColors.grayBorder),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 11,
          children: [
            Image.asset(AppImages.uploadIcon, width: 70, height: 60),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Choose files from '.tr(context),
                      style: AppTextStyles.uploadMulish16BoldNeutral850.copyWith(
                        fontFamily: isArabic ? 'Cairo' : null,
                      ),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onFilePick,
                        child: Text(
                          'Phone'.tr(context),
                          style: AppTextStyles.uploadMulish16BoldTealUnderline
                              .copyWith(
                            fontFamily: isArabic ? 'Cairo' : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 309,
              child: Text(
                supportedFormatsText,
                textAlign: TextAlign.center,
                style: AppTextStyles.uploadHintNeutral700_12.copyWith(
                  fontFamily: isArabic ? 'Cairo' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
