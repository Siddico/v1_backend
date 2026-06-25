// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
// import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/stroke_prediction_logic.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';

class PatientPredictionSetupPage extends ConsumerStatefulWidget {
  const PatientPredictionSetupPage({super.key});

  @override
  ConsumerState<PatientPredictionSetupPage> createState() =>
      _PatientPredictionSetupPageState();
}

class _PatientPredictionSetupPageState
    extends ConsumerState<PatientPredictionSetupPage> {
  final _formKey = GlobalKey<FormState>();

  // Form input controllers and state values
  final _ageController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _bmiController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'Female';
  bool _hypertension = false;
  bool _heartDisease = false;
  bool _everMarried = false;
  String _workType = 'Private';
  String _residenceType = 'Urban';
  String _smokingStatus = 'never smoked';

  // AI Model V2 Specific Symptoms
  bool _chestPain = false;
  bool _irregularHeartbeat = false;
  bool _shortnessOfBreath = false;
  bool _fatigueWeakness = false;
  bool _dizziness = false;
  bool _swellingEdema = false;
  bool _neckJawPain = false;
  bool _excessiveSweating = false;
  bool _persistentCough = false;
  bool _nauseaVomiting = false;
  bool _chestDiscomfort = false;
  bool _coldHandsFeet = false;
  bool _snoringSleepApnea = false;
  bool _anxietyDoom = false;

  bool _isLoading = false;
  double? _calculatedRisk;
  String? _riskLabel;
  String? _explanation;
  List<String> _advice = [];

  String get _normalizedGender {
    final g = _gender.toLowerCase().trim();
    if (g.contains('female')) return 'Female';
    if (g.contains('male')) return 'Male';
    if (g.contains('other')) return 'Other';
    return 'Female';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _glucoseController.dispose();
    _bmiController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Pre-fill user profile info if available
  void _calculateBmi() {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    if (weight != null && weight > 0 && height != null && height > 0) {
      final double heightMeters = height / 100.0;
      final double calculatedBmi = weight / (heightMeters * heightMeters);
      _bmiController.text = calculatedBmi.toStringAsFixed(1);
    } else {
      _bmiController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateBmi);
    _heightController.addListener(_calculateBmi);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        if (user.gender != null) {
          final g = user.gender!.toLowerCase();
          if (g.contains('female')) {
            setState(() => _gender = 'Female');
          } else if (g.contains('male')) {
            setState(() => _gender = 'Male');
          } else {
            setState(() => _gender = 'Other');
          }
        }
        if (user.dateOfBirth != null) {
          try {
            final birthDate = DateTime.parse(user.dateOfBirth!);
            final age = DateTime.now().year - birthDate.year;
            setState(() => _ageController.text = age.toString());
          } catch (_) {}
        }
      }
      _loadPreviousData();
    });
  }

  Future<void> _loadPreviousData() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('patient_profile')
          .doc(user.id)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          if (data['gender'] != null) {
            final g = data['gender'].toString().toLowerCase().trim();
            if (g.contains('female')) {
              _gender = 'Female';
            } else if (g.contains('male')) {
              _gender = 'Male';
            } else {
              _gender = 'Other';
            }
          }
          if (data['hypertension'] != null) {
            _hypertension = data['hypertension'] == 1;
          }
          if (data['heart_disease'] != null) {
            _heartDisease = data['heart_disease'] == 1;
          }
          if (data['ever_married'] != null) {
            _everMarried = data['ever_married'] == 'Yes';
          }
          if (data['work_type'] != null) {
            final w = data['work_type'].toString().trim();
            _workType =
                [
                  'Private',
                  'Self-employed',
                  'Govt_job',
                  'Never_worked',
                  'children',
                ].firstWhere(
                  (item) => item.toLowerCase() == w.toLowerCase(),
                  orElse: () => 'Private',
                );
          }
          if (data['Residence_type'] != null) {
            final r = data['Residence_type'].toString().trim();
            _residenceType = ['Urban', 'Rural'].firstWhere(
              (item) => item.toLowerCase() == r.toLowerCase(),
              orElse: () => 'Urban',
            );
          }
          if (data['avg_glucose_level'] != null) {
            _glucoseController.text = (data['avg_glucose_level'] as num)
                .toStringAsFixed(1);
          }
          if (data['bmi'] != null) {
            _bmiController.text = (data['bmi'] as num).toStringAsFixed(1);
          }
          if (data['weight'] != null) {
            _weightController.text = (data['weight'] as num).toStringAsFixed(1);
          }
          if (data['height'] != null) {
            _heightController.text = (data['height'] as num).toStringAsFixed(1);
          }
          if (data['smoking_status'] != null) {
            final s = data['smoking_status'].toString().trim();
            _smokingStatus =
                [
                  'never smoked',
                  'formerly smoked',
                  'smokes',
                  'Unknown',
                ].firstWhere(
                  (item) => item.toLowerCase() == s.toLowerCase(),
                  orElse: () => 'never smoked',
                );
          }
          if (data['age'] != null) {
            _ageController.text = (data['age'] as num).toInt().toString();
          }
          if (data['chest_pain'] != null) _chestPain = data['chest_pain'] == 1;
          if (data['irregular_heartbeat'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _irregularHeartbeat = data['irregular_heartbeat'] == 1;
          if (data['shortness_of_breath'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _shortnessOfBreath = data['shortness_of_breath'] == 1;
          if (data['fatigue_weakness'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _fatigueWeakness = data['fatigue_weakness'] == 1;
          if (data['dizziness'] != null) _dizziness = data['dizziness'] == 1;
          if (data['swelling_edema'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _swellingEdema = data['swelling_edema'] == 1;
          if (data['neck_jaw_pain'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _neckJawPain = data['neck_jaw_pain'] == 1;
          if (data['excessive_sweating'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _excessiveSweating = data['excessive_sweating'] == 1;
          if (data['persistent_cough'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _persistentCough = data['persistent_cough'] == 1;
          if (data['nausea_vomiting'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _nauseaVomiting = data['nausea_vomiting'] == 1;
          if (data['chest_discomfort'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _chestDiscomfort = data['chest_discomfort'] == 1;
          if (data['cold_hands_feet'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _coldHandsFeet = data['cold_hands_feet'] == 1;
          if (data['snoring_sleep_apnea'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _snoringSleepApnea = data['snoring_sleep_apnea'] == 1;
          if (data['anxiety_doom'] != null)
            // ignore: curly_braces_in_flow_control_structures
            _anxietyDoom = data['anxiety_doom'] == 1;
        });
      }
    } catch (_) {}
  }

  Future<void> _calculateAndPredict() async {
    if (!_formKey.currentState!.validate()) return;

    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';

    setState(() {
      _isLoading = true;
    });

    final double age = double.tryParse(_ageController.text) ?? 0.0;
    final double glucose = double.tryParse(_glucoseController.text) ?? 0.0;
    final double bmi = double.tryParse(_bmiController.text) ?? 0.0;

    final String huggingFaceApiUrl = dotenv.env['HUGGING_FACE_API_URL'] ?? '';

    if (huggingFaceApiUrl.isEmpty) {
      if (mounted) {
        AppToast.show(
          context,
          'API URL is not configured in .env file'.tr(context),
          type: AppToastType.error,
          translate: false,
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    double risk = 0.0;

    try {
      final response = await http
          .post(
            Uri.parse(huggingFaceApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "age": age.toInt(),
              "gender": _normalizedGender,
              "chest_pain": _chestPain ? 1 : 0,
              "high_blood_pressure": _hypertension ? 1 : 0,
              "irregular_heartbeat": _irregularHeartbeat ? 1 : 0,
              "shortness_of_breath": _shortnessOfBreath ? 1 : 0,
              "fatigue_weakness": _fatigueWeakness ? 1 : 0,
              "dizziness": _dizziness ? 1 : 0,
              "swelling_edema": _swellingEdema ? 1 : 0,
              "neck_jaw_pain": _neckJawPain ? 1 : 0,
              "excessive_sweating": _excessiveSweating ? 1 : 0,
              "persistent_cough": _persistentCough ? 1 : 0,
              "nausea_vomiting": _nauseaVomiting ? 1 : 0,
              "chest_discomfort": _chestDiscomfort ? 1 : 0,
              "cold_hands_feet": _coldHandsFeet ? 1 : 0,
              "snoring_sleep_apnea": _snoringSleepApnea ? 1 : 0,
              "anxiety_doom": _anxietyDoom ? 1 : 0,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        risk = (data['stroke_risk_probability'] as num).toDouble();
        if (mounted) {
          AppToast.show(
            context,
            isArabic
                ? 'نجاح! تم الاتصال بنموذج الذكاء الاصطناعي. الخطر: ${(risk * 100).toStringAsFixed(1)}%'
                : 'Success! AI Model connected. Risk: ${(risk * 100).toStringAsFixed(1)}%',
            type: AppToastType.success,
            translate: false,
          );
        }
      } else {
        throw Exception(
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on TimeoutException {
      if (mounted) {
        AppToast.show(
          context,
          isArabic
              ? 'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت.'
              : 'Connection timeout. Please check your internet connection.',
          type: AppToastType.error,
          translate: false,
        );
      }
      setState(() => _isLoading = false);
      return;
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          isArabic ? 'خطأ في نموذج الذكاء الاصطناعي: $e' : 'AI Model Error: $e',
          type: AppToastType.error,
          translate: false,
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final results = StrokePredictionLogic.generateExplanationAndAdvice(
      age: age,
      hypertension: _hypertension,
      heartDisease: _heartDisease,
      avgGlucoseLevel: glucose,
      bmi: bmi,
      smokingStatus: _smokingStatus,
      chestPain: _chestPain,
      irregularHeartbeat: _irregularHeartbeat,
      shortnessOfBreath: _shortnessOfBreath,
      fatigueWeakness: _fatigueWeakness,
      dizziness: _dizziness,
      swellingEdema: _swellingEdema,
      neckJawPain: _neckJawPain,
      excessiveSweating: _excessiveSweating,
      persistentCough: _persistentCough,
      nauseaVomiting: _nauseaVomiting,
      chestDiscomfort: _chestDiscomfort,
      coldHandsFeet: _coldHandsFeet,
      snoringSleepApnea: _snoringSleepApnea,
      anxietyDoom: _anxietyDoom,
      languageCode: lang,
    );

    setState(() {
      _calculatedRisk = risk;
      _riskLabel = StrokePredictionLogic.getStrokeRiskLabel(risk);
      _explanation = results['explanation'] as String;
      _advice = List<String>.from(results['advice']);
      _isLoading = false;
    });
  }

  Future<void> _saveAndProceed() async {
    if (_calculatedRisk == null) return;

    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';

    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        AppToast.show(
          context,
          isArabic ? 'تم حفظ التقييم بنجاح' : 'Assessment saved successfully',
          type: AppToastType.success,
        );
      }

      await ref.refresh(authStateProvider.future);

      if (mounted) {
        context.go(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          isArabic
              ? 'خطأ أثناء حفظ التقييم: $e'
              : 'Error saving assessment: $e',
          type: AppToastType.error,
          translate: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final themeFamily = isArabic ? 'Cairo' : 'Poppins';
    final primaryTheme = AppColors.tealTheme().copyWith(
      textTheme: AppColors.tealTheme().textTheme.apply(fontFamily: themeFamily),
    );

    // final user = ref.watch(authStateProvider).valueOrNull;
    // final isOnboarding = user == null || user.aiRiskStrokeRate == null;

    return Theme(
      data: primaryTheme,
      child: PopScope(
        canPop: true,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Stroke Risk Assessment'.tr(context),
            onBack: () => Navigator.pop(context),
          ),
          body: _isLoading
              ? _buildCustomLoadingIndicator()
              : _calculatedRisk != null
              ? _buildResultScreen()
              : _buildFormScreen(),
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealSurface, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Top Gradient Cover Header with modern abstract glassmorphism
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.tealPrimaryDark,
                      AppColors.tealPrimarySoft,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealPrimaryDark,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Abstract glowing blob 1
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Abstract glowing blob 2
                    Positioned(
                      left: -80,
                      bottom: -80,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.tealAccent.withValues(alpha: 0.15),
                              Colors.tealAccent.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Glassmorphism Blur Layer
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: const SizedBox(),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome!'.tr(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your medical details to get started'
                                      .tr(context),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Heartbeat or medical icon decoration
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.monitor_heart_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form container with overlapping overlay
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard(
                          title: 'Personal & Demographic Info'.tr(context),
                          icon: Icons.person_outline_rounded,
                          children: [
                            // Age & Gender in row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _buildTextField(
                                    controller: _ageController,
                                    label: 'Age'.tr(context),
                                    hint: 'e.g. 45',
                                    prefixIcon: Icons.calendar_today_outlined,
                                    suffixUnit: 'years',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a valid age'.tr(
                                          context,
                                        );
                                      }
                                      final age = int.tryParse(val);
                                      if (age == null ||
                                          age <= 0 ||
                                          age > 120) {
                                        return 'Please enter a valid age'.tr(
                                          context,
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: _buildGenderDropdown(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Marriage Toggle
                            _buildPremiumToggleCard(
                              title: 'Ever Married'.tr(context),
                              value: _everMarried,
                              icon: Icons.people_outline_rounded,
                              onChanged: (val) =>
                                  setState(() => _everMarried = val),
                            ),
                            const SizedBox(height: 16),

                            // Work & Residence dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Work Type'.tr(context),
                                    value: _workType,
                                    prefixIcon: Icons.work_outline_rounded,
                                    items: [
                                      'Private',
                                      'Self-employed',
                                      'Govt_job',
                                      'Never_worked',
                                      'children',
                                    ],
                                    onChanged: (val) => setState(
                                      () => _workType = val ?? 'Private',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Residence Type'.tr(context),
                                    value: _residenceType,
                                    prefixIcon: Icons.home_outlined,
                                    items: ['Urban', 'Rural'],
                                    onChanged: (val) => setState(
                                      () => _residenceType = val ?? 'Urban',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildCard(
                          title: 'Medical Vitals'.tr(context),
                          icon: Icons.healing_outlined,
                          children: [
                            // Hypertension & Heart Disease Toggles
                            _buildPremiumToggleCard(
                              title: 'Hypertension (High BP)'.tr(context),
                              value: _hypertension,
                              icon: Icons.favorite_rounded,
                              onChanged: (val) =>
                                  setState(() => _hypertension = val),
                            ),
                            const SizedBox(height: 12),
                            _buildPremiumToggleCard(
                              title: 'Heart Disease'.tr(context),
                              value: _heartDisease,
                              icon: Icons.monitor_heart_rounded,
                              onChanged: (val) =>
                                  setState(() => _heartDisease = val),
                            ),
                            const SizedBox(height: 16),

                            // Glucose level and BMI inputs
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _glucoseController,
                                  label: 'Average Glucose Level (mg/dL)'.tr(
                                    context,
                                  ),
                                  hint: 'e.g. 105.4',
                                  prefixIcon: Icons.opacity_rounded,
                                  suffixUnit: 'mg/dL',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter average glucose level'
                                          .tr(context);
                                    }
                                    final double? numVal = double.tryParse(val);
                                    if (numVal == null || numVal <= 0) {
                                      return 'Please enter average glucose level'
                                          .tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _bmiController,
                                  label: 'BMI (Body Mass Index)'.tr(context),
                                  hint: 'e.g. 26.5',
                                  prefixIcon: Icons.monitor_weight_outlined,
                                  suffixUnit: 'kg/m²',
                                  readOnly: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter BMI'.tr(context);
                                    }
                                    final double? numVal = double.tryParse(val);
                                    if (numVal == null || numVal <= 0) {
                                      return 'Please enter BMI'.tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    'Don\'t know your BMI? Enter height and weight to calculate:'
                                        .tr(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.neutral500,
                                      fontFamily: AppTextStyles.isArabic
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _heightController,
                                        label: 'Height (cm)'.tr(context),
                                        hint: 'e.g. 170',
                                        prefixIcon: Icons.height_rounded,
                                        suffixUnit: 'cm',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please enter height'.tr(
                                              context,
                                            );
                                          }
                                          final double? numVal =
                                              double.tryParse(val);
                                          if (numVal == null || numVal <= 0) {
                                            return 'Please enter a valid height'
                                                .tr(context);
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _weightController,
                                        label: 'Weight (kg)'.tr(context),
                                        hint: 'e.g. 70',
                                        prefixIcon: Icons.scale_rounded,
                                        suffixUnit: 'kg',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please enter weight'.tr(
                                              context,
                                            );
                                          }
                                          final double? numVal =
                                              double.tryParse(val);
                                          if (numVal == null || numVal <= 0) {
                                            return 'Please enter a valid weight'
                                                .tr(context);
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Smoking Status Selector
                            _buildDropdown(
                              label: 'Smoking Status'.tr(context),
                              value: _smokingStatus,
                              prefixIcon: Icons.smoke_free_rounded,
                              items: [
                                'never smoked',
                                'formerly smoked',
                                'smokes',
                                'Unknown',
                              ],
                              onChanged: (val) => setState(
                                () => _smokingStatus = val ?? 'never smoked',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildCard(
                          title: 'Clinical Symptoms (For AI Prediction)'.tr(
                            context,
                          ),
                          icon: Icons.monitor_heart_rounded,
                          children: [
                            _buildPremiumToggleCard(
                              title: 'Chest Pain'.tr(context),
                              value: _chestPain,
                              icon: Icons.monitor_heart_outlined,
                              onChanged: (val) =>
                                  setState(() => _chestPain = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Irregular Heartbeat'.tr(context),
                              value: _irregularHeartbeat,
                              icon: Icons.favorite_border_rounded,
                              onChanged: (val) =>
                                  setState(() => _irregularHeartbeat = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Shortness of Breath'.tr(context),
                              value: _shortnessOfBreath,
                              icon: Icons.air_rounded,
                              onChanged: (val) =>
                                  setState(() => _shortnessOfBreath = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Fatigue & Weakness'.tr(context),
                              value: _fatigueWeakness,
                              icon: Icons.battery_alert_rounded,
                              onChanged: (val) =>
                                  setState(() => _fatigueWeakness = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Dizziness'.tr(context),
                              value: _dizziness,
                              icon: Icons.rotate_right_rounded,
                              onChanged: (val) =>
                                  setState(() => _dizziness = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Swelling Edema'.tr(context),
                              value: _swellingEdema,
                              icon: Icons.accessibility_new_rounded,
                              onChanged: (val) =>
                                  setState(() => _swellingEdema = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Neck/Jaw Pain'.tr(context),
                              value: _neckJawPain,
                              icon: Icons.sick_outlined,
                              onChanged: (val) =>
                                  setState(() => _neckJawPain = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Excessive Sweating'.tr(context),
                              value: _excessiveSweating,
                              icon: Icons.water_drop_outlined,
                              onChanged: (val) =>
                                  setState(() => _excessiveSweating = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Persistent Cough'.tr(context),
                              value: _persistentCough,
                              icon: Icons.coronavirus_outlined,
                              onChanged: (val) =>
                                  setState(() => _persistentCough = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Nausea & Vomiting'.tr(context),
                              value: _nauseaVomiting,
                              icon: Icons.sanitizer_outlined,
                              onChanged: (val) =>
                                  setState(() => _nauseaVomiting = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Chest Discomfort'.tr(context),
                              value: _chestDiscomfort,
                              icon: Icons.warning_amber_rounded,
                              onChanged: (val) =>
                                  setState(() => _chestDiscomfort = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Cold Hands & Feet'.tr(context),
                              value: _coldHandsFeet,
                              icon: Icons.ac_unit_rounded,
                              onChanged: (val) =>
                                  setState(() => _coldHandsFeet = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Snoring / Sleep Apnea'.tr(context),
                              value: _snoringSleepApnea,
                              icon: Icons.bedtime_outlined,
                              onChanged: (val) =>
                                  setState(() => _snoringSleepApnea = val),
                            ),
                            _buildPremiumToggleCard(
                              title: 'Feeling of Anxiety/Doom'.tr(context),
                              value: _anxietyDoom,
                              icon: Icons.psychology_outlined,
                              onChanged: (val) =>
                                  setState(() => _anxietyDoom = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Calculate Risk Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tealP.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealP,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _calculateAndPredict,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Calculate Risk'.tr(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'ar'
                                      ? Icons.arrow_back_ios_new_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final int percentage = (_calculatedRisk! * 100).toInt();
    final Color riskColor = _riskLabel == 'high'
        ? AppColors.redPrimary
        : _riskLabel == 'medium'
        ? AppColors.warningYellow
        : AppColors.successGreen;

    final String localRiskLabel = _riskLabel == 'high'
        ? 'High Risk'.tr(context)
        : _riskLabel == 'medium'
        ? 'Moderate Risk'.tr(context)
        : 'Low Risk'.tr(context);

    return Scaffold(
      backgroundColor: AppColors.tealBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'Assessment Result'.tr(context),
              style: TextStyle(
                color: AppColors.tealPrimaryDark,
                fontSize: 22,
                fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'Cairo'
                    : 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Circular Radial Risk Score indicator with outer glowing container
            Center(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealPrimaryDark.withValues(alpha: 0.08),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 154,
                      height: 154,
                      child: CircularProgressIndicator(
                        value: _calculatedRisk,
                        strokeWidth: 12,
                        color: riskColor,
                        backgroundColor: Colors.grey.shade100,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.tealPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stroke Risk'.tr(context),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Risk category pill badge with custom icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: riskColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: riskColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _riskLabel == 'high'
                        ? Icons.gpp_bad_rounded
                        : _riskLabel == 'medium'
                        ? Icons.gpp_maybe_rounded
                        : Icons.gpp_good_rounded,
                    color: riskColor == AppColors.warningYellow
                        ? Colors.orange.shade800
                        : riskColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localRiskLabel,
                    style: TextStyle(
                      color: riskColor == AppColors.warningYellow
                          ? Colors.orange.shade800
                          : riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Dynamic Medical Explanation Card
            _buildInfoCard(
              title: 'Explanation'.tr(context),
              icon: Icons.analytics_outlined,
              accentColor: AppColors.tealIconActive,
              child: Text(
                _explanation ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.neutral300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actionable Doctor's Advice List Card
            _buildInfoCard(
              title: 'Doctor\'s Advice'.tr(context),
              icon: Icons.assignment_turned_in_outlined,
              accentColor: riskColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _advice.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: riskColor == AppColors.warningYellow
                                ? Colors.orange.shade800
                                : riskColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.neutral300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 36),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.tealP,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _calculatedRisk = null;
                      });
                    },
                    child: Text(
                      'Back'.tr(context),
                      style: const TextStyle(
                        color: AppColors.tealP,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.tealP,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveAndProceed,
                    child: Text(
                      'Save & Continue'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Font style helper that resolves Cairo/Poppins dynamically
  TextStyle _getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Visual widgets helpers
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.tealBorderLight.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimaryDark.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.tealSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.tealP, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: _getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.tealSurface, thickness: 1.5),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? suffixUnit,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: _getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.tealPrimaryDark,
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: AppColors.redPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          style: _getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint.tr(context),
            hintStyle: _getTextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.tealP, size: 20),
            suffixText: suffixUnit?.tr(context),
            suffixStyle: _getTextStyle(
              color: AppColors.tealPrimaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.tealIconActive,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.redPrimary.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.redPrimary,
                width: 1.8,
              ),
            ),
            errorStyle: _getTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.redPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gender'.tr(context),
              style: _getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.tealPrimaryDark,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: AppColors.redPrimary.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(_normalizedGender),
          initialValue: _normalizedGender,
          style: _getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.transgender_rounded,
              color: AppColors.tealP,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.tealIconActive,
                width: 1.8,
              ),
            ),
          ),
          items: ['Female', 'Male', 'Other'].map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val.tr(context),
                style: _getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _gender = val);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData prefixIcon,
    required void Function(String?) onChanged,
  }) {
    final normalizedValue = items.firstWhere(
      (item) => item.toLowerCase() == value.toLowerCase().trim(),
      orElse: () => items.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: _getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.tealPrimaryDark,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: AppColors.redPrimary.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(normalizedValue),
          initialValue: normalizedValue,
          isExpanded: true,
          style: _getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: AppColors.tealP, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.tealIconActive,
                width: 1.8,
              ),
            ),
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val.tr(context),
                style: _getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPremiumToggleCard({
    required String title,
    required bool value,
    required IconData icon,
    required void Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.tealSurface.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.tealIconActive : Colors.grey.shade200,
          width: value ? 1.5 : 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.tealP.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? AppColors.tealP : Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: _getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.tealPrimaryDark : AppColors.neutral300,
              ),
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onChanged(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: !value ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: !value
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'No'.tr(context),
                      style: _getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !value
                            ? Colors.grey.shade800
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onChanged(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: value ? AppColors.tealP : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: value
                          ? [
                              BoxShadow(
                                color: AppColors.tealP.withValues(alpha: 0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Yes'.tr(context),
                      style: _getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimaryDark.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: _getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.tealSurface, thickness: 1.5),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomLoadingIndicator() {
    final hasCalculated = _calculatedRisk != null;
    final text = hasCalculated
        ? (Localizations.localeOf(context).languageCode == 'ar'
              ? 'جاري حفظ التقييم...'
              : 'Saving assessment...')
        : 'Calculating stroke risk...'.tr(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularLoadingIndicator(size: 90),
          const SizedBox(height: 24),
          Text(
            text,
            style: _getTextStyle(
              color: AppColors.tealPrimaryDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingHeartIcon extends StatefulWidget {
  const _PulsingHeartIcon();

  @override
  State<_PulsingHeartIcon> createState() => _PulsingHeartIconState();
}

class _PulsingHeartIconState extends State<_PulsingHeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(
        Icons.favorite_rounded,
        color: AppColors.tealPrimaryDark,
        size: 36,
      ),
    );
  }
}

