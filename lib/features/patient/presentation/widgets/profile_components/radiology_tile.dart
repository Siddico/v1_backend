import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile/dashed_rect_border_painter.dart';

class RadiologyTile extends StatelessWidget {
  const RadiologyTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Container(
            height: 52,
            width: 54,
            decoration: ShapeDecoration(
              color: AppColors.gray100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.shadowBlack25,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CustomPaint(
              foregroundPainter: const DashedRRectBorderPainter(
                color: AppColors.neutral450,
                radius: 8,
                strokeWidth: 1,
                dashWidth: 4,
                dashGap: 3,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppImages.downloadIconPdfSvg,
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),
          SizedBox(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.patientDetailAuxLabelBlack11Medium,
            ),
          ),
        ],
      ),
    );
  }
}
