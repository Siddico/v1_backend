/// Centralized duration constants for consistent animations.
class AppDurations {
  AppDurations._();

  // Animation durations - Generic
  static const Duration instant = Duration.zero;
  static const Duration veryFast = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration short = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
  static const Duration veryLong = Duration(seconds: 1);
  static const Duration extraLong = Duration(seconds: 2);

  // Splash screen animations
  static const Duration splashLogo = Duration(milliseconds: 2000);
  static const Duration splashPopup = Duration(milliseconds: 1000);
  static const Duration splashPopupDelay = Duration(milliseconds: 4000);
  static const Duration splashNavigation = Duration(milliseconds: 80);

  // Onboarding animations
  static const Duration onboardingFade = Duration(milliseconds: 800);
  static const Duration onboardingSlide = Duration(milliseconds: 1000);
  static const Duration onboardingSlideDelay = Duration(milliseconds: 200);

  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 600);
  static const Duration fadeTransition = Duration(milliseconds: 280);

  // UI interactions
  static const Duration buttonPress = Duration(milliseconds: 200);
  static const Duration toggleSwitch = Duration(milliseconds: 200);
  static const Duration ripple = Duration(milliseconds: 300);

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Chart updates
  static const Duration chartUpdate = Duration(milliseconds: 40);
}
