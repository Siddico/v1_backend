import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

/// Reusable specialty chip widget
class SpecialtyChip extends StatelessWidget {
  const SpecialtyChip({super.key, 
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.tealBorderLight : Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.tealPrimaryDark),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.chipTextTealIcon12BoldTight,
        ),
      ),
    );
  }
}
