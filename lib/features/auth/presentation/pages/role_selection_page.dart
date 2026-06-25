import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../domain/entities/role_selection_entity.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../core/localization/app_localizations.dart';
import '../widgets/role_detail_card.dart';
import '../widgets/role_image_card.dart';
import '../controllers/role_controller.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  final bool _isDarkMode = false;

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    String roleTitle,
  ) async {
    final UserRole selectedRole = _mapRoleTitle(roleTitle);

    if (selectedRole == UserRole.researcher) {
      AppToast.show(
        context,
        'Coming soon!'.tr(context),
        type: AppToastType.warning,
        role: UserRole.researcher,
      );
      return;
    }

    await ref.read(roleProvider.notifier).setRole(selectedRole);

    final String nextRoute = selectedRole == UserRole.patient
        ? AppConstants.routeSignup
        : AppConstants.routeLogin;

    // ignore: use_build_context_synchronously
    context.go(nextRoute);
  }

  UserRole _mapRoleTitle(String roleTitle) {
    switch (roleTitle.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'researcher':
        return UserRole.researcher;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            // Triangle background image
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: ClipRect(
                child: SizedBox(
                  width: double.infinity,
                  height: 600,
                  child: Image.asset(
                    AppImages.triangleOfRoleSelectionView,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Content on top
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppBarControls(
                  isDarkMode: _isDarkMode,
                  onDarkModeToggle: () {},
                  onLanguageSelect: () {},
                  darkModeToggleLightColor: const Color(0xFFE77E8C),
                  darkModeToggleDarkColor: const Color(0xFFAB2133),
                ),
                const SizedBox(height: 20),
                Text(
                  'you are',
                  style: AppTextStyles.roleTitleCroissant50RedDarkest,
                ),
                const SizedBox(height: 15),
                Text(
                  'identify your role to continue'.tr(context),
                  style: AppTextStyles.authSubtitleNeutral550_22,
                ),

                // Role cards section with padding
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20,
                    top: 46,
                    end: 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var role in RoleSelectionConstants.roles) ...[
                        GestureDetector(
                          onTap: () => _selectRole(context, ref, role.title),
                          child: Row(
                            children: [
                              // Role image card
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: RoleImageCard(
                                  imageUrl: RoleSelectionConstants.roles
                                      .firstWhere((r) => r.title == role.title)
                                      .imageLogoRole,
                                  shadowColor: role.imageCardShadowColor,
                                ),
                              ),
                              const SizedBox(width: 11),
                              // Role detail card
                              Expanded(
                                child: RoleDetailCard(
                                  roleTitle: role.title.tr(context),
                                  roleDescription: role.description.tr(context),
                                  titleColor: role.titleColor,
                                  titleFontSize: role.titleFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 52),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
