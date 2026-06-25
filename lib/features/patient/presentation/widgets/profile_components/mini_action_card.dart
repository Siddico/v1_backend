import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class MiniActionCard extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MiniActionCard({
    required this.label,
    required this.iconImage,
    required this.onTap,
  });

  final String label;
  final String iconImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 52,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: AppColors.gray100,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: AppColors.neutral450),
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
            child: SvgPicture.asset(iconImage, width: 22, height: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.patientDetailAuxLabelBlack11Medium,
          ),
        ],
      ),
    );
  }
}
