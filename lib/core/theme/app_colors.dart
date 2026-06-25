import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class AppColors {
  AppColors._();

  // Red theme (patient/doctor)
  static const Color redPrimary = Color(0xFFC41E3A);
  static const Color redSecondary = Color(0xFFE5556B);
  static const Color redBackground = Color(0xFFFFF8F9);
  static const Color redAccent = Color(0xFF8F1026);

  // Teal theme (researcher)
  static const Color tealPrimary = Color(0xFF00A896);
  static const Color tealSecondary = Color(0xFF4ECDC4);
  static const Color tealBackground = Color(0xFFF0F8F7);
  static const Color tealAccent = Color(0xFF4BBFCB);

  // Neutral
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color textPrimary = neutral800;
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFE6E6E6);

  // Teal palette (patient flow)
  static const Color tealPrimaryDark = Color(0xFF166771);
  static const Color tealP = Color(0xFF1B808E);
  static const Color tealPrimaryDarker = Color(0xFF104D55);
  static const Color tealPrimaryLight = Color(0xFF209AAA);
  static const Color tealPrimarySoft = Color(0xFF13A9B3);
  static const Color tealA = Color(0xFF24ABBD);
  static const Color tealAccentLight = Color(0xFF00C3D0);
  static const Color tealAccentMuted = Color(0xFF0090A5);
  static const Color tealAccentBright = Color(0xFF2397A5);
  static const Color tealIconActive = Color(0xFF1C8897);
  static const Color tealBorderLight = Color(0xFFBBE5EB);
  static const Color tealSurface = Color(0xFFE9F7F8);
  static const Color tealSurfaceAlt = Color(0xFFDEF2F5);

  // Red palette
  static const Color redDeep = Color(0xFFAB2133);
  static const Color redStrong = Color(0xFFC8102E);
  static const Color redButton = Color(0xFFBD2438);
  static const Color redLight = Color(0xFFE57373);
  static const Color redSoft = Color(0xFFE77E8C);
  static const Color redSurface = Color(0xFFFBEAEC);
  static const Color redDarkest = Color(0xFF2B080D);
  static const Color redNearBlack = Color(0xFF150406);

  // Blues and indigos
  static const Color bluePrimary = Color(0xFF024E88);
  static const Color blueSecondary = Color(0xFF035D9F);
  static const Color indigoDark = Color(0xFF1E1B39);
  static const Color indigoMuted = Color(0xFF615E82);

  // Neutral scale
  static const Color neutralBlack = Color(0xFF000000);
  static const Color neutralNearBlack = Color(0xFF010101);
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral850 = Color(0xFF1E1E1E);
  static const Color neutral800 = Color(0xFF1F1F1F);
  static const Color neutral750 = Color(0xFF1A2525);
  static const Color neutral700 = Color(0xFF6B7280);
  static const Color neutral650 = Color(0xFF8B95A5);
  static const Color neutral600 = Color(0xFF9CA3AF);
  static const Color neutral550 = Color(0xFF999999);
  static const Color neutral500 = Color(0xFF757575);
  static const Color neutral450 = Color(0xFF8E8E93);
  static const Color neutral400 = Color(0xFF79747E);
  static const Color neutral350 = indigoMuted;
  static const Color neutral300 = Color(0xFF49454F);
  static const Color neutral250 = Color(0xFFBFBFBF);
  static const Color neutral200 = Color(0xFFE5E5EF);
  static const Color neutral150 = Color(0xFFF2F4F7);
  static const Color neutral100 = Color(0xFFE8EAF6);

  // Additional UI colors
  static const Color grayLight = Color(0xFFEEEEEE);
  static const Color grayBorder = Color(0xFFAEAEB2);
  static const Color grayDivider = Color(0xFFE3E3E3);
  static const Color otpBorder = Color(0x993C3C43);

  // Notification status colors
  static const Color successGreen = Color(0xFF24BD83);
  static const Color warningYellow = Color(0xFFFFCC00);

  // Extended neutral palette
  static const Color textDark = Color(0xFF0C1523);
  static const Color textGray = Color(0xFF667085);
  static const Color neutralLighter = Color(0xFFF0F1F3);
  static const Color neutralMid = Color(0xFF525252);
  static const Color neutralLight = Color(0xFFA0A0A0);
  static const Color neutralSurface = Color(0xFFF2F2F7);

  // Shadows / overlays
  static const Color shadowBlack05 = Color(0x0F000000);
  static const Color shadowBlack08 = Color(0x14000000);
  static const Color shadowBlack10 = Color(0x1A000000);
  static const Color shadowLight11 = Color(0x1C000000);
  static const Color shadowBlack20 = Color(0x33000000);
  static const Color shadowBlack25 = Color(0x3F000000);
  static const Color shadowGray25 = Color(0x3F898A87);
  static const Color shadowBlack30 = Color(0x4D000000);
  static const Color shadowBlack31 = Color(0x50000000);
  static const Color shadowBlack33 = Color(0x55000000);
  static const Color shadowRed25 = Color(0x3FFF0000);
  static const Color shadowPurple = Color(0x770471BE);

  // Extended colors palette
  static const Color tealGreen = Color(0xFF00927F);
  static const Color tealBlue = Color(0xFF009CBC);
  static const Color tealAzure = Color(0xFF24A7BD);
  static const Color blueBright = Color(0xFF0471BE);
  static const Color blueDeep = Color(0xFF0A5EB0);
  static const Color blueLight = Color(0xFF6FB9FE);
  static const Color blueIce = Color(0xFFE3F0FF);
  static const Color blueGhost = Color(0xFFF2F8FF);
  static const Color blueGrayLight = Color(0xFFDCE3EF);

  static const Color greenForest = Color(0xFF0F8E5E);
  static const Color greenDark = Color(0xFF10553B);
  static const Color emeraldGreen = Color(0xFF26A69A);
  static const Color greenMintLight = Color(0xFFBBEBD9);
  static const Color greenMintSnow = Color(0xFFE9F8F3);

  static const Color redMaroon = Color(0xFF56101A);
  static const Color redCrimson = Color(0xFF6E1F2A);
  static const Color redAlert = Color(0xFFA20A0A);
  static const Color redVivid = Color(0xFFCE1126);
  static const Color redCoral = Color(0xFFDE5466);
  static const Color redRose = Color(0xFFE34949);
  static const Color redBright = Color(0xFFFF3939);

  static const Color yellowMustard = Color(0xFF8E6D00);
  static const Color yellowPale = Color(0xFFFFEA99);

  static const Color cyanMuted = Color(0xFF61CEE0);
  static const Color cyanLightest = Color(0xFFCCEFEB);

  static const Color pinkBlush = Color(0xFFEFA9B3);
  static const Color pinkLight = Color(0xFFF7D4D9);
  static const Color pinkLace = Color(0x0ffde8ec);

  static const Color blackNeutral = Color(0xFF11120F);
  static const Color gray900Extra = Color(0xFF171717);
  static const Color gray850Alt = Color(0xFF1C1B1F);
  static const Color gray800Alt = Color(0xFF333333);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray850 = Color(0xFF1C1B1F);
  static const Color gray900 = Color(0xFF171717);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray100 = Color(0xFFEDEDED);
  static const Color gray50 = Color(0xFFF4F4F4);

  static const Color lavenderLight = Color(0xFFF6F6FA);

  static ThemeData redTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: redPrimary,
        primary: redPrimary,
        secondary: redSecondary,
        tertiary: redAccent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: redBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: redPrimary,
        foregroundColor: white,
        elevation: 0,
      ),
    );
  }

  static ThemeData tealTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: tealPrimary,
        primary: tealPrimary,
        secondary: tealSecondary,
        tertiary: tealAccent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: tealBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: tealPrimary,
        foregroundColor: white,
        elevation: 0,
      ),
    );
  }
}
