import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class GenderButton extends StatelessWidget {
  const GenderButton({super.key, 
    required this.label,
    required this.selected,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? AppColors.redSurface : AppColors.white,
          border: Border.all(width: 1, color: AppColors.neutral400),
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(isLeft ? 100 : 0),
            bottomStart: Radius.circular(isLeft ? 100 : 0),
            topEnd: Radius.circular(isLeft ? 0 : 100),
            bottomEnd: Radius.circular(isLeft ? 0 : 100),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.doctorGenderButtonLabel(selected),
          ),
        ),
      ),
    );
  }
}
