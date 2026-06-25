import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

/// Theme configuration for each user role
/// Contains colors, text content, and visual styling specific to each role
class RoleThemeConfig {
  final Color primaryColor;
  final Color primaryDarkColor;
  final Color iconColor;
  final Color surfaceColor;
  final Color buttonColor;
  final Color accentColor;
  final Color shadowColor;
  final Color
  darkModeToggleLightColor; // Color when light mode is active (sun icon)
  final Color
  darkModeToggleDarkColor; // Color when dark mode is active (moon icon)
  final Color signupTitleColor;
  final Color signupDescriptionColor;
  final Color loginTitleColor;
  final Color loginDescriptionColor;
  final Color forgotPasswordTitleColor;
  final Color forgotPasswordDescriptionColor;
  final Color otpTitleColor;
  final Color otpDescriptionColor;
  final String signupTitle;
  final String signupSubtitle;
  final String loginTitle;
  final String loginSubtitle;
  final String forgotPasswordHint;
  final String forgotPasswordTitle;
  final String forgotPasswordSubtitle;
  final String privacyPolicyHighlightColor;

  const RoleThemeConfig({
    required this.primaryColor,
    required this.primaryDarkColor,
    required this.iconColor,
    required this.surfaceColor,
    required this.buttonColor,
    required this.accentColor,
    required this.shadowColor,
    required this.darkModeToggleLightColor,
    required this.darkModeToggleDarkColor,
    required this.signupTitleColor,
    required this.signupDescriptionColor,
    required this.loginTitleColor,
    required this.loginDescriptionColor,
    required this.forgotPasswordTitleColor,
    required this.forgotPasswordDescriptionColor,
    required this.otpTitleColor,
    required this.otpDescriptionColor,
    required this.signupTitle,
    required this.signupSubtitle,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.forgotPasswordHint,
    required this.forgotPasswordTitle,
    required this.forgotPasswordSubtitle,
    required this.privacyPolicyHighlightColor,
  });

  /// Get theme configuration based on user role
  factory RoleThemeConfig.fromRole(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return _doctorTheme;
      case UserRole.researcher:
        return _researcherTheme;
      case UserRole.patient:
        return _patientTheme;
    }
  }

  // ========================================
  // Doctor Theme (Red/Pink)
  // ========================================
  static const _doctorTheme = RoleThemeConfig(
    primaryColor: AppColors.redSoft, // Pink primary
    primaryDarkColor: AppColors.redButton, // Dark red
    iconColor: AppColors.redMaroon, // Dark maroon for doctor icons
    surfaceColor: AppColors.redSurface, // Light pink surface
    buttonColor: AppColors.redButton, // Red button
    accentColor: AppColors.pinkBlush, // Pink accent
    shadowColor: AppColors.redVivid, // Red shadow
    darkModeToggleLightColor: AppColors.redSoft, // Light pink for light mode
    darkModeToggleDarkColor: AppColors.redDeep, // Dark red for dark mode
    signupTitleColor: AppColors.redNearBlack,
    signupDescriptionColor: AppColors.neutral550,
    loginTitleColor: AppColors.redNearBlack,
    loginDescriptionColor: AppColors.neutral550,
    forgotPasswordTitleColor: AppColors.redNearBlack,
    forgotPasswordDescriptionColor: AppColors.neutral550,
    otpTitleColor: AppColors.redNearBlack,
    otpDescriptionColor: AppColors.neutral550,
    signupTitle: 'Sign-Up',
    signupSubtitle: 'Join us and take the first step toward better health',
    loginTitle: 'Log in',
    loginSubtitle:
        'Welcome back, Doctor! Access your patients\' health insights and provide better care.',
    forgotPasswordHint: 'If you forget your password',
    forgotPasswordTitle: 'Forget Password',
    forgotPasswordSubtitle:
        "Don't worry, Doctor! Enter your registered email, and we'll help you reset your password quickly.",
    privacyPolicyHighlightColor: '#E77E8C',
  );

  // ========================================
  // Researcher Theme (Teal/Blue)
  // ========================================
  static const _researcherTheme = RoleThemeConfig(
    primaryColor: AppColors.blueGhost, // Chambray-50
    primaryDarkColor: AppColors.blueSecondary, // Chambray-800
    iconColor: AppColors.bluePrimary, // Chambray-900
    surfaceColor: AppColors.blueIce, // Chambray-100
    buttonColor: AppColors.bluePrimary, // Chambray-900
    accentColor: AppColors.blueBright, // Chambray-700
    shadowColor: AppColors.blueLight, // Chambray shadow
    darkModeToggleLightColor: AppColors.blueLight, // Light blue for light mode
    darkModeToggleDarkColor: AppColors.blueSecondary, // Dark blue for dark mode
    signupTitleColor: AppColors.blueSecondary,
    signupDescriptionColor: AppColors.neutral550,
    loginTitleColor: AppColors.bluePrimary,
    loginDescriptionColor: AppColors.neutral550,
    forgotPasswordTitleColor: AppColors.bluePrimary,
    forgotPasswordDescriptionColor: AppColors.neutral550,
    otpTitleColor: AppColors.bluePrimary,
    otpDescriptionColor: AppColors.neutral550,
    signupTitle: 'Sign-Up',
    signupSubtitle:
        'Join our research community and contribute to advancing healthcare',
    loginTitle: 'Log in',
    loginSubtitle:
        'Welcome back, Researcher! Access your data and continue your important work.',
    forgotPasswordHint: 'If you forget your password',
    forgotPasswordTitle: 'Forget Password',
    forgotPasswordSubtitle:
        "Don't worry! Enter your registered email, and we'll send you instructions to reset your password.",
    privacyPolicyHighlightColor: '#24ABBD',
  );

  // ========================================
  // Patient Theme (Teal/Green - default)
  // ========================================
  static const _patientTheme = RoleThemeConfig(
    primaryColor: AppColors.tealA, // Teal primary (top circle)
    primaryDarkColor: AppColors.tealPrimaryDark, // Dark teal (main title color)
    iconColor: AppColors.tealPrimaryDark, // Dark teal
    surfaceColor: AppColors.tealSurface, // Light teal surface
    buttonColor: AppColors.tealP, // Teal button (submit button)
    accentColor: AppColors.tealA, // Teal accent (small circle)
    shadowColor: AppColors.tealAccentLight, // Cyan shadow (from design)
    darkModeToggleLightColor: AppColors.tealBorderLight, // Light teal for light mode
    darkModeToggleDarkColor: AppColors.tealP, // Dark teal for dark mode
    signupTitleColor: AppColors.tealPrimaryDark, // Sign-Up title color
    signupDescriptionColor: AppColors.neutral550, // Sign-Up description color
    loginTitleColor: AppColors.tealPrimaryDark, // Log in title color
    loginDescriptionColor: AppColors.neutral550, // Log in description color
    forgotPasswordTitleColor: AppColors.tealPrimaryDark, // Forget Password title color
    forgotPasswordDescriptionColor: Color(
      0xFF999999,
    ), // Forget Password description color
    otpTitleColor: AppColors.tealPrimaryDark, // Enter OTP title color
    otpDescriptionColor: AppColors.neutral550, // Enter OTP description color
    signupTitle: 'Sign-Up',
    signupSubtitle: 'Join us and take the first step toward better health',
    loginTitle: 'Log in',
    loginSubtitle:
        'Welcome back! Track your health and stay connected with your care team.',
    forgotPasswordHint: 'If you forget your password',
    forgotPasswordTitle: 'Forget Password',
    forgotPasswordSubtitle:
        "Don't worry! Enter your registered email, and we'll send you instructions to reset your password.",
    privacyPolicyHighlightColor: '#24ABBD',
  );

  /// Get BoxShadow for decorative circles
  List<BoxShadow> getCircleShadows() {
    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: 111,
        offset: const Offset(11, 22),
        spreadRadius: 11,
      ),
    ];
  }

  /// Get BoxShadow for buttons
  List<BoxShadow> getButtonShadows() {
    return [
      const BoxShadow(
        color: AppColors.shadowBlack25,
        blurRadius: 6,
        offset: Offset(0, 6),
        spreadRadius: 0,
      ),
    ];
  }

  /// Get BoxShadow for form fields
  List<BoxShadow> getFormFieldShadows() {
    return [
      const BoxShadow(
        color: AppColors.shadowBlack25,
        blurRadius: 4,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  /// Get toggle button active border color
  Color getToggleBorderColor() {
    return primaryDarkColor;
  }

  /// Get toggle button inactive border color (black variant)
  Color getToggleInactiveBorderColor() {
    return AppColors.redNearBlack;
  }
}
