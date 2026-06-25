import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'doctor_state_card.dart';

class DoctorStatsStrip extends StatelessWidget {
  const DoctorStatsStrip({
    super.key,
    this.yearsExperience = '',
    this.patientsCount = '',
    this.licenseNumber = '',
  });

  /// e.g. '12+' from doctor_profile['years_experience']
  final String yearsExperience;

  /// e.g. '700+' from doctor_profile['patients_count']
  final String patientsCount;

  /// e.g. 'MOH-012345' from doctor_profile['license_number']
  final String licenseNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: DoctorStatCard(
              value: yearsExperience.isNotEmpty ? yearsExperience : '--',
              label: 'Years Experience'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DoctorStatCard(
              value: patientsCount.isNotEmpty ? patientsCount : '--',
              label: 'Patients'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DoctorStatCard(
              value: licenseNumber.isNotEmpty ? licenseNumber : '--',
              label: 'License Number'.tr(context),
            ),
          ),
        ],
      ),
    );
  }
}
