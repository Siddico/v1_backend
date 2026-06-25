import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/features/doctor/presentation/controllers/doctor_providers.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_tutorial_helper.dart';

import '../widgets/doctor_home/daily_task_card.dart';
import '../widgets/doctor_home/doctor_home_header.dart';
import '../widgets/doctor_home/doctor_state_row.dart';
import '../widgets/doctor_home/patients_section.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../widgets/search/doctor_search_view_content.dart';
import 'doctor_messages_page.dart';
import 'doctor_profile_page.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/floating_notification_button.dart';
import '../../../../shared/presentation/widgets/floating_chatbot_button.dart';
import '../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';

class DoctorHomePage extends ConsumerStatefulWidget {
  const DoctorHomePage({super.key});

  @override
  ConsumerState<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends ConsumerState<DoctorHomePage> {
  bool _isDarkMode = false;
  int _currentIndex = 0;

  bool _isTutorialTriggered = false;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dashboardAsync = ref.watch(doctorDashboardProvider);
    final authState = ref.watch(authStateProvider);

    final homeContent = authState.when(
      loading: () => const _DoctorLoadingState(),
      error: (err, _) => Center(child: Text('${'Error:'.tr(context)} $err')),
      data: (user) {
        if (user == null) {
          return const _DoctorLoadingState();
        }

        return dashboardAsync.when(
          loading: () => const _DoctorLoadingState(),
          error: (err, _) => Center(
            child: Text('${'Error loading dashboard:'.tr(context)} $err'),
          ),
          data: (dashboard) {
            final tasks = dashboard.tasks;
            final stats = dashboard.stats;
            final patients = dashboard.patients;

            if (!_isTutorialTriggered) {
              _isTutorialTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  AppTutorialHelper.showDoctorTutorialIfNeeded(context, user.id);
                }
              });
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DoctorHomeHeader(
                        isDarkMode: _isDarkMode,
                        doctorName: user.name,
                        doctorImage: user.photoUrl,
                        onDarkModeToggle: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          'Your daily overview'.tr(context),
                          style: AppTextStyles
                              .doctorOverviewHeaderRedDarkest20ExtraBold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => DailyTaskCard(
                            item: tasks[index],
                            cardWidth: width * 0.75,
                          ),
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemCount: tasks.length,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: DoctorStatsRow(stats: stats),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: KeyedSubtree(
                          key: AppTutorialHelper.doctorPatientsSectionKey,
                          child: PatientsSection(patients: patients),
                        ),
                      ),
                    ],
                  ),
                ),
                KeyedSubtree(
                  key: AppTutorialHelper.doctorNotificationBtnKey,
                  child: FloatingNotificationButton(
                    onTap: () => context.push(AppConstants.doctorNotifications),
                    backgroundColor: AppColors.redDeep,
                    right: 20,
                    bottom: 90,
                  ),
                ),
                KeyedSubtree(
                  key: AppTutorialHelper.doctorChatbotBtnKey,
                  child: const FloatingChatbotButton(bottom: 90, left: 20),
                ),
              ],
            );
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: _currentIndex == 1
          ? DoctorSearchViewContent(currentIndex: 1, onNavigate: _onNavTap)
          : _currentIndex == 2
          ? DoctorMessagesPage(
              currentIndex: _currentIndex,
              onNavigate: _onNavTap,
            )
          : _currentIndex == 3
          ? DoctorProfilePage(
              currentIndex: _currentIndex,
              onNavigate: _onNavTap,
            )
          : homeContent,
      bottomNavigationBar: _currentIndex == 2 || _currentIndex == 3
          ? null
          : CustomBottomNavBar(
              centerButtonKey: AppTutorialHelper.doctorCenterNavKey,
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              labels: [
                'Home'.tr(context),
                'Search'.tr(context),
                'Message'.tr(context),
                'Profile'.tr(context),
              ],
              selectedIcons: const [
                AppImages.homeSelectedSvg,
                AppImages.searchSelectedSvg,
                AppImages.messageLogoSvg,
                AppImages.profileSelectedSvg,
              ],
              unselectedIcons: const [
                AppImages.homeUnselectedSvg,
                AppImages.searchUnselectedSvg,
                AppImages.messageLogoSvg,
                AppImages.profileUnselectedSvg,
              ],
              activeColor: AppColors.redDeep,
              inactiveColor: AppColors.redSoft,
              centerButtonColor: AppColors.redDeep,
              centerButtonBorderColor: AppColors.pinkLight,
              centerButtonIcon: AppImages.scanQrCodeSvg,
              centerButtonOnTap: () {
                context.push(AppConstants.routeDoctorScanQr);
              },
            ),
    );
  }
}

/// Branded loading screen shown while the doctor dashboard is initializing.
/// Shown instead of a blank page after login.
class _DoctorLoadingState extends StatelessWidget {
  const _DoctorLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.logoPng,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularLoadingIndicator(size: 32, color: AppColors.redDeep),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => Text(
              'Loading your dashboard…'.tr(context),
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                color: AppColors.redDeep.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
