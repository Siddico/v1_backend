import 'package:flutter/material.dart';

class PatientProfileSettingsItemData {
  const PatientProfileSettingsItemData({
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.key,
    this.iconColor,
  });

  final String iconPath;
  final String title;
  final VoidCallback onTap;
  final Key? key;
  final Color? iconColor;
}
