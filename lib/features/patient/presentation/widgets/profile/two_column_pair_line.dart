import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class TwoColumnPairLine extends StatelessWidget {
  const TwoColumnPairLine({super.key, 
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });

  final String label1;
  final String value1;
  final String label2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Text(
                    label1,
                    style: AppTextStyles.patientDetailLabelBlack14SemiBold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ': $value1',
                    style: AppTextStyles.patientDetailValueBlack14Light,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Text(
                    label2,
                    style: AppTextStyles.patientDetailLabelBlack14SemiBold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ': $value2',
                    style: AppTextStyles.patientDetailValueBlack14Light,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
