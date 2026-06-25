import 'package:flutter/material.dart';
// File no longer contains Google Fonts imports as all fonts have been migrated to local fonts defined in pubspec.yaml

class AppTypography {
  AppTypography._();

  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 30;

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppFonts {
  AppFonts._();

  static const String inter = 'Inter';
  static const String poppins = 'Poppins';
  static const String aladin = 'Aladin';
  static const String roboto = 'Roboto';

  static String get croissantOne => 'CroissantOne';
}
