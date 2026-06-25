import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

import 'patient_profile_colors.dart';
import 'patient_profile_settings_item_data.dart';

class PatientProfileSettingsCard extends StatelessWidget {
  const PatientProfileSettingsCard({super.key, required this.items});

  final List<PatientProfileSettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 1, color: PatientProfileColors.patientDark),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 11,
              offset: Offset(2, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              _PatientProfileSettingsRow(item: items[i]),
          ],
        ),
      ),
    );
  }
}

class _PatientProfileSettingsRow extends StatelessWidget {
  const _PatientProfileSettingsRow({required this.item});

  final PatientProfileSettingsItemData item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: item.key,
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: PatientProfileColors.patientAccent,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(color: AppColors.tealSurface),
              child: Image.asset(
                item.iconPath,
                fit: BoxFit.contain,
                color: item.iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.patientProfileSettingsRowGray800_16Regular,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.neutral600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
