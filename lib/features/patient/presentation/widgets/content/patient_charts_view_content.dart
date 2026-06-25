import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/patient_profile_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/device_not_connected_card.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/status_mapper.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../../shared/presentation/widgets/ecg_chart.dart';
import '../../../../../shared/presentation/widgets/floating_notification_button.dart';
import '../../../../../shared/presentation/widgets/floating_chatbot_button.dart';
import '../../../../../shared/presentation/widgets/ppg_chart.dart';
import '../../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../wellness/presentation/controllers/wellness_providers.dart';
import '../../../../wellness/presentation/widgets/chart_status_badge.dart';
import '../../../../wellness/presentation/widgets/health_metrics_card.dart';
import '../../../../wellness/presentation/widgets/health_overview_chart.dart';
import '../../../../wellness/presentation/widgets/stability_index_card.dart';
import '../../../../../shared/presentation/widgets/user_qr_widget.dart';
import '../../../../../core/services/pdf_report_service.dart';
import '../../controllers/chart_navigation_provider.dart';

class PatientChartsViewContent extends ConsumerStatefulWidget {
  const PatientChartsViewContent({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<PatientChartsViewContent> createState() =>
      _PatientChartsViewContentState();
}

class _PatientChartsViewContentState
    extends ConsumerState<PatientChartsViewContent> {
  late int _currentNavIndex;
  bool _isDarkMode = false;
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectivityResults = const [
    ConnectivityResult.none,
  ];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // Expansion states for each metric/chart section
  bool _heartRateExpanded = false;
  bool _spo2Expanded = false;
  bool _stabilityExpanded = false;
  bool _ecgExpanded = false;
  bool _ppgExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
    _initConnectivity();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      if (!mounted) return;
      setState(() {
        _connectivityResults = result;
      });
    });
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (!mounted) return;
    setState(() {
      _connectivityResults = result;
    });
  }

  @override
  void didUpdateWidget(PatientChartsViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentNavIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  String _computeAge(String? dob, BuildContext context) {
    if (dob == null || dob.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age--;
      }
      return '$age ${'years'.tr(context)}';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConnected =
        _connectivityResults.isNotEmpty &&
        !_connectivityResults.contains(ConnectivityResult.none);
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

    final String patientId = userId ?? '';
    final patientState = ref.watch(patientDetailsProvider(patientId));
    final patient = patientState.valueOrNull;

    final healthState = ref.watch(
      healthMonitoringControllerProviderFamily(patientId),
    );

    final strokeRisk =
        patientDetailsState?.valueOrNull?.aiRiskStrokeRate?.toDouble() ??
        latestHealthData?.riskScore ??
        46;

    final statusString = StatusMapper.resolveStatus(
      prediction: healthState.currentPrediction,
      patientStatus:
          patient?.status ?? patient?.patientProfile?['status']?.toString(),
      riskScore: strokeRisk.toDouble(),
    );
    final Color chartColor = StatusMapper.getColorForStatus(statusString);

    final patientAge = _computeAge(authState.valueOrNull?.dateOfBirth, context);

    final oxygenSaturation = latestHealthData?.oxygenSaturation ?? 98;
    final stabilityPercentage = 100 - strokeRisk.toDouble();

    final activeSection = ref.watch(activeChartSectionProvider);

    // If an external section is active, expand it, scroll to it, then reset the provider
    if (activeSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (activeSection == 'heart_rate') {
            _heartRateExpanded = true;
          } else if (activeSection == 'spo2') {
            _spo2Expanded = true;
          } else if (activeSection == 'stability') {
            _stabilityExpanded = true;
          } else if (activeSection == 'ecg') {
            _ecgExpanded = true;
          } else if (activeSection == 'ppg') {
            _ppgExpanded = true;
          }
        });
        ref.read(activeChartSectionProvider.notifier).state = null;
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 105),
                          Container(
                            height: 93,
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: AppColors.shadowBlack25,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Container(
                                  width: 71,
                                  height: 72,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image:
                                          (authState.valueOrNull?.photoUrl !=
                                                  null &&
                                              authState
                                                  .valueOrNull!
                                                  .photoUrl!
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                                  authState
                                                      .valueOrNull!
                                                      .photoUrl!,
                                                )
                                                as ImageProvider
                                          : const AssetImage(
                                              AppImages.onboardingBackground,
                                            ),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: AppColors.neutral250,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        35.50,
                                      ),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: AppColors.shadowBlack25,
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTextStyles.titleBlack18ExtraBold,
                                      ),
                                      ChartStatusBadge(
                                        label: 'Diagnosis'.tr(context),
                                        status:
                                            patientDetailsState
                                                ?.valueOrNull
                                                ?.status ??
                                            'Unknown'.tr(context),
                                      ),
                                      Text(
                                        patientAge,
                                        style:
                                            AppTextStyles.subtitleBlack14Medium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Real QR code for the signed-in patient
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF0FB39E,
                                      ).withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.07,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const UserQrWidget(size: 70),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          const SizedBox(height: 42),

                          if (!isConnected) ...[
                            DeviceNotConnectedCard(
                              onUploadPressed: () => context.push(
                                AppConstants.routeUploadFilesStep1,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ] else ...[
                            // Heart Rate collapsible card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _heartRateExpanded = !_heartRateExpanded;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _heartRateExpanded
                                      ? Colors.transparent
                                      : null,
                                  gradient: !_heartRateExpanded
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE6F4F6),
                                            Colors.white,
                                          ],
                                          begin:
                                              AlignmentDirectional.centerStart,
                                          end: AlignmentDirectional.centerEnd,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: !_heartRateExpanded
                                      ? Border.all(
                                          color: AppColors.tealPrimaryDark
                                              .withValues(alpha: 0.15),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding: _heartRateExpanded
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!_heartRateExpanded) ...[
                                          const Icon(
                                            Icons.favorite_rounded,
                                            color: AppColors.tealIconActive,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          'Heart Rate Trend'.tr(context),
                                          style: _heartRateExpanded
                                              ? AppTextStyles
                                                    .titleBlack18ExtraBold
                                              : TextStyle(
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppTextStyles.isArabic
                                                      ? 'Cairo'
                                                      : 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: _heartRateExpanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _heartRateExpanded
                                            ? AppColors.black
                                            : AppColors.tealIconActive,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: const Column(
                                children: [
                                  HeartRateChart(),
                                  SizedBox(height: 26),
                                ],
                              ),
                              crossFadeState: _heartRateExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),

                            // SpO2 collapsible card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _spo2Expanded = !_spo2Expanded;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _spo2Expanded
                                      ? Colors.transparent
                                      : null,
                                  gradient: !_spo2Expanded
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE6F4F6),
                                            Colors.white,
                                          ],
                                          begin:
                                              AlignmentDirectional.centerStart,
                                          end: AlignmentDirectional.centerEnd,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: !_spo2Expanded
                                      ? Border.all(
                                          color: AppColors.tealPrimaryDark
                                              .withValues(alpha: 0.15),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding: _spo2Expanded
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!_spo2Expanded) ...[
                                          const Icon(
                                            Icons.opacity,
                                            color: AppColors.tealIconActive,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          'Oxygen Saturation (SpO₂)'.tr(
                                            context,
                                          ),
                                          style: _spo2Expanded
                                              ? AppTextStyles
                                                    .titleBlack18ExtraBold
                                              : TextStyle(
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppTextStyles.isArabic
                                                      ? 'Cairo'
                                                      : 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: _spo2Expanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _spo2Expanded
                                            ? AppColors.black
                                            : AppColors.tealIconActive,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  HealthMetricsCard(
                                    title: 'Current Status'.tr(context),
                                    value: '$oxygenSaturation%',
                                    unit: 'Oxygen'.tr(context),
                                    status: 'Normal'.tr(context),
                                    statusColor: AppColors.tealP,
                                    description:
                                        'of your Oxygen level is normal.'.tr(
                                          context,
                                        ),
                                    circleColor: AppColors.tealPrimaryLight,
                                    borderColor: Colors.transparent,
                                  ),
                                  const SizedBox(height: 26),
                                ],
                              ),
                              crossFadeState: _spo2Expanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),

                            // Stability collapsible card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _stabilityExpanded = !_stabilityExpanded;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _stabilityExpanded
                                      ? Colors.transparent
                                      : null,
                                  gradient: !_stabilityExpanded
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE6F4F6),
                                            Colors.white,
                                          ],
                                          begin:
                                              AlignmentDirectional.centerStart,
                                          end: AlignmentDirectional.centerEnd,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: !_stabilityExpanded
                                      ? Border.all(
                                          color: AppColors.tealPrimaryDark
                                              .withValues(alpha: 0.15),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding: _stabilityExpanded
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!_stabilityExpanded) ...[
                                          const Icon(
                                            Icons.speed_rounded,
                                            color: AppColors.tealIconActive,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          'Stability Index'.tr(context),
                                          style: _stabilityExpanded
                                              ? AppTextStyles
                                                    .titleBlack18ExtraBold
                                              : TextStyle(
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppTextStyles.isArabic
                                                      ? 'Cairo'
                                                      : 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: _stabilityExpanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _stabilityExpanded
                                            ? AppColors.black
                                            : AppColors.tealIconActive,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  StabilityIndexCard(
                                    percentage: stabilityPercentage,
                                    description:
                                        'is the normal zone for stability.'.tr(
                                          context,
                                        ),
                                  ),
                                  const SizedBox(height: 26),
                                ],
                              ),
                              crossFadeState: _stabilityExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),

                            // ECG collapsible card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _ecgExpanded = !_ecgExpanded;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _ecgExpanded
                                      ? Colors.transparent
                                      : null,
                                  gradient: !_ecgExpanded
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE6F4F6),
                                            Colors.white,
                                          ],
                                          begin:
                                              AlignmentDirectional.centerStart,
                                          end: AlignmentDirectional.centerEnd,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: !_ecgExpanded
                                      ? Border.all(
                                          color: AppColors.tealPrimaryDark
                                              .withValues(alpha: 0.15),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding: _ecgExpanded
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!_ecgExpanded) ...[
                                          const Icon(
                                            Icons.stacked_line_chart,
                                            color: AppColors.tealIconActive,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          'ECG Signals'.tr(context),
                                          style: _ecgExpanded
                                              ? AppTextStyles
                                                    .titleBlack18ExtraBold
                                              : TextStyle(
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppTextStyles.isArabic
                                                      ? 'Cairo'
                                                      : 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: _ecgExpanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _ecgExpanded
                                            ? AppColors.black
                                            : AppColors.tealIconActive,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  ECGChart(lineColor: chartColor),
                                  const SizedBox(height: 26),
                                ],
                              ),
                              crossFadeState: _ecgExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),

                            // PPG collapsible card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _ppgExpanded = !_ppgExpanded;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _ppgExpanded
                                      ? Colors.transparent
                                      : null,
                                  gradient: !_ppgExpanded
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE6F4F6),
                                            Colors.white,
                                          ],
                                          begin:
                                              AlignmentDirectional.centerStart,
                                          end: AlignmentDirectional.centerEnd,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: !_ppgExpanded
                                      ? Border.all(
                                          color: AppColors.tealPrimaryDark
                                              .withValues(alpha: 0.15),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding: _ppgExpanded
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!_ppgExpanded) ...[
                                          const Icon(
                                            Icons.waves_rounded,
                                            color: AppColors.tealIconActive,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          'PPG Signals'.tr(context),
                                          style: _ppgExpanded
                                              ? AppTextStyles
                                                    .titleBlack18ExtraBold
                                              : TextStyle(
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppTextStyles.isArabic
                                                      ? 'Cairo'
                                                      : 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                      ],
                                    ),
                                    AnimatedRotation(
                                      turns: _ppgExpanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _ppgExpanded
                                            ? AppColors.black
                                            : AppColors.tealIconActive,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    decoration: ShapeDecoration(
                                      color: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: AppColors.redMaroon,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadows: const [
                                        BoxShadow(
                                          color: AppColors.shadowBlack25,
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: SizedBox(
                                      height: 170,
                                      child: PPGChart(lineColor: chartColor),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                              crossFadeState: _ppgExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final isDoctor =
                                        authState.valueOrNull?.role ==
                                        UserRole.doctor;
                                    await PDFReportService.generateAndShareReport(
                                      userName: userName,
                                      age: patientAge,
                                      healthData: latestHealthData,
                                      profile: patientDetailsState
                                          ?.valueOrNull
                                          ?.patientProfile,
                                      isDoctor: isDoctor,
                                      recentPredictions:
                                          healthState.recentPredictions,
                                    );
                                  },
                                  child: Container(
                                    width: 201,
                                    height: 61,
                                    decoration: ShapeDecoration(
                                      color: AppColors.tealP,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: AppColors.shadowBlack25,
                                          blurRadius: 6,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Print PDF'.tr(context),
                                        style: AppTextStyles
                                            .buttonTextTealSurface27ExtraBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FloatingNotificationButton(
            bottom: 5,
            onTap: () => context.push(AppConstants.routeNotifications),
          ),
          const FloatingChatbotButton(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
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
