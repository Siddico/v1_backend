import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';

class UploadHelpSection extends StatelessWidget {
  const UploadHelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return Column(
      children: [
        const Center(child: _UploadIconBadge()),
        const SizedBox(height: 12),
        Text(
          'You can upload one or more medical reports here. Make sure your files are in one of the supported formats.'
              .tr(context),
          textAlign: TextAlign.center,
          style: AppTextStyles.uploadHelpNeutralMid15SfProRegular.copyWith(
            fontFamily: isArabic ? 'Cairo' : null,
          ),
        ),
      ],
    );
  }
}

class _UploadIconBadge extends StatelessWidget {
  const _UploadIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 59.59,
      height: 59.59,
      padding: const EdgeInsets.all(14),
      decoration: const ShapeDecoration(
        color: AppColors.neutralSurface,
        shape: OvalBorder(),
      ),
      child: SvgPicture.asset(AppImages.upload, fit: BoxFit.contain),
    );
  }
}
