import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class DoctorSearchNoDataState extends StatelessWidget {
  const DoctorSearchNoDataState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 59.59,
            height: 59.59,
            decoration: const ShapeDecoration(
              color: AppColors.neutralSurface,
              shape: OvalBorder(),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppImages.searchUnselectedSvg,
                width: 29,
                height: 29,
                colorFilter: const ColorFilter.mode(
                  AppColors.redDeep,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Oops! No data founded yet',
            textAlign: TextAlign.center,
            style: AppTextStyles.homeSearchEmptyTitleGray900_20BoldSfPro,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 361,
            child: Text(
              'It seems that you\'ve got a blank state. We\'ll let you know when updates arrive!',
              textAlign: TextAlign.center,
              style: AppTextStyles.homeSearchEmptyBodyNeutralMid15RegularSfPro,
            ),
          ),
        ],
      ),
    );
  }
}
