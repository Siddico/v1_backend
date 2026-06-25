import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../../core/utils/app_tutorial_helper.dart';
import '../../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../../shared/presentation/widgets/logout_confirm_dialog.dart';
import '../../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import '../profile/patient_profile_colors.dart';
import '../profile/patient_profile_header_card.dart';
import '../profile/patient_profile_logout_button.dart';
import '../profile/patient_profile_settings_card.dart';
import '../profile/patient_profile_settings_item_data.dart';
import '../../../../../core/localization/app_localizations.dart';
import 'profile_records_tab.dart';
import 'profile_meds_tab.dart';
import 'profile_appointments_tab.dart';

class PatientProfileViewContent extends ConsumerStatefulWidget {
  const PatientProfileViewContent({
    super.key,
    this.currentIndex = 3,
    this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigate;

  @override
  ConsumerState<PatientProfileViewContent> createState() =>
      _PatientProfileViewContentState();
}

class _PatientProfileViewContentState
    extends ConsumerState<PatientProfileViewContent> {
  late int _currentNavIndex;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.currentIndex == 3) {
        final uid = ref.read(authStateProvider).valueOrNull?.id;
        AppTutorialHelper.showPatientProfileTutorialIfNeeded(context, uid);
      }
    });
  }

  @override
  void didUpdateWidget(PatientProfileViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentNavIndex = widget.currentIndex;
      if (_currentNavIndex == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final uid = ref.read(authStateProvider).valueOrNull?.id;
            AppTutorialHelper.showPatientProfileTutorialIfNeeded(context, uid);
          }
        });
      }
    }
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showLogoutConfirmDialog(
      context,
      colors: LogoutDialogColors.patient,
    );
    if (confirmed == true) {
      if (context.mounted) {
        AppToast.show(
          // ignore: use_build_context_synchronously
          context,
          'Logged out successfully.',
          type: AppToastType.success,
          role: UserRole.patient,
        );
      }
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  // ignore: unused_element
  void _showComingSoon(String feature) {
    AppToast.show(
      context,
      '$feature is coming soon.',
      type: AppToastType.warning,
      role: UserRole.patient,
    );
  }

  String _computeAge(BuildContext context, String? dob) {
    if (dob == null || dob.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age--;
      }
      return '$age ${'yrs'.tr(context)}';
    } catch (_) {
      return 'N/A';
    }
  }

  Widget _buildSegmentedTabBar() {
    final tabs = [
      'Settings'.tr(context),
      'Records'.tr(context),
      'Meds'.tr(context),
      'Appointments'.tr(context),
      // 'History'.tr(context),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tealSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tealP : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.tealP.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white
                          : AppColors.tealPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 430 ? 430.0 : width;
    final authState = ref.watch(authStateProvider);

    final user = authState.valueOrNull;
    final displayName = authState.when(
      data: (u) => u?.name ?? 'Patient',
      loading: () => '...',
      // ignore: unnecessary_underscores
      error: (_, __) => 'Patient',
    );
    final photoUrl = user?.photoUrl;
    final ageLabel = _computeAge(context, user?.dateOfBirth);

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppBarControls(
                  isDarkMode: true,
                  onDarkModeToggle: () {},
                  onLanguageSelect: () {},
                ),
                const SizedBox(height: 40),
                PatientProfileHeaderCard(
                  // Navigate to the real edit profile page.
                  onEditTap: () =>
                      context.push(AppConstants.routePatientEditProfile),
                  displayName: displayName,
                  ageLabel: ageLabel,
                  photoUrl: photoUrl,
                ),
                const SizedBox(height: 24),
                KeyedSubtree(
                  key: AppTutorialHelper.profileSegmentedControlKey,
                  child: _buildSegmentedTabBar(),
                ),
                const SizedBox(height: 24),
                if (_activeTab == 0) ...[
                  PatientProfileSettingsCard(
                    items: [
                      PatientProfileSettingsItemData(
                        iconPath: AppImages.emergencyContact,
                        title: 'Emergency contact'.tr(context),
                        onTap: () {
                          context.push(AppConstants.routeEmergencyContact);
                        },
                      ),
                      PatientProfileSettingsItemData(
                        iconPath: AppImages.scanQrCode,
                        title: 'Scan QR Code'.tr(context),
                        key: AppTutorialHelper.profileScanQrKey,
                        iconColor: AppColors.tealP,
                        onTap: () {
                          context.push(AppConstants.routeScanQr);
                        },
                      ),
                      PatientProfileSettingsItemData(
                        iconPath: AppImages.charts,
                        title: 'Stroke Risk Assessment'.tr(context),
                        onTap: () {
                          context.push(AppConstants.routePredictionSetup);
                        },
                      ),
                      PatientProfileSettingsItemData(
                        iconPath: AppImages.uploadIcon,
                        title: 'Medical History'.tr(context),
                        key: AppTutorialHelper.profileMedicalHistoryKey,
                        onTap: () {
                          context.push(AppConstants.routeMedicalHistory);
                        },
                      ),
                      PatientProfileSettingsItemData(
                        iconPath: AppImages.person,
                        title: 'About Us'.tr(context),
                        onTap: () {
                          context.push(AppConstants.routePatientAboutUs);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: PatientProfileLogoutButton(
                      onPressed: _confirmLogout,
                    ),
                  ),
                ] else if (_activeTab == 1)
                  const ProfileRecordsTab()
                else if (_activeTab == 2)
                  const ProfileMedsTab()
                else if (_activeTab == 3)
                  const ProfileAppointmentsTab(),
                // else if (_activeTab == 4)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 20),
                //     child: PredictionHistorySection(
                //       patientId: user?.id ?? '',
                //       isDoctor: false,
                //     ),
                //   ),
                // const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        centerButtonOnTap: () {
          context.push(AppConstants.routeUploadFilesStep1);
        },
        labels: [
          'Home'.tr(context),
          'Search'.tr(context),
          'Charts'.tr(context),
          'Profile'.tr(context),
        ],
        selectedIcons: const [
          AppImages.homeSelectedSvg,
          AppImages.searchSelectedSvg,
          AppImages.chartsSelectedSvg,
          AppImages.profileSelectedSvg,
        ],
        unselectedIcons: const [
          AppImages.homeUnselectedSvg,
          AppImages.searchUnselectedSvg,
          AppImages.chartsUnselectedSvg,
          AppImages.profileUnselectedSvg,
        ],
        activeColor: PatientProfileColors.patientSelectedNav,
        inactiveColor: PatientProfileColors.patientAccent,
        centerButtonColor: PatientProfileColors.patientSelectedNav,
        centerButtonBorderColor: PatientProfileColors.patientBorder,
      ),
    );
  }
}
