import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class InstructionItem extends StatelessWidget {
  const InstructionItem({super.key, required this.text, this.dotColor = AppColors.redDeep});

  final String text;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsetsDirectional.only(top: 5),
          decoration: ShapeDecoration(
            color: dotColor,
            shape: const OvalBorder(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.robotoBlack14Regular.copyWith(
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : null,
            ),
          ),
        ),
      ],
    );
  }
}
