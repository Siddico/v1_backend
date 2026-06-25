import 'package:flutter/material.dart';

import 'dark_mode_toggle.dart';
import 'language_selector.dart';

/// A reusable widget that combines language selector and dark mode toggle
class AppBarControls extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onDarkModeToggle;
  final VoidCallback onLanguageSelect;
  final Color? darkModeToggleLightColor;
  final Color? darkModeToggleDarkColor;
  final Color? languageTextColor;

  const AppBarControls({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    required this.onLanguageSelect,
    this.darkModeToggleLightColor,
    this.darkModeToggleDarkColor,
    this.languageTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 27.0, start: 27, top: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LanguageSelector(
            onTap: onLanguageSelect,
            textColor: languageTextColor ?? darkModeToggleDarkColor,
          ),
          DarkModeToggle(
            isDarkMode: isDarkMode,
            onTap: onDarkModeToggle,
            lightColor: darkModeToggleLightColor,
            darkColor: darkModeToggleDarkColor,
          ),
        ],
      ),
    );
  }
}
