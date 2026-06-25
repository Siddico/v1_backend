import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../patient/presentation/widgets/profile_components/bottom_action_button.dart';
import '../../../patient/presentation/widgets/profile_components/information_dashboard_switch.dart';
import '../../../patient/presentation/widgets/profile/information_section.dart';
import '../../../patient/presentation/widgets/profile_components/medical_dashboard_section.dart';
import '../../../patient/presentation/widgets/profile_components/patient_header.dart';
import '../../../patient/presentation/controllers/patient_profile_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_tutorial_helper.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';

class PatientDetailPage extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends ConsumerState<PatientDetailPage> {
  bool _isDarkMode = false;
  bool _showMedicalDashboard = false;
  bool _isTutorialTriggered = false;

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientDetailsProvider(widget.patientId));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: patientState.when(
        loading: () => const CircularLoadingIndicator(color: AppColors.redDeep),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.redAlert),
                const SizedBox(height: 16),
                Text(
                  '${'Error loading patient: '.tr(context)}$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(patientDetailsProvider(widget.patientId)),
                  child: Text('Retry'.tr(context)),
                ),
              ],
            ),
          ),
        ),
        data: (patient) {
          if (!_isTutorialTriggered) {
            _isTutorialTriggered = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final uid = ref.read(authStateProvider).valueOrNull?.id;
              AppTutorialHelper.showDoctorPatientDetailsTutorialIfNeeded(
                context,
                uid,
              );
            });
          }
          return Stack(
            children: [
              // Background decoration circles filling the whole screen
              Positioned.fill(
                child: BottomBackgroundCircles(
                  themeConfig: RoleThemeConfig.fromRole(UserRole.doctor),
                ),
              ),
              // Main Layout on top of background
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AppBarControls(
                          isDarkMode: _isDarkMode,
                          onDarkModeToggle: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          },
                          onLanguageSelect: () {},
                          darkModeToggleLightColor: AppColors.pinkLight,
                          darkModeToggleDarkColor: AppColors.redDeep,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: 20,
                              start: 22,
                              end: 22,
                              bottom: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PatientHeader(patient: patient),
                                const SizedBox(height: 12),
                                KeyedSubtree(
                                  key: AppTutorialHelper
                                      .doctorPatientInfoSwitchKey,
                                  child: InfoDashboardSwitch(
                                    showMedicalDashboard: _showMedicalDashboard,
                                    onToggle: (value) {
                                      setState(() {
                                        _showMedicalDashboard = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _showMedicalDashboard
                                    ? MedicalDashboardSection(
                                        patientId: widget.patientId,
                                      )
                                    : InformationSection(patient: patient),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SliverFillRemaining pushes the child to the bottom when content is short,
                  // but scrolls with the content when it is long.
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 22,
                        end: 22,
                        bottom: 24,
                        top: 10,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomActionButtons(patientId: widget.patientId),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
