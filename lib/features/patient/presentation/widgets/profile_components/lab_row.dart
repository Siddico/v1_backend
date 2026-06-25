import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class LabRow extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LabRow({required this.name, required this.category});

  final String name;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.81),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.gray200),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 105, child: _rowText(name)),
          SizedBox(width: 110, child: _rowText(category)),
          SizedBox(
            width: 72,
            child: Text(
              'Last review',
              style: AppTextStyles.patientDetailTableCellNeutral450_10ExtraBold,
            ),
          ),
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

  Widget _rowText(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.patientDetailTableCellNeutral450_10ExtraBold,
    );
  }
}
