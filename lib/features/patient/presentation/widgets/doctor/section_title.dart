import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: AppTextStyles
            .patientDoctorDetailSectionTitleBlackNeutral20ExtraBold,
      ),
    );
  }
}
