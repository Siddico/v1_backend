import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized shadow constants for consistent UI elevation.
class AppShadows {
  AppShadows._();

  // Shadow presets
  static const BoxShadow light = BoxShadow(
    color: AppColors.shadowBlack10, // 10% opacity
    blurRadius: 4,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const BoxShadow standard = BoxShadow(
    color: AppColors.shadowBlack25,
    blurRadius: 6,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow medium = BoxShadow(
    color: AppColors.shadowBlack25, // 25% opacity
    blurRadius: 6,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow heavy = BoxShadow(
    color: AppColors.shadowBlack31, // 31% opacity
    blurRadius: 10,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );

  static const BoxShadow button = BoxShadow(
    color: AppColors.shadowBlack25,
    blurRadius: 6,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );

  // Shadow lists (commonly used in decoration)
  static const List<BoxShadow> lightShadow = [light];
  static const List<BoxShadow> standardShadow = [standard];
  static const List<BoxShadow> mediumShadow = [medium];
  static const List<BoxShadow> heavyShadow = [heavy];
  static const List<BoxShadow> buttonShadow = [button];

  // Common use cases
  static const List<BoxShadow> card = standardShadow;
  static const List<BoxShadow> dialog = mediumShadow;
  static const List<BoxShadow> elevated = heavyShadow;
}
