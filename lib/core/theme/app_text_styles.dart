import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static bool isArabic = false;

  static String _getFontFamily(String original) {
    if (isArabic) {
      if (original == 'Aladin' || original == 'CroissantOne') {
        return original;
      }
      return 'Cairo';
    }
    return original;
  }

  static TextStyle _interStyle({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) {
    if (isArabic) {
      return TextStyle(
        fontFamily: 'Cairo',
        color: color ?? textStyle?.color,
        fontSize: fontSize ?? textStyle?.fontSize,
        fontWeight: fontWeight ?? textStyle?.fontWeight,
        letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
        height: height ?? textStyle?.height,
        shadows: shadows ?? textStyle?.shadows,
        decoration: decoration ?? textStyle?.decoration,
      );
    } else {
      return GoogleFonts.inter(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
      );
    }
  }

  static TextStyle _poppinsStyle({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) {
    if (isArabic) {
      return TextStyle(
        fontFamily: 'Cairo',
        color: color ?? textStyle?.color,
        fontSize: fontSize ?? textStyle?.fontSize,
        fontWeight: fontWeight ?? textStyle?.fontWeight,
        letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
        height: height ?? textStyle?.height,
        shadows: shadows ?? textStyle?.shadows,
        decoration: decoration ?? textStyle?.decoration,
      );
    } else {
      return TextStyle(
        fontFamily: 'Poppins',
        color: color ?? textStyle?.color,
        fontSize: fontSize ?? textStyle?.fontSize,
        fontWeight: fontWeight ?? textStyle?.fontWeight,
        letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
        height: height ?? textStyle?.height,
        shadows: shadows ?? textStyle?.shadows,
        decoration: decoration ?? textStyle?.decoration,
      );
    }
  }

  // =====================================================
  // Auth
  // =====================================================

  // Main hero title used in auth screens (Sign up / OTP / Forgot Password).
  static TextStyle get authHeroTitleCroissant50TealDark => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 50,
    fontFamily: _getFontFamily('CroissantOne'),
    fontWeight: FontWeight.w400,
  );

  // Auth subtitle/description text under hero titles.
  static TextStyle get authSubtitleNeutral550_22 => _interStyle(
    color: AppColors.neutral550,
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  // Small helper text in auth flows (e.g., "If you forgot your password...").
  static TextStyle get authHintNeutral450_12Medium => _interStyle(
    color: AppColors.neutral450,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Underlined auth action link with shadow (e.g., "Change now", "Click here").
  static TextStyle get authActionLinkAladin14UnderlineShadow => TextStyle(
    color: AppColors.tealP,
    fontSize: 14,
    fontFamily: _getFontFamily('Aladin'),
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline,
    shadows: [
      Shadow(
        offset: Offset(0, 4),
        blurRadius: 4,
        color: AppColors.shadowBlack25,
      ),
    ],
  );

  // Privacy policy link style in auth agreement blocks.
  static TextStyle get privacyPolicyLinkInter14ExtraBold => _interStyle(
    color: AppColors.tealP,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    decoration: TextDecoration.underline,
  );

  // Red hero title used in role selection onboarding path.
  static TextStyle get roleTitleCroissant50RedDarkest => TextStyle(
    fontSize: 50,
    fontFamily: _getFontFamily('CroissantOne'),
    color: AppColors.redDarkest,
  );

  // Motivational text in onboarding screen.
  static TextStyle get onboardingMotivationAladin22Regular => TextStyle(
    color: AppColors.black,
    fontSize: 22,
    fontFamily: _getFontFamily('Aladin'),
    fontWeight: FontWeight.w400,
  );

  // Red primary CTA text used on onboarding "Get Started" button.
  static TextStyle get buttonTextRedSurface27ExtraBold => _interStyle(
    color: AppColors.redSurface,
    fontSize: 27,
    fontWeight: FontWeight.bold,
  );

  // =====================================================
  // Patient
  // =====================================================

  // Generic large teal title with subtle shadow for patient pages.
  static TextStyle get titleTeal22BoldShadow => _interStyle(
    color: AppColors.tealPrimaryLight,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.09,
    shadows: [
      Shadow(
        offset: Offset(0, 4),
        blurRadius: 4,
        color: AppColors.shadowBlack25,
      ),
    ],
  );

  // Filled teal button text (e.g., action buttons in patient flow).
  static TextStyle get buttonTextTealSurface27ExtraBold => _interStyle(
    color: AppColors.tealSurface,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  // Outlined teal button text.
  static TextStyle get buttonTextTeal27ExtraBold => _interStyle(
    color: AppColors.tealP,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  // Toggle row label style in settings pages.
  static TextStyle get toggleLabelTealDark22Bold => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.09,
  );

  // Section title style used in profile/details screens.
  static TextStyle get sectionTitleDark20ExtraBold => _interStyle(
    color: AppColors.neutral900,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.20,
  );

  // Standard body paragraph text.
  static TextStyle get bodyDark16Regular => _interStyle(
    color: AppColors.neutral900,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  // Inline link style inside rich texts.
  static TextStyle get linkTeal16Regular => _interStyle(
    color: AppColors.tealA,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  // Doctor/profile title text.
  static TextStyle get doctorNameTeal20SemiBold => TextStyle(
    color: AppColors.tealPrimaryLight,
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
    height: 1.20,
  );

  // Doctor/profile meta text.
  static TextStyle get doctorMetaTeal16Regular => TextStyle(
    color: AppColors.tealPrimaryLight,
    fontSize: 16,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  // Numeric value in compact stat cards.
  static TextStyle get statNumberTealSurface12ExtraBold => TextStyle(
    color: AppColors.tealSurface,
    fontSize: 12,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w800,
    height: 1.25,
  );

  // Label in compact stat cards.
  static TextStyle get statLabelTealSurface10Regular => TextStyle(
    color: AppColors.tealSurface,
    fontSize: 10,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  // Notification page badge title style.
  static TextStyle get notificationBadgeTitle => _interStyle(
    color: AppColors.tealP,
    fontSize: 29,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.65,
  );

  // Empty/error main title style in notification contexts.
  static TextStyle get emptyStateTitleDark22Bold => _interStyle(
    color: AppColors.neutral750,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: 0.35,
  );

  // Empty/error supporting body text.
  static TextStyle get emptyStateBodyGray17Regular => _interStyle(
    color: AppColors.neutralLight,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.41,
  );

  // Teal action link style (Refresh / Try Again actions).
  static TextStyle get actionLinkTeal15SemiBold => _interStyle(
    color: AppColors.tealA,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.50,
  );

  // Notification list section header.
  static TextStyle get notificationSectionHeader16Medium => _interStyle(
    color: AppColors.textDark,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  // Sort button text in notification lists.
  static TextStyle get sortButtonText12Medium => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  // Notification item title text.
  static TextStyle get notificationTitleGray14Regular => _poppinsStyle(
    color: AppColors.textGray,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.60,
  );

  // Notification item subtitle text.
  static TextStyle get notificationSubtitleDark14Medium => _poppinsStyle(
    color: AppColors.textDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  // Notification timestamp text.
  static TextStyle get notificationTimeGray12Regular => _poppinsStyle(
    color: AppColors.textGray,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.60,
  );

  // Generic empty state title.
  static TextStyle get emptyBellTitle20SemiBold => _interStyle(
    color: AppColors.neutral900,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.40,
  );

  // Generic empty state body.
  static TextStyle get emptyBellBody15Regular => _interStyle(
    color: AppColors.neutralMid,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.40,
  );

  // Error state title style.
  static TextStyle get errorTitle22Bold => TextStyle(
    color: AppColors.neutral750,
    fontSize: 22,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: 0.35,
  );

  // Error state body style.
  static TextStyle get errorBody17Regular => TextStyle(
    color: AppColors.neutralLight,
    fontSize: 17,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.41,
  );

  // SF Pro action text variant used where native iOS look is required.
  static TextStyle get sfProActionLink15SemiBold => TextStyle(
    fontFamily: _getFontFamily('SF Pro Display'),
    color: AppColors.tealA,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.50,
  );

  // Search field floating label.
  static TextStyle get searchLabelTealDark12Regular => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Specialty chip text style.
  static TextStyle get chipTextTealIcon12BoldTight => TextStyle(
    color: AppColors.tealIconActive,
    fontSize: 12,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  // Search input and hint style.
  static TextStyle get searchInputBlack12Regular => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Doctor name style in search cards.
  static TextStyle get doctorNameTealDark22Bold => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 22,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    height: 0.91,
    letterSpacing: 0.1,
  );

  // Doctor specialty style in search cards.
  static TextStyle get doctorSpecialtyTealIcon12Bold => TextStyle(
    color: AppColors.tealIconActive,
    fontSize: 12,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  // Upload flow step title style.
  static TextStyle get uploadStepTitleTealDark20ExtraBold => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Small "Skip/More" chip text style.
  static TextStyle get skipTextTealIcon9Bold => TextStyle(
    color: AppColors.tealIconActive,
    fontSize: 9,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    letterSpacing: 0.10,
  );

  // Upload hints text style.
  static TextStyle get uploadHintNeutral700_12 => _interStyle(
    color: AppColors.neutral700,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Upload header text (e.g., uploaded files summary).
  static TextStyle get uploadHeaderMulish14Bold => TextStyle(
    color: AppColors.neutral700,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Upload file row text style.
  static TextStyle get uploadFileNameMulish12Regular => TextStyle(
    fontSize: 12,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Step circle number text in upload wizard.
  static TextStyle get uploadStepNode20SemiBold => TextStyle(
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
  );

  // Upload call-to-action card main headline.
  static TextStyle get uploadDataNowTealDark40Bold => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 40,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Upload call-to-action card supporting text.
  static TextStyle get uploadDataDescTealDark13Medium => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 13,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientDoctorDetailBodyBlackNeutral16Regular =>
      _interStyle(
        color: AppColors.blackNeutral,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.25,
      );

  static TextStyle get patientDoctorDetailReadMoreTeal16Regular => _interStyle(
    color: AppColors.tealA,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static TextStyle get patientDoctorDetailDotBlueDeep16Regular => _interStyle(
    color: AppColors.blueDeep,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static TextStyle get patientDoctorDetailSectionTitleBlackNeutral20ExtraBold =>
      _interStyle(
        color: AppColors.blackNeutral,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle get patientDoctorHeaderNameTeal18ExtraBold => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get patientDoctorHeaderMetaTeal14Medium => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientDoctorStatValueTealSurface16SemiBold => TextStyle(
    color: AppColors.tealSurface,
    fontSize: 16,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get patientDoctorStatLabelTealSurface12Regular => TextStyle(
    color: AppColors.tealSurface,
    fontSize: 12,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static TextStyle get patientProfileHeaderNameTeal18ExtraBold => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get patientProfileHeaderAgeTeal14Medium => _interStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientProfileSettingsRowGray800_16Regular =>
      _interStyle(
        color: AppColors.gray800,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get uploadHelpNeutralMid15SfProRegular => TextStyle(
    color: AppColors.neutralMid,
    fontSize: 15,
    fontFamily: _getFontFamily('SF Pro'),
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.40,
  );

  static TextStyle messagesHeaderName(Color color) =>
      _interStyle(color: color, fontSize: 17, fontWeight: FontWeight.w700);

  static TextStyle get messagesHeaderSubtitleBlack35_13Medium => _interStyle(
    color: AppColors.black.withValues(alpha: 0.35),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle messageBubbleText(Color textColor, double textSize) =>
      _interStyle(
        color: textColor,
        fontSize: textSize,
        fontWeight: FontWeight.w400,
        height: 1.2,
      );

  static TextStyle get messageComposerInputNeutral900_16Regular => _interStyle(
    color: AppColors.neutral900,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle messageComposerHint(Color color) =>
      _interStyle(color: color, fontSize: 17, fontWeight: FontWeight.w400);

  static TextStyle get messageTimestampShadowBlack30_12Medium => _interStyle(
    color: AppColors.shadowBlack30,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Teal-surface button text for compact CTAs.
  static TextStyle get buttonTextTealSurface15ExtraBold => TextStyle(
    color: AppColors.tealSurface,
    fontSize: 15,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Patient profile title style.
  static TextStyle get profileNameTealDark18ExtraBold => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 18,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Patient profile subtitle/meta style.
  static TextStyle get profileMetaTealDark14Medium => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w500,
  );

  // QR modal title style.
  static TextStyle get qrModalTitleTealDark20Bold => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Generic Roboto black body style used in QR instructions.
  static TextStyle get robotoBlack14Regular => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
  );

  // Black extra-bold heading used in charts sections.
  static TextStyle get titleBlack18ExtraBold => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 18,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Black medium subtitle used under headings.
  static TextStyle get subtitleBlack14Medium => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w500,
  );

  // Action text style used in outlined secondary actions.
  static TextStyle get actionTealP14Regular => TextStyle(
    color: AppColors.tealP,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // =====================================================
  // Doctor
  // =====================================================

  static TextStyle get doctorOverviewHeaderRedDarkest20ExtraBold => _interStyle(
    color: AppColors.redDarkest,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get doctorWelcomeTitleBlack30CroissantRegular => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 24,
    fontFamily: _getFontFamily('CroissantOne'),
    fontWeight: FontWeight.w400,
  );

  static TextStyle get doctorWelcomeDescriptionNeutral550_17 => _interStyle(
    color: AppColors.neutral550,
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get doctorTaskTitleGray850_16Bold => TextStyle(
    color: AppColors.gray850,
    fontSize: 16,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w700,
  );

  static TextStyle get doctorTaskDescriptionNeutral300_13 => TextStyle(
    color: AppColors.neutral300,
    fontSize: 13,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextStyle get doctorTaskTimeNeutral300_11Medium => TextStyle(
    color: AppColors.neutral300,
    fontSize: 11,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w500,
  );

  static TextStyle get doctorStatTitleRedDarkest13ExtraBold => _interStyle(
    color: AppColors.redDarkest,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static TextStyle get doctorStatValueGreenMintSnow16ExtraBold => _interStyle(
    color: AppColors.greenMintSnow,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get doctorFilterLabelRedMaroon12Bold => _interStyle(
    color: AppColors.redMaroon,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get doctorDataTableHeaderNeutral450_11ExtraBold =>
      _interStyle(
        color: AppColors.neutral450,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get doctorDataTableCellNeutral450_11Bold => _interStyle(
    color: AppColors.neutral450,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get doctorConversationNameBlack17Regular => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.40,
  );

  static TextStyle get doctorUnreadBadgeWhite10Bold => _interStyle(
    color: AppColors.white,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  static TextStyle doctorConversationPreviewBlack14Regular(double alpha) =>
      _interStyle(
        color: AppColors.neutralBlack.withValues(alpha: alpha),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: -0.15,
      );

  static TextStyle get doctorProfileBioBlackNeutral16Regular => _interStyle(
    color: AppColors.blackNeutral,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static TextStyle get doctorProfileReadMoreRedDeep16Black => _interStyle(
    color: AppColors.redDeep,
    fontSize: 16,
    fontWeight: FontWeight.w900,
    height: 1.25,
  );

  static TextStyle get doctorActionTextRedDeep27ExtraBold => _interStyle(
    color: AppColors.redDeep,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get doctorActionTextRedSurface27ExtraBold => _interStyle(
    color: AppColors.redSurface,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get doctorProfileNameRedNearBlack20SemiBold => TextStyle(
    color: AppColors.redNearBlack,
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get doctorSpecialtyRedNearBlack16Regular => TextStyle(
    color: AppColors.redNearBlack,
    fontSize: 16,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static TextStyle get doctorStatCardValueRedSurface12Black => _interStyle(
    color: AppColors.redSurface,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    height: 1.67,
  );

  static TextStyle get doctorStatCardLabelRedSurface12Medium => _interStyle(
    color: AppColors.redSurface,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static TextStyle get doctorContactValueBlack18Light => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 18,
    fontWeight: FontWeight.w300,
  );

  static TextStyle get doctorInputLabelNeutral300_13Medium => TextStyle(
    color: AppColors.neutral300,
    fontSize: 13,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static TextStyle get doctorInputValueGray850_14Regular => TextStyle(
    color: AppColors.gray850,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
  );

  static TextStyle get doctorGenderHintNeutral300_12Regular => TextStyle(
    color: AppColors.neutral300,
    fontSize: 12,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static TextStyle get doctorNotificationLatestHeaderDark16Medium =>
      _interStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.60,
      );

  static TextStyle get doctorNotificationSortByDark12Medium => _interStyle(
    color: AppColors.textDark,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  static TextStyle get doctorNotificationEmptyTitleGray900_20SemiBold =>
      TextStyle(
        color: AppColors.gray900,
        fontSize: 20,
        fontFamily: _getFontFamily('SF Pro Display'),
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.40,
      );

  static TextStyle get doctorNotificationEmptyBodyNeutralMid15Regular =>
      TextStyle(
        color: AppColors.neutralMid,
        fontSize: 15,
        fontFamily: _getFontFamily('SF Pro Display'),
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: -0.40,
      );

  static TextStyle get doctorNotificationFallbackTitleGray900_20Bold =>
      _interStyle(
        color: AppColors.gray900,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get doctorNotificationFallbackBodyNeutralMid15Regular =>
      _interStyle(
        color: AppColors.neutralMid,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get doctorNotificationItemTitleTextGray14Regular =>
      _interStyle(
        color: AppColors.textGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.60,
      );

  static TextStyle get doctorNotificationItemSubtitleTextDark14Medium =>
      _interStyle(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.60,
      );

  static TextStyle get doctorNotificationItemMetaTextGray12Regular =>
      _interStyle(
        color: AppColors.textGray,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.60,
      );

  static TextStyle get doctorQrDetectedTitleRedDeep20Bold => _interStyle(
    color: AppColors.redDeep,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get doctorScanAgainRedDeep14Medium => _interStyle(
    color: AppColors.redDeep,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientDetailNameBlack18ExtraBold => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get patientDetailLabelBlack14SemiBold => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get patientDetailValueBlack14Light => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  static TextStyle get patientDetailMetaBlack14Medium => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientDetailSectionTitleBlack18ExtraBold => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get patientDetailAuxLabelBlack11Medium => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get patientDetailTableHeaderBlack70_10ExtraBold =>
      _interStyle(
        color: Color(0xB3000000),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get patientDetailTableCellNeutral450_10ExtraBold =>
      _interStyle(
        color: AppColors.neutral450,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get patientDetailPrimaryActionRedSurface16ExtraBold =>
      _interStyle(
        color: AppColors.redSurface,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get patientDetailSecondaryActionRedDeep16ExtraBold =>
      _interStyle(
        color: AppColors.redDeep,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get patientDetailChatLabelGray800Alt12Regular => _interStyle(
    color: AppColors.gray800Alt,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get patientDetailStrokeRiskTitleBlack75_20ExtraBold =>
      _interStyle(
        color: Color(0xBF000000),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      );

  static TextStyle patientDetailSegmentTab(bool selected) => TextStyle(
    color: selected ? AppColors.redSurface : AppColors.gray800Alt,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.10,
  );

  static TextStyle doctorStoryAvatarName(bool isYourStory) => TextStyle(
    color: AppColors.neutralBlack.withValues(alpha: 0.35),
    fontSize: 13,
    fontFamily: isYourStory ? 'SF Pro Text' : 'Roboto',
    fontWeight: isYourStory ? FontWeight.w400 : FontWeight.w700,
    height: 1.38,
    letterSpacing: -0.08,
  );

  static TextStyle doctorGenderButtonLabel(bool selected) => TextStyle(
    color: AppColors.gray850,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // =====================================================
  // Wellness
  // =====================================================

  // Legend text style for chart labels.
  static TextStyle get chartLegendText14Regular => _interStyle(
    color: AppColors.neutral350,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.14,
  );

  // Card title style in wellness charts.
  static TextStyle get chartCardTitleTealDarker20ExtraBold => TextStyle(
    color: AppColors.tealPrimaryDarker,
    fontSize: 20,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Small legend label style (Normal / Unnormal).
  static TextStyle get chartLegendLabelNeutral350_12 => _interStyle(
    color: AppColors.neutral350,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Y-axis compact numeric labels (bold variant).
  static TextStyle get chartAxisLabel9ExtraBold => TextStyle(
    color: AppColors.neutral350,
    fontSize: 9,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Axis/tick compact labels (regular variant).
  static TextStyle get chartAxisLabel9Regular => _interStyle(
    color: AppColors.neutral350,
    fontSize: 9,
    fontWeight: FontWeight.w400,
  );

  // Metric card title style.
  static TextStyle get metricCardTitleTealDarker16ExtraBold => TextStyle(
    color: AppColors.tealPrimaryDarker,
    fontSize: 16,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
  );

  // Small metric label style (e.g., Oxygen).
  static TextStyle get metricLabelNeutral600_12SemiBold => TextStyle(
    color: AppColors.neutral600,
    fontSize: 12,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
  );

  // Main metric numeric value style.
  static TextStyle get metricValueNeutral850_24SemiBold => TextStyle(
    color: AppColors.neutral850,
    fontSize: 24,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
  );

  // Generic metric description text style (neutral).
  static TextStyle get metricDescNeutral600_14Bold => TextStyle(
    color: AppColors.neutral600,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Highlighted teal part inside metric rich text.
  static TextStyle get metricDescTeal14Bold => TextStyle(
    color: AppColors.tealPrimaryLight,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Section title in stroke/risk cards.
  static TextStyle get riskStrokeTitle16SemiBold => TextStyle(
    color: AppColors.neutral850,
    fontSize: 16,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
    height: 1.50,
  );

  // Connection status text style in risk cards.
  static TextStyle get connectedLabelTealDarker11Regular => _interStyle(
    color: AppColors.tealPrimaryDarker,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.82,
  );

  // Generic muted risk label style.
  static TextStyle get riskLabelNeutral600 => _interStyle(
    color: AppColors.neutral600,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Risk percentage highlight style.
  static TextStyle get riskPercentRedSoft24Bold => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: _getFontFamily('Poppins'),
    color: AppColors.redSoft,
  );

  // Black emphasized part in metric/risk rich text.
  static TextStyle get metricDescBlack14Bold => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Status badge label style.
  static TextStyle get chartStatusLabel14SemiBold =>
      _interStyle(fontSize: 14, fontWeight: FontWeight.w600);

  // Status badge value style.
  static TextStyle get chartStatusValue10ExtraBold =>
      _interStyle(fontSize: 10, fontWeight: FontWeight.w800);

  // Status value style in metrics cards (poppins variant).
  static TextStyle get metricStatusPoppins24SemiBold => TextStyle(
    fontSize: 24,
    fontFamily: _getFontFamily('Poppins'),
    fontWeight: FontWeight.w600,
  );

  // Device disconnected card title.
  static TextStyle get deviceNotConnectedTitle20Bold => _interStyle(
    color: AppColors.neutral900,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  // Device disconnected card body paragraph.
  static TextStyle get deviceNotConnectedBody14Regular => _interStyle(
    color: AppColors.neutral700,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Greeting title in patient home header.
  static TextStyle get greetingAladin38TealDark => TextStyle(
    color: AppColors.tealPrimaryDark,
    fontSize: 38,
    fontFamily: _getFontFamily('Aladin'),
    fontWeight: FontWeight.w400,
  );

  // Greeting username text in patient home header.
  static TextStyle get greetingUserName12MediumBlack => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // =====================================================
  // Common
  // =====================================================

  // Legacy base style kept for backward compatibility.
  static TextStyle get textStyleFontsize20WithWeight600AndBlackColor =>
      TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack,
      );

  // Main submit button text style used by reusable submit button widget.
  static TextStyle get submitButtonTealSurface27ExtraBold => _interStyle(
    color: AppColors.tealSurface,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  // Standard form field label style.
  static TextStyle get formLabelNeutral16Medium => TextStyle(
    color: AppColors.neutral300,
    fontSize: 16,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w500,
  );

  // Standard form helper style.
  static TextStyle get formHelperNeutral12Regular => TextStyle(
    color: AppColors.neutral300,
    fontSize: 12,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
  );

  // Form error text style.
  static TextStyle get formErrorRed12Roboto => TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontFamily: _getFontFamily('Roboto'),
  );

  // Checkbox primary label style.
  static TextStyle get checkboxLabelNeutral850_16 => _interStyle(
    color: AppColors.neutral850,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  // Checkbox secondary/description style.
  static TextStyle get checkboxDescriptionNeutral500_16 => _interStyle(
    color: AppColors.neutral500,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  // Time text used in custom status bars.
  static TextStyle get statusBarTime14Regular => _interStyle(
    color: AppColors.neutral750,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  // Icon font text style used in status icon placeholders.
  static TextStyle get statusIconText12Black => TextStyle(
    color: AppColors.neutral750,
    fontSize: 12,
    fontFamily: _getFontFamily('Font Awesome 5 Free'),
    fontWeight: FontWeight.w900,
    height: 1.33,
  );

  // Generic role card title style with runtime color/size overrides.
  static TextStyle roleCardTitleInter(Color color, double? fontSize) =>
      _interStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
      );

  // Role card description style.
  static TextStyle get roleCardDescription12Light => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  // Toggle group option text style with runtime color override.
  static TextStyle toggleOptionText14Roboto500(Color color) => TextStyle(
    color: color,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w500,
  );

  // Bottom navigation item label style with selected-state weight.
  static TextStyle navItemLabel12(Color color, bool selected) => _interStyle(
    color: color,
    fontSize: 12,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
  );

  // Search field input/hint style.
  static TextStyle get searchFieldInputBlack12Inter => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Mulish upload prompt text (neutral variant).
  static TextStyle get uploadMulish16BoldNeutral850 => TextStyle(
    color: AppColors.neutral850,
    fontSize: 16,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  // Mulish upload prompt text (teal underlined variant).
  static TextStyle get uploadMulish16BoldTealUnderline => TextStyle(
    color: AppColors.tealP,
    fontSize: 16,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    height: 1.5,
  );

  // Common call identity panel name.
  static TextStyle get callIdentityNameWhite24Bold => _interStyle(
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  // Common call identity panel status text.
  static TextStyle callIdentityStatusWhite17(double alpha) => _interStyle(
    color: AppColors.white.withValues(alpha: alpha),
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.33,
  );

  // Rear camera tag in call views.
  static TextStyle get rearCameraLabelWhite70_12 => _interStyle(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Doctor offline title/body/actions used in global guard.
  static TextStyle get doctorOfflineTitleRed22BoldSfPro => TextStyle(
    color: AppColors.redDeep,
    fontSize: 22,
    fontFamily: _getFontFamily('SF Pro Display'),
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: 0.35,
  );

  static TextStyle get doctorOfflineBodyNeutral17RegularSfPro => TextStyle(
    color: AppColors.neutralLight,
    fontSize: 17,
    fontFamily: _getFontFamily('SF Pro Display'),
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.41,
  );

  static TextStyle get doctorOfflineRefreshRedSoft15SemiBoldSfPro => TextStyle(
    color: AppColors.redSoft,
    fontSize: 15,
    fontFamily: _getFontFamily('SF Pro Display'),
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.50,
  );

  static TextStyle get doctorOfflineBackRed27ExtraBold => _interStyle(
    color: AppColors.redDeep,
    fontSize: 27,
    fontWeight: FontWeight.w800,
  );

  // Logout confirm dialog dynamic styles.
  static TextStyle logoutConfirmTitle(Color color, double fontSize) =>
      _interStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.1,
        shadows: [
          Shadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      );

  static TextStyle logoutConfirmAction(Color color, double fontSize) =>
      _interStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
      );

  // Common home search styles.
  static TextStyle get homeSearchHelperBlack14RobotoRegular => TextStyle(
    color: AppColors.neutralBlack,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
  );

  static TextStyle get homeSearchResultNameGray850_16Regular => TextStyle(
    color: AppColors.gray850,
    fontSize: 16,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.50,
  );

  static TextStyle get homeSearchResultMetaNeutral300_14Regular => TextStyle(
    color: AppColors.neutral300,
    fontSize: 14,
    fontFamily: _getFontFamily('Roboto'),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get homeSearchCriticalBlack10ExtraBold => _interStyle(
    color: AppColors.neutralBlack,
    fontSize: 10,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get homeSearchEmptyTitleGray900_20BoldSfPro => TextStyle(
    color: AppColors.gray900,
    fontSize: 20,
    fontFamily: _getFontFamily('SF Pro Display'),
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get homeSearchEmptyBodyNeutralMid15RegularSfPro => TextStyle(
    color: AppColors.neutralMid,
    fontSize: 15,
    fontFamily: _getFontFamily('SF Pro Display'),
    fontWeight: FontWeight.w400,
    height: 1.33,
  );
}
