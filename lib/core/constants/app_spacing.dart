import 'package:flutter/material.dart';

/// Centralized spacing and padding constants for consistent UI.
class AppSpacing {
  AppSpacing._();

  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Padding presets - All sides
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Padding presets - Horizontal & Vertical
  static const EdgeInsets paddingH16V20 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 20,
  );
  static const EdgeInsets paddingH16V6 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 6,
  );
  static const EdgeInsets paddingH16V8 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets paddingH18V8 = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 8,
  );
  static const EdgeInsets paddingH25 = EdgeInsets.symmetric(horizontal: 25);

  // SizedBox presets - Heights
  static const SizedBox gapXS = SizedBox(height: xs);
  static const SizedBox gapSM = SizedBox(height: sm);
  static const SizedBox gapMD = SizedBox(height: md);
  static const SizedBox gapLG = SizedBox(height: lg);
  static const SizedBox gapXL = SizedBox(height: xl);
  static const SizedBox gapXXL = SizedBox(height: xxl);
  static const SizedBox gapXXXL = SizedBox(height: xxxl);

  // SizedBox presets - Widths
  static const SizedBox gapWidthXS = SizedBox(width: xs);
  static const SizedBox gapWidthSM = SizedBox(width: sm);
  static const SizedBox gapWidthMD = SizedBox(width: md);
  static const SizedBox gapWidthLG = SizedBox(width: lg);
}
