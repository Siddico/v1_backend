import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class SegmentTab extends StatelessWidget {
  const SegmentTab({super.key, 
    required this.label,
    required this.selected,
    required this.leftRounded,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool leftRounded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: selected ? AppColors.redButton : AppColors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.redNearBlack),
            borderRadius: BorderRadiusDirectional.only(
              topStart: leftRounded ? const Radius.circular(100) : Radius.zero,
              bottomStart: leftRounded
                  ? const Radius.circular(100)
                  : Radius.zero,
              topEnd: !leftRounded ? const Radius.circular(100) : Radius.zero,
              bottomEnd: !leftRounded
                  ? const Radius.circular(100)
                  : Radius.zero,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.patientDetailSegmentTab(selected),
        ),
      ),
    );
  }
}
