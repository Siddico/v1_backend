import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/services/pdf_report_service.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/patient_profile_providers.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';
import 'package:grad_imp_1/features/wellness/domain/entities/health_data_entity.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/core/utils/app_tutorial_helper.dart';


class BottomActionButtons extends ConsumerWidget {
  final String patientId;

  const BottomActionButtons({super.key, required this.patientId});

  String _computeAge(String? dob) {
    if (dob == null || dob.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age--;
      }
      return '$age Year';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailsProvider(patientId));
    final healthState = ref.watch(
      healthMonitoringControllerProviderFamily(patientId),
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: KeyedSubtree(
            key: AppTutorialHelper.doctorPatientReportBtnKey,
            child: SizedBox(
              height: 61,
              child: ElevatedButton(
                onPressed: () async {
                  final patient = patientAsync.valueOrNull;
                  if (patient == null) return;

                  final profile = patient.patientProfile;
                  final profileBmi = (profile?['bmi'] as num?)?.toDouble();
                  double height = (profile?['height'] as num?)?.toDouble() ?? 0.0;
                  double weight = (profile?['weight'] as num?)?.toDouble() ?? 0.0;
                  
                  // If weight and height are not set but we have bmi, default height and calculate weight
                  if (weight == 0.0 && height == 0.0 && profileBmi != null) {
                    height = 170.0;
                    weight = profileBmi * (height / 100.0) * (height / 100.0);
                  }

                  final rawRiskScore =
                      healthState.currentPrediction?.riskScore ??
                      (profile?['ai_risk_stroke_rate'] as num?)?.toDouble() ??
                      healthState.averageRiskScore;
                  final riskScore = rawRiskScore <= 1.0 ? rawRiskScore * 100 : rawRiskScore;
                  final heartRate =
                      healthState.currentSignal?.heartRate.round() ??
                      (profile?['heart_rate'] != null ? int.tryParse(profile!['heart_rate'].toString().replaceAll(RegExp(r'[^0-9]'), '')) : null) ??
                      (healthState.averageHeartRate > 0
                          ? healthState.averageHeartRate.round()
                          : 78);
                  final String bp = profile?['blood_pressure']?.toString() ?? '120/80';
                  final double temp = healthState.currentSignal?.temperature ??
                      (profile?['temperature'] as num?)?.toDouble() ?? 36.6;
                  final int spo2 = healthState.currentSignal?.spO2?.round() ??
                      (profile?['spo2'] as num?)?.toInt() ??
                      (profile?['oxygen_saturation'] as num?)?.toInt() ?? 98;

                  final healthData = HealthDataEntity(
                    heartRate: heartRate,
                    bloodPressure: bp,
                    temperature: temp,
                    weight: weight,
                    height: height,
                    date: DateTime.now(),
                    riskScore: riskScore,
                    oxygenSaturation: spo2,
                  );

                  final currentUser = ref.read(authStateProvider).valueOrNull;
                  final isDoctor = currentUser?.role == UserRole.doctor;

                  await PDFReportService.generateAndShareReport(
                    userName: patient.name,
                    age: _computeAge(patient.dateOfBirth),
                    healthData: healthData,
                    profile: profile,
                    isDoctor: isDoctor,
                    recentPredictions: healthState.recentPredictions,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redButton,
                  foregroundColor: AppColors.redSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.shadowBlack25,
                ),
                child: Text(
                  'Download report'.tr(context),
                  style: AppTextStyles
                      .patientDetailPrimaryActionRedSurface16ExtraBold
                      .copyWith(
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 61,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1, color: AppColors.redDeep),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'Home'.tr(context),
                style:
                    const TextStyle(
                      color: AppColors.redDeep,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ).copyWith(
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
