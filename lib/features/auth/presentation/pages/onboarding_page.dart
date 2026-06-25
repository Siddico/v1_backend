import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/networking/local_storage.dart';
import '../../../../core/localization/app_localizations.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: AppDurations.onboardingFade,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      duration: AppDurations.onboardingSlide,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(AppDurations.onboardingSlideDelay, () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.onboardingBackground),
              fit: BoxFit.cover,
              alignment: Alignment(0.4, 0),
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                Positioned(
                  left: -39,
                  right: -39,
                  bottom: -228,
                  child: Container(
                    width: 480,
                    height: 443,
                    decoration: const ShapeDecoration(
                      color: AppColors.white,
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                Positioned(
                  left: 35,
                  right: 35,
                  bottom: 30,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: GestureDetector(
                          onTap: () async {
                            await ref
                                .read(localStorageProvider)
                                .saveOnboardingCompleted(true);
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              context.go(AppConstants.routeRole);
                            }
                          },
                          child: Container(
                            height: 61,
                            padding: const EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: AppColors.redButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                              shadows: AppShadows.buttonShadow,
                            ),
                            child: Center(
                              child: Text(
                                'Get Started'.tr(context),
                                textAlign: TextAlign.center,
                                style: AppTextStyles
                                    .buttonTextRedSurface27ExtraBold
                                    .copyWith(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Your health is your greatest investment take care of it today',
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.onboardingMotivationAladin22Regular,
                        ),
                      ),
                    ],
                  ),
                ),
                // AppBarControls(
                //   isDarkMode: false,
                //   onDarkModeToggle: () {},
                //   onLanguageSelect: () {},
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
