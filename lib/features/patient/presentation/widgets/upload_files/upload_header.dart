import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';

class UploadHeader extends StatelessWidget {
  const UploadHeader({super.key, required this.title, required this.onSkip});

  final String title;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.uploadStepTitleTealDark20ExtraBold.copyWith(
              fontFamily: isArabic ? 'Cairo' : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onSkip,
          child: Container(
            width: 72,
            height: 24,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: AppColors.tealPrimaryDark,
                ),
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(100),
                  bottomEnd: Radius.circular(100),
                ),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Skip'.tr(context),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.skipTextTealIcon9Bold.copyWith(
                        fontFamily: isArabic ? 'Cairo' : null,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: AppColors.tealPrimaryDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
