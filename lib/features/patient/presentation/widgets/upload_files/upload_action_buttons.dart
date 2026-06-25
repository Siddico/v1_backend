import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';

class UploadActionButtons extends StatelessWidget {
  const UploadActionButtons({
    super.key,
    required this.showBack,
    required this.primaryButtonText,
    required this.onNext,
    required this.onBack,
  });

  final bool showBack;
  final String primaryButtonText;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return Row(
      children: [
        Expanded(
          flex: showBack ? 3 : 1,
          child: GestureDetector(
            onTap: onNext,
            child: Container(
              height: 61,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: AppColors.tealP,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    primaryButtonText,
                    style: AppTextStyles.buttonTextTealSurface27ExtraBold
                        .copyWith(fontFamily: isArabic ? 'Cairo' : null),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showBack) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                height: 61,
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 1, color: AppColors.tealP),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Back'.tr(context),
                      style: AppTextStyles.buttonTextTeal27ExtraBold.copyWith(
                        fontFamily: isArabic ? 'Cairo' : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
