import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/chart_navigation_provider.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_tutorial_helper.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/floating_notification_button.dart';
import '../../../../shared/presentation/widgets/floating_chatbot_button.dart';
import '../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../../../../features/patient/presentation/controllers/patient_profile_providers.dart';
import '../controllers/wellness_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../widgets/data_upload_card.dart';
import '../widgets/patient_greeting_header.dart';
import '../widgets/risk_stroke_card.dart';
import '../../../../core/utils/status_mapper.dart';
import '../../../../core/localization/app_localizations.dart';

class WellnessPage extends ConsumerStatefulWidget {
  const WellnessPage({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends ConsumerState<WellnessPage> {
  late int _currentNavIndex;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.currentIndex == 0) {
        final uid = ref.read(authStateProvider).valueOrNull?.id;
        AppTutorialHelper.showPatientTutorialIfNeeded(context, uid);
      }
    });
  }

  @override
  void didUpdateWidget(WellnessPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentNavIndex = widget.currentIndex;
      if (_currentNavIndex == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final uid = ref.read(authStateProvider).valueOrNull?.id;
            AppTutorialHelper.showPatientTutorialIfNeeded(context, uid);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.valueOrNull?.id;
    final patientDetailsState = userId != null
        ? ref.watch(patientDetailsProvider(userId))
        : null;
    final latestHealthData = ref.watch(latestHealthDataProvider);

    final userName = authState.when(
      data: (user) => user?.name ?? 'Patient',
      loading: () => '...',
      // ignore: unnecessary_underscores
      error: (_, __) => 'Patient',
    );

    final healthState = userId != null
        ? ref.watch(healthMonitoringControllerProviderFamily(userId))
        : null;

    final patient = patientDetailsState?.valueOrNull;

    final rawRiskScore =
        patient?.aiRiskStrokeRate?.toDouble() ??
        healthState?.currentPrediction?.riskScore ??
        latestHealthData?.riskScore ??
        46;
    final riskScore = rawRiskScore <= 1.0 ? rawRiskScore * 100 : rawRiskScore;
    final oxygenSaturation = latestHealthData?.oxygenSaturation ?? 98;

    final derivedStatus = StatusMapper.resolveStatus(
      prediction: healthState?.currentPrediction,
      patientStatus:
          patient?.status ?? patient?.patientProfile?['status']?.toString(),
      riskScore: riskScore.toDouble(),
    );

    final isAssessed = patient?.aiRiskStrokeRate != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: -198,
                        right: 0,
                        child: Container(
                          height: 469,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [AppColors.tealPrimarySoft, Colors.white],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusXXL,
                            ),
                          ),
                        ),
                      ),

                      AppBarControls(
                        isDarkMode: _isDarkMode,
                        onDarkModeToggle: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                        onLanguageSelect: () {},
                        darkModeToggleLightColor: const Color(0xFFBBE5EB),
                        darkModeToggleDarkColor: const Color(0xFF1B808E),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 115),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: PatientGreetingHeader(
                                    userName: userName,
                                    profileImageUrl:
                                        authState.valueOrNull?.photoUrl,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 31),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: KeyedSubtree(
                                  key: AppTutorialHelper.patientRiskCardKey,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isAssessed) {
                                          context.push(
                                            AppConstants.routePredictionSetup,
                                          );
                                        }
                                      },
                                      child: RiskStrokeCard(
                                        percentage: riskScore.toDouble(),
                                        status: derivedStatus,
                                        isAssessed: isAssessed,
                                        description: !isAssessed
                                            ? ''
                                            : derivedStatus == 'critical'
                                            ? 'You are at high risk for stroke. Please consult a doctor immediately.'
                                                  .tr(context)
                                            : derivedStatus == 'stable'
                                            ? 'You are in the safe zone for stroke risk.'
                                                  .tr(context)
                                            : 'Your stroke risk is elevated. Please monitor your health.'
                                                  .tr(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 30,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overview'.tr(context),
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles
                                            .chartCardTitleTealDarker20ExtraBold
                                            .copyWith(height: 1),
                                      ),
                                      GestureDetector(
                                        onTap: () => widget.onNavigate(
                                          2,
                                        ), // Navigate to charts
                                        child: Container(
                                          width: 61,
                                          height: 19,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                width: 1,
                                                color:
                                                    AppColors.tealPrimaryDark,
                                              ),
                                              borderRadius:
                                                  const BorderRadiusDirectional.only(
                                                    topEnd: Radius.circular(
                                                      100,
                                                    ),
                                                    bottomEnd: Radius.circular(
                                                      100,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'More'.tr(context),
                                                style: AppTextStyles
                                                    .skipTextTealIcon9Bold,
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 9,
                                                color: AppColors.tealIconActive,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Premium Interactive Cards for Home
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Heart Rate card
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              ref
                                                      .read(
                                                        activeChartSectionProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  'heart_rate';
                                              widget.onNavigate(2);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFE6F4F6),
                                                    Colors.white,
                                                  ],
                                                  begin: AlignmentDirectional
                                                      .centerStart,
                                                  end: AlignmentDirectional
                                                      .centerEnd,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppColors
                                                      .tealPrimaryDark
                                                      .withValues(alpha: 0.15),
                                                  width: 1,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Icon(
                                                        Icons.favorite_rounded,
                                                        color: AppColors
                                                            .tealIconActive,
                                                        size: 22,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .north_east_rounded,
                                                        color: AppColors
                                                            .tealIconActive,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Heart Rate'.tr(context),
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF64748B,
                                                      ),
                                                      fontSize: 13,
                                                      fontFamily:
                                                          AppTextStyles.isArabic
                                                          ? 'Cairo'
                                                          : 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '78 BPM',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF1E293B,
                                                      ),
                                                      fontSize: 20,
                                                      fontFamily:
                                                          AppTextStyles.isArabic
                                                          ? 'Cairo'
                                                          : 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .tealPrimaryDark
                                                          .withValues(
                                                            alpha: 0.08,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Stable'.tr(context),
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .tealPrimaryDark,
                                                        fontSize: 11,
                                                        fontFamily:
                                                            AppTextStyles
                                                                .isArabic
                                                            ? 'Cairo'
                                                            : 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // SpO2 card
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              ref
                                                      .read(
                                                        activeChartSectionProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  'spo2';
                                              widget.onNavigate(2);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFE6F4F6),
                                                    Colors.white,
                                                  ],
                                                  begin: AlignmentDirectional
                                                      .centerStart,
                                                  end: AlignmentDirectional
                                                      .centerEnd,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppColors
                                                      .tealPrimaryDark
                                                      .withValues(alpha: 0.15),
                                                  width: 1,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Icon(
                                                        Icons.opacity,
                                                        color: AppColors
                                                            .tealIconActive,
                                                        size: 22,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .north_east_rounded,
                                                        color: AppColors
                                                            .tealIconActive,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'SpO₂ Level'.tr(context),
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF64748B,
                                                      ),
                                                      fontSize: 13,
                                                      fontFamily:
                                                          AppTextStyles.isArabic
                                                          ? 'Cairo'
                                                          : 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$oxygenSaturation%',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF1E293B,
                                                      ),
                                                      fontSize: 20,
                                                      fontFamily:
                                                          AppTextStyles.isArabic
                                                          ? 'Cairo'
                                                          : 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .tealPrimaryDark
                                                          .withValues(
                                                            alpha: 0.08,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Normal'.tr(context),
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .tealPrimaryDark,
                                                        fontSize: 11,
                                                        fontFamily:
                                                            AppTextStyles
                                                                .isArabic
                                                            ? 'Cairo'
                                                            : 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Stability index full width card
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                                .read(
                                                  activeChartSectionProvider
                                                      .notifier,
                                                )
                                                .state =
                                            'stability';
                                        widget.onNavigate(2);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE6F4F6),
                                              Colors.white,
                                            ],
                                            begin: AlignmentDirectional
                                                .centerStart,
                                            end: AlignmentDirectional.centerEnd,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppColors.tealPrimaryDark
                                                .withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.speed_rounded,
                                                  color:
                                                      AppColors.tealIconActive,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 14),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Stability Index'.tr(
                                                        context,
                                                      ),
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF1E293B,
                                                        ),
                                                        fontSize: 15,
                                                        fontFamily:
                                                            AppTextStyles
                                                                .isArabic
                                                            ? 'Cairo'
                                                            : 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${'Current Score:'.tr(context)} ${(100 - riskScore).toInt()}%',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF64748B,
                                                        ),
                                                        fontSize: 12,
                                                        fontFamily:
                                                            AppTextStyles
                                                                .isArabic
                                                            ? 'Cairo'
                                                            : 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Icon(
                                              Icons.north_east_rounded,
                                              color: AppColors.tealIconActive,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DataUploadCard(
                                    onUploadPressed: () {
                                      context.push(
                                        AppConstants.routeUploadFilesStep1,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                child: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          KeyedSubtree(
            key: AppTutorialHelper.patientNotificationBtnKey,
            child: FloatingNotificationButton(
              onTap: () {
                context.push(AppConstants.routeNotifications);
              },
            ),
          ),
          KeyedSubtree(
            key: AppTutorialHelper.patientChatbotKey,
            child: const FloatingChatbotButton(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        centerButtonKey: AppTutorialHelper.patientCenterNavKey,
        chartsTabKey: AppTutorialHelper.patientChartsTabKey,
        profileTabKey: AppTutorialHelper.patientProfileTabKey,
        currentIndex: _currentNavIndex,
        labels: [
          'Home'.tr(context),
          'Search'.tr(context),
          'Charts'.tr(context),
          'Profile'.tr(context),
        ],
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          widget.onNavigate(index);
        },
        centerButtonOnTap: () {
          context.push(AppConstants.routeUploadFilesStep1);
        },
      ),
    );
  }
}
