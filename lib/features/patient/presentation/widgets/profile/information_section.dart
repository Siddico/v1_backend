import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile/two_column_pair_line.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/chat_quick_button.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/information_group.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/mini_action_card.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/pair_line.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';
import 'package:grad_imp_1/shared/domain/entities/user_entity.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/core/utils/stroke_prediction_logic.dart';
import 'package:grad_imp_1/core/utils/app_tutorial_helper.dart';

class InformationSection extends ConsumerStatefulWidget {
  final UserEntity patient;

  const InformationSection({super.key, required this.patient});

  @override
  ConsumerState<InformationSection> createState() => _InformationSectionState();
}

class _InformationSectionState extends ConsumerState<InformationSection> {
  bool _aiPredictionExpanded = true;
  bool _medicalDataExpanded = false;
  bool _personalDataExpanded = false;
  // ignore: unused_field, prefer_final_fields
  bool _historyExpanded = false;
  
  Map<String, dynamic>? _medicalData;
  bool _isLoadingMedicalData = false;
  
  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  Future<void> _fetchMedicalData() async {
    setState(() => _isLoadingMedicalData = true);
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        ApiConstants.doctorMedicalData,
        queryParameters: {'patient_id': widget.patient.id},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // the response returns an array or single object, assuming array of data or single object
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          setState(() => _medicalData = data.first);
        } else if (data is Map<String, dynamic>) {
          setState(() => _medicalData = data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching medical data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMedicalData = false);
    }
  }

  String _calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return 'N/A';
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      var age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return '$age';
    } catch (_) {
      return 'N/A';
    }
  }

  Widget _buildToggleHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: isExpanded
            ? const EdgeInsets.symmetric(vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.transparent : null,
          gradient: !isExpanded
              ? const LinearGradient(
                  colors: [Color(0xFFFFF2F2), Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: !isExpanded
              ? Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.redMaroon.withOpacity(0.15),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles
                    .patientDoctorDetailSectionTitleBlackNeutral20ExtraBold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isExpanded ? AppColors.black : AppColors.redDeep,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    // ignore: unused_local_variable
    final isDoctorView = currentUser?.role == UserRole.doctor;
    final profile = widget.patient.patientProfile;
    
    // Fallback to static profile if medical data from API is not loaded
    final diagnosis = _medicalData?['diagnosis']?.toString() ?? profile?['diagnosis']?.toString() ?? 'Ischemic Stroke';
    final hr = _medicalData?['heart_rate'] != null ? '${_medicalData?['heart_rate']} bpm' : profile?['heart_rate']?.toString() ?? '78 bpm';
    final bp = _medicalData?['blood_pressure']?.toString() ?? profile?['blood_pressure']?.toString() ?? '120 / 80 mmHg';
    final glucose = _medicalData?['blood_glucose'] != null ? '${_medicalData?['blood_glucose']} mg/dL' : profile?['blood_glucose']?.toString() ?? '92 mg/dL';
    final cholesterol = _medicalData?['cholesterol'] != null ? '${_medicalData?['cholesterol']} mg/dL' : profile?['cholesterol']?.toString() ?? '180 mg/dL';
    final lastUpload = profile?['last_upload']?.toString() ?? '10 Jan 2026';
    final doctorNotes = _medicalData?['notes']?.toString() ?? profile?['doctor_notes']?.toString() ?? 'None';

    final genderText =
        widget.patient.gender ?? profile?['gender']?.toString() ?? 'N/A';
    final dob =
        (widget.patient.dateOfBirth != null &&
            widget.patient.dateOfBirth!.isNotEmpty)
        ? widget.patient.dateOfBirth
        : profile?['date_of_birth']?.toString();
    final ageText = _calculateAge(dob);
    final displayId = widget.patient.id.length > 6
        ? '#${widget.patient.id.substring(0, 6)}'
        : '#${widget.patient.id}';
    final phoneText =
        widget.patient.phone ?? profile?['phone']?.toString() ?? 'N/A';
    final emergencyPhoneText =
        profile?['emergency_number']?.toString() ?? profile?['emergency_contact_phone']?.toString() ?? 'N/A';

    final hasAiPrediction = profile?['ai_risk_stroke_rate'] != null;
    final aiRiskScore = profile?['ai_risk_stroke_rate'] != null
        ? (profile?['ai_risk_stroke_rate'] as num).toDouble()
        : null;

    Color riskColor = AppColors.successGreen;
    String riskLabel = 'Low Risk'.tr(context);
    if (aiRiskScore != null) {
      if (aiRiskScore >= 50.0) {
        riskColor = AppColors.redPrimary;
        riskLabel = 'High Risk'.tr(context);
      } else if (aiRiskScore >= 20.0) {
        riskColor = AppColors.warningYellow;
        riskLabel = 'Moderate Risk'.tr(context);
      }
    }

    final aiHypertension = profile?['hypertension'] == 1
        ? 'Yes'.tr(context)
        : 'No'.tr(context);
    final aiHeartDisease = profile?['heart_disease'] == 1
        ? 'Yes'.tr(context)
        : 'No'.tr(context);
    final aiEverMarried = (profile?['ever_married']?.toString() ?? 'No').tr(
      context,
    );
    final aiWorkType = (profile?['work_type']?.toString() ?? 'Private').tr(
      context,
    );
    final aiResidenceType = (profile?['Residence_type']?.toString() ?? 'Urban')
        .tr(context);
    final aiGlucose = profile?['avg_glucose_level'] != null
        ? '${(profile?['avg_glucose_level'] as num).toStringAsFixed(1)} mg/dL'
        : 'N/A';
    final aiBmi = profile?['bmi'] != null
        // ignore: unnecessary_string_interpolations
        ? '${(profile?['bmi'] as num).toStringAsFixed(1)}'
        : 'N/A';
    final aiSmoking = (profile?['smoking_status']?.toString() ?? 'never smoked')
        .tr(context);

    // Dynamically calculate explanation and advice based on language
    final lang = Localizations.localeOf(context).languageCode;
    final ageVal = double.tryParse(_calculateAge(dob)) ?? 45.0;
    final aiHypertensionBool = profile?['hypertension'] == 1;
    final aiHeartDiseaseBool = profile?['heart_disease'] == 1;
    final aiGlucoseVal = profile?['avg_glucose_level'] != null
        ? (profile?['avg_glucose_level'] as num).toDouble()
        : 100.0;
    final aiBmiVal = profile?['bmi'] != null
        ? (profile?['bmi'] as num).toDouble()
        : 22.0;
    final aiSmokingStr =
        profile?['smoking_status']?.toString() ?? 'never smoked';

    final generatedExplanationAdvice =
        StrokePredictionLogic.generateExplanationAndAdvice(
          age: ageVal,
          hypertension: aiHypertensionBool,
          heartDisease: aiHeartDiseaseBool,
          avgGlucoseLevel: aiGlucoseVal,
          bmi: aiBmiVal,
          smokingStatus: aiSmokingStr,
          chestPain: profile?['chest_pain'] == 1,
          irregularHeartbeat: profile?['irregular_heartbeat'] == 1,
          shortnessOfBreath: profile?['shortness_of_breath'] == 1,
          fatigueWeakness: profile?['fatigue_weakness'] == 1,
          dizziness: profile?['dizziness'] == 1,
          swellingEdema: profile?['swelling_edema'] == 1,
          neckJawPain: profile?['neck_jaw_pain'] == 1,
          excessiveSweating: profile?['excessive_sweating'] == 1,
          persistentCough: profile?['persistent_cough'] == 1,
          nauseaVomiting: profile?['nausea_vomiting'] == 1,
          chestDiscomfort: profile?['chest_discomfort'] == 1,
          coldHandsFeet: profile?['cold_hands_feet'] == 1,
          snoringSleepApnea: profile?['snoring_sleep_apnea'] == 1,
          anxietyDoom: profile?['anxiety_doom'] == 1,
          languageCode: lang,
        );

    final aiExplanation = generatedExplanationAdvice['explanation'] as String;
    final List<dynamic> aiAdviceList =
        generatedExplanationAdvice['advice'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAiPrediction) ...[
          _buildToggleHeader(
            title: 'Stroke Risk Assessment'.tr(context),
            isExpanded: _aiPredictionExpanded,
            onTap: () {
              setState(() {
                _aiPredictionExpanded = !_aiPredictionExpanded;
              });
            },
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.tealPrimaryDark.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Stroke Risk percentage'.tr(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral300,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                          // ignore: deprecated_member_use
                          border: Border.all(color: riskColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${aiRiskScore!.toInt()}% - $riskLabel',
                          style: TextStyle(
                            color: riskColor == AppColors.warningYellow
                                ? Colors.orange.shade800
                                : riskColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),
                  InformationGroup(
                    rows: [
                      PairLine(
                        label: 'Hypertension (High BP)'.tr(context),
                        value: aiHypertension,
                      ),
                      PairLine(
                        label: 'Heart Disease'.tr(context),
                        value: aiHeartDisease,
                      ),
                      PairLine(
                        label: 'Average Glucose Level'.tr(context),
                        value: aiGlucose,
                      ),
                      PairLine(
                        label: 'BMI (Body Mass Index)'.tr(context),
                        value: aiBmi,
                      ),
                      PairLine(
                        label: 'Smoking Status'.tr(context),
                        value: aiSmoking,
                      ),
                      PairLine(
                        label: 'Work Type'.tr(context),
                        value: aiWorkType,
                      ),
                      PairLine(
                        label: 'Residence Type'.tr(context),
                        value: aiResidenceType,
                      ),
                      PairLine(
                        label: 'Ever Married'.tr(context),
                        value: aiEverMarried,
                      ),
                    ],
                  ),
                  if (aiExplanation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Explanation'.tr(context),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealPrimaryDark,
                        fontFamily: AppTextStyles.isArabic
                            ? 'Cairo'
                            : 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aiExplanation,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral300,
                        height: 1.4,
                        fontFamily: AppTextStyles.isArabic
                            ? 'Cairo'
                            : 'Poppins',
                      ),
                    ),
                  ],
                  if (aiAdviceList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Doctor\'s Advice'.tr(context),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealPrimaryDark,
                        fontFamily: AppTextStyles.isArabic
                            ? 'Cairo'
                            : 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...aiAdviceList.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: AppColors.tealIconActive,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.neutral300,
                                  fontFamily: AppTextStyles.isArabic
                                      ? 'Cairo'
                                      : 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _aiPredictionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],

        KeyedSubtree(
          key: AppTutorialHelper.doctorPatientDetailsContentKey,
          child: _buildToggleHeader(
            title: 'Medical data'.tr(context),
            isExpanded: _medicalDataExpanded,
            onTap: () {
              setState(() {
                _medicalDataExpanded = !_medicalDataExpanded;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _isLoadingMedicalData 
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.redDeep)),
                )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              InformationGroup(
                rows: [
                  PairLine(label: 'Diagnosis'.tr(context), value: diagnosis),
                  PairLine(label: 'Heart Rate (HR)'.tr(context), value: hr),
                  PairLine(label: 'Blood Pressure (BP)'.tr(context), value: bp),
                  PairLine(label: 'Blood Glucose'.tr(context), value: glucose),
                  PairLine(
                    label: 'Cholesterol'.tr(context),
                    value: cholesterol,
                  ),
                  PairLine(
                    label: 'Last ECG / PPG Upload'.tr(context),
                    value: lastUpload,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text(
                            'Doctor notes',
                            style:
                                AppTextStyles.patientDetailLabelBlack14SemiBold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorNotes,
                          style: AppTextStyles.patientDetailValueBlack14Light,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MiniActionCard(
                        label: 'Download',
                        iconImage: AppImages.downloadIconPdfSvg,
                        onTap: () {
                          AppToast.show(
                            context,
                            'Coming soon',
                            type: AppToastType.info,
                            role: UserRole.doctor,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      MiniActionCard(
                        label: 'Update',
                        iconImage: AppImages.updateIconSvg,
                        onTap: () {
                          AppToast.show(
                            context,
                            'Coming soon',
                            type: AppToastType.info,
                            role: UserRole.doctor,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _medicalDataExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'Personal data'.tr(context),
          isExpanded: _personalDataExpanded,
          onTap: () {
            setState(() {
              _personalDataExpanded = !_personalDataExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              TwoColumnPairLine(
                label1: 'Full name'.tr(context),
                value1: widget.patient.name.isEmpty
                    ? 'Patient'.tr(context)
                    : widget.patient.name,
                label2: 'Gender'.tr(context),
                value2: genderText.tr(context),
              ),
              TwoColumnPairLine(
                label1: 'Age'.tr(context),
                value1: ageText,
                label2: 'ID'.tr(context),
                value2: displayId,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PairLine(
                            label: 'Phone'.tr(context),
                            value: phoneText,
                          ),
                          const SizedBox(height: 10),
                          PairLine(
                            label: 'Phone Emergency'.tr(context),
                            value: emergencyPhoneText,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Center(child: ChatQuickButton(patient: widget.patient)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          crossFadeState: _personalDataExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        // _buildToggleHeader(
        //   title: 'Prediction History'.tr(context),
        //   isExpanded: _historyExpanded,
        //   onTap: () {
        //     setState(() {
        //       _historyExpanded = !_historyExpanded;
        //     });
        //   },
        // ),
        // const SizedBox(height: 8),
        // AnimatedCrossFade(
        //   firstChild: const SizedBox.shrink(),
        //   secondChild: Column(
        //     children: [
        //       const SizedBox(height: 10),
        //       PredictionHistorySection(
        //         patientId: widget.patient.id,
        //         isDoctor: isDoctorView,
        //       ),
        //       const SizedBox(height: 10),
        //     ],
        //   ),
        //   crossFadeState: _historyExpanded
        //       ? CrossFadeState.showSecond
        //       : CrossFadeState.showFirst,
        //   duration: const Duration(milliseconds: 250),
        // ),
      ],
    );
  }
}
