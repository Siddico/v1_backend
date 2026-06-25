import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';

class RoleModel {
  final String title;
  final String description;
  final Color titleColor;
  final Color imageCardShadowColor;
  final String imageLogoRole;
  final double? titleFontSize;

  const RoleModel({
    required this.title,
    required this.description,
    required this.titleColor,
    required this.imageCardShadowColor,
    required this.imageLogoRole,
    this.titleFontSize = 27,
  });
}

class RoleSelectionConstants {
  // static const String imageUrl = AppImages.roleImagePlaceholder;

  static final List<RoleModel> roles = [
    RoleModel(
      title: 'Doctor',
      description: 'Access patient data and monitor health insights.',
      titleColor: AppColors.redDeep,
      imageCardShadowColor: AppColors.shadowRed25,
      imageLogoRole: AppImages.doctorLogoRole,
    ),
    RoleModel(
      title: 'Patient',
      description: 'Track your health status and connect with your doctor.',
      titleColor: AppColors.tealPrimaryDark,
      imageCardShadowColor: AppColors.tealAccentMuted,
      imageLogoRole: AppImages.patientLogoRole,
    ),
    RoleModel(
      title: 'Researcher',
      description: 'Explore and analyze medical papers and data.',
      titleColor: AppColors.bluePrimary,
      imageCardShadowColor: AppColors.shadowPurple,
      titleFontSize: 22,
      imageLogoRole: AppImages.researcherLogoRole,
    ),
  ];
}
