import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class UploadStepIndicator extends StatelessWidget {
  const UploadStepIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepNode(number: 1, active: currentStep >= 1),
          Expanded(child: _StepLine(active: currentStep >= 2)),
          _StepNode(number: 2, active: currentStep >= 2),
          Expanded(child: _StepLine(active: currentStep >= 3)),
          _StepNode(number: 3, active: currentStep >= 3),
          Expanded(child: _StepLine(active: currentStep >= 4)),
          _StepNode(number: 4, active: currentStep >= 4),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.tealIconActive : AppColors.tealBorderLight,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.number, required this.active});

  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 33,
      decoration: ShapeDecoration(
        color: active ? AppColors.tealPrimaryLight : AppColors.tealSurface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.tealP),
          borderRadius: BorderRadius.circular(23.5),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          textAlign: TextAlign.center,
          style: AppTextStyles.uploadStepNode20SemiBold.copyWith(
            color: active ? AppColors.tealSurface : AppColors.tealPrimaryDark,
          ),
        ),
      ),
    );
  }
}
