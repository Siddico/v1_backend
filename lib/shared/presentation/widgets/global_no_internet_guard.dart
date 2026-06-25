import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/localization/locale_provider.dart';

import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/shared/presentation/controllers/connectivity_providers.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/role_controller.dart';
import 'package:grad_imp_1/shared/presentation/widgets/dark_mode_toggle.dart';
import 'package:grad_imp_1/shared/presentation/widgets/language_selector.dart';

class GlobalNoInternetGuard extends ConsumerWidget {
  const GlobalNoInternetGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch localeProvider to rebuild the guard when language changes
    // ignore: unused_local_variable
    final activeLocale = ref.watch(localeProvider);
    final hasInternet = ref.watch(hasInternetProvider).valueOrNull ?? true;
    final selectedRole = ref.watch(roleProvider);

    if (hasInternet) {
      return child;
    }

    final overlay = selectedRole == UserRole.doctor
        ? const _DoctorNoInternetOverlay()
        : const _GlobalNoInternetOverlay();

    return Stack(fit: StackFit.expand, children: [child, overlay]);
  }
}

class _GlobalNoInternetOverlay extends ConsumerWidget {
  const _GlobalNoInternetOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch localeProvider to rebuild when locale changes
    // ignore: unused_local_variable
    final activeLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Top controls for changing language
            Positioned(
              top: 16,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LanguageSelector(onTap: () {}),
                  const SizedBox(), // Spacer placeholder
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const ShapeDecoration(
                          color: AppColors.tealA,
                          shape: OvalBorder(),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.wifi_off,
                            color: AppColors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'No Internet Connection'.tr(context),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.emptyStateTitleDark22Bold,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please check your internet connection\nor try again later.'
                            .tr(context),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.emptyStateBodyGray17Regular,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          ref.invalidate(hasInternetProvider);
                          final connectivity = ref.read(connectivityProvider);
                          await connectivity.checkConnectivity();
                        },
                        child: Text(
                          'Refresh'.tr(context),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.actionLinkTeal15SemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorNoInternetOverlay extends StatefulWidget {
  const _DoctorNoInternetOverlay();

  @override
  State<_DoctorNoInternetOverlay> createState() =>
      _DoctorNoInternetOverlayState();
}

class _DoctorNoInternetOverlayState extends State<_DoctorNoInternetOverlay> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch localeProvider so the widget rebuilds immediately on language toggle
        // ignore: unused_local_variable
        final activeLocale = ref.watch(localeProvider);
        final screenHeight = MediaQuery.of(context).size.height;

        // Use relative responsive positioning based on screen height to prevent overlaps
        final contentTop = screenHeight * 0.32;
        final buttonTop = screenHeight * 0.63;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Curved backdrop centered horizontally
              const _DoctorOfflineHeaderBackdrop(),

              // Center design card with error elements
              Positioned(
                top: contentTop,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 335,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // WiFi icon in circle
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFFE77E8C),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 25,
                                top: 25,
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.wifi_off,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 21),
                        // Texts container
                        SizedBox(
                          width: 335,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 335,
                                child: Text(
                                  'No Internet Connection'.tr(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFAB2133,
                                    ), // Styled in Red for readable visibility on white bg
                                    fontSize: 22,
                                    fontFamily: AppTextStyles.isArabic
                                        ? 'Cairo'
                                        : 'SF Pro Display',
                                    fontWeight: FontWeight.w700,
                                    height: 1.27,
                                    letterSpacing: 0.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 335,
                                child: Text(
                                  'Please check your internet connection\nor try again later.'
                                      .tr(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFA0A0A0),
                                    fontSize: 17,
                                    fontFamily: AppTextStyles.isArabic
                                        ? 'Cairo'
                                        : 'SF Pro Text',
                                    fontWeight: FontWeight.w400,
                                    height: 1.29,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 21),
                        // Refresh link
                        GestureDetector(
                          onTap: () async {
                            ref.invalidate(hasInternetProvider);
                            final connectivity = ref.read(connectivityProvider);
                            await connectivity.checkConnectivity();
                          },
                          child: SizedBox(
                            width: 317,
                            child: Text(
                              'Refresh'.tr(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFE77E8C),
                                fontSize: 15,
                                fontFamily: AppTextStyles.isArabic
                                    ? 'Cairo'
                                    : 'SF Pro Text',
                                fontWeight: FontWeight.w600,
                                height: 1.33,
                                letterSpacing: -0.50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back button
              Positioned(
                top: buttonTop,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.maybePop(context);
                    },
                    child: Container(
                      width: 201,
                      height: 61,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFAB2133),
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Back'.tr(context),
                            style: TextStyle(
                              color: const Color(0xFFAB2133),
                              fontSize: 27,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Top controls
              Positioned(
                left: 28,
                right: 28,
                top: 51,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LanguageSelector(onTap: () {}),
                    DarkModeToggle(
                      isDarkMode: _isDarkMode,
                      onTap: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      lightColor: const Color(0xFFE77E8C),
                      darkColor: const Color(0xFFAB2133),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorOfflineHeaderBackdrop extends StatelessWidget {
  const _DoctorOfflineHeaderBackdrop();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      left: (screenWidth - 564) / 2,
      top: -312,
      child: SizedBox(
        width: 564,
        height: 540,
        child: Stack(
          children: [
            Positioned(
              left: 37,
              top: 0,
              child: Container(
                width: 500,
                height: 468,
                decoration: const ShapeDecoration(
                  color: Color(0xFFE77E8C),
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0xFFCE1126),
                      blurRadius: 111,
                      offset: Offset(11, 22),
                      spreadRadius: 11,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 26,
              top: 7,
              child: Container(
                width: 500,
                height: 468,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 111,
                      offset: Offset(11, 22),
                      spreadRadius: 11,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 199,
              top: 15,
              child: Container(
                width: 166,
                height: 152,
                decoration: const ShapeDecoration(
                  color: Color(0xFFEFA9B3),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
