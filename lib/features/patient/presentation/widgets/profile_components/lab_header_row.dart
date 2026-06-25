import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class LabHeaderRow extends StatelessWidget {
  const LabHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: ShapeDecoration(
        color: AppColors.gray50,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.redDarkest),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: Row(
        children: [
          _headerText('Lab name'.tr(context)),
          const Spacer(),
          _headerText('Category'.tr(context)),
          const Spacer(),
          _headerText('Last review'.tr(context)),
          const Spacer(),
          SvgPicture.asset(
            AppImages.eyeOfPatientRecordSvg,
            width: 12,
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: AppTextStyles.patientDetailTableHeaderBlack70_10ExtraBold,
    );
  }
}
