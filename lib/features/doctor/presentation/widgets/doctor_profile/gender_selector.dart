import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'gender_button.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, required this.isMale, required this.onChanged});

  final bool isMale;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 355,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GenderButton(
                  label: 'Male'.tr(context),
                  selected: isMale,
                  isLeft: true,
                  onTap: () => onChanged(true),
                ),
              ),
              Expanded(
                child: GenderButton(
                  label: 'Female'.tr(context),
                  selected: !isMale,
                  isLeft: false,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Please select your gender'.tr(context),
            style: AppTextStyles.doctorGenderHintNeutral300_12Regular,
          ),
        ],
      ),
    );
  }
}
