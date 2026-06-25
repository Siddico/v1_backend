import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/role_theme_config.dart';

import 'background_circle.dart';

/// Reusable bottom decorative circles used in auth/patient screens.
/// Colors are dynamically determined by the role theme.
class BottomBackgroundCircles extends StatelessWidget {
  final RoleThemeConfig? themeConfig;

  const BottomBackgroundCircles({super.key, this.themeConfig});

  @override
  Widget build(BuildContext context) {
    // Use provided theme or fall back to patient theme
    final theme = themeConfig ?? RoleThemeConfig.fromRole(UserRole.patient);

    return Stack(
      children: [
        Positioned(
          left: -189,
          bottom: -368,
          child: BackgroundCircle(
            width: 482,
            height: 486,
            color: theme.primaryColor,
            shadows: theme.getCircleShadows(),
          ),
        ),
        Positioned(
          left: -200,
          bottom: -373,
          child: BackgroundCircle(
            width: 482,
            height: 486,
            color: AppColors.white,
            shadows: [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 111,
                offset: Offset(11, 22),
                spreadRadius: 11,
              ),
            ],
          ),
        ),
        Positioned(
          left: -50,
          bottom: -100,
          child: BackgroundCircle(
            width: 154,
            height: 153,
            color: theme.accentColor,
          ),
        ),
      ],
    );
  }
}
