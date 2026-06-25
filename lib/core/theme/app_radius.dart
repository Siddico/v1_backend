import 'package:flutter/material.dart';

/// Centralized border radius constants for consistent UI.
class AppRadius {
  AppRadius._();

  // Radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 22.0;
  static const double xxl = 32.0;
  static const double full = 999.0; // Circular

  // BorderRadius presets
  static final BorderRadius radiusXS = BorderRadius.circular(xs);
  static final BorderRadius radiusSM = BorderRadius.circular(sm);
  static final BorderRadius radiusMD = BorderRadius.circular(md);
  static final BorderRadius radiusLG = BorderRadius.circular(lg);
  static final BorderRadius radiusXL = BorderRadius.circular(xl);
  static final BorderRadius radiusXXL = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // Common use cases
  static final BorderRadius card = radiusLG; // 16
  static final BorderRadius button = radiusXL; // 22
  static final BorderRadius input = radiusMD; // 12
  static final BorderRadius chip = radiusSM; // 8
  static final BorderRadius dialog = radiusLG; // 16
}
