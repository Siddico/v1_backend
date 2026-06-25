import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class PairLine extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const PairLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            Text(label, style: AppTextStyles.patientDetailLabelBlack14SemiBold),
            const SizedBox(width: 4),
            Text(
              ': $value',
              style: AppTextStyles.patientDetailValueBlack14Light,
            ),
          ],
        ),
      ),
    );
  }
}
