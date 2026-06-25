import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.patientDetailSectionTitleBlack18ExtraBold,
    );
  }
}
