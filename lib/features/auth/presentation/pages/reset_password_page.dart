import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/custom_back_button.dart';
import '../../domain/password_reset_session.dart';
import '../controllers/auth_providers.dart';
import '../controllers/role_controller.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_submit_button.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.session});

  final PasswordResetSession session;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = ref.watch(roleProvider) ?? UserRole.patient;
    final themeConfig = RoleThemeConfig.fromRole(selectedRole);
    final authState = ref.watch(authControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final titleScale = (screenWidth / 402).clamp(0.76, 1.0);
    final subtitleScale = (screenWidth / 402).clamp(0.84, 1.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: AppBarControls(
              isDarkMode: _isDarkMode,
              onDarkModeToggle: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              onLanguageSelect: () {},
              darkModeToggleLightColor: themeConfig.darkModeToggleLightColor,
              darkModeToggleDarkColor: themeConfig.darkModeToggleDarkColor,
            ),
          ),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsetsDirectional.only(
              top: 117,
              end: 20,
              start: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.authHeroTitleCroissant50TealDark
                              .copyWith(
                                fontSize: 50 * titleScale,
                                color: themeConfig.primaryDarkColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${'Create a new password for'.tr(context)} ${widget.session.email}.',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.authSubtitleNeutral550_22
                              .copyWith(
                                fontSize: 22 * subtitleScale,
                                color:
                                    themeConfig.forgotPasswordDescriptionColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      CustomFormField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        helperText: AppStrings.passwordHelper,
                        validator: Validators.validatePassword,
                        obscureText: true,
                        focusedBorderColor: themeConfig.primaryDarkColor,
                      ),
                      const SizedBox(height: 12),
                      CustomFormField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        helperText: 'Re-enter your new password',
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                        obscureText: true,
                        focusedBorderColor: themeConfig.primaryDarkColor,
                      ),
                      const SizedBox(height: 63),
                      Row(
                        children: [
                          Expanded(
                            child: CustomSubmitButton(
                              onTap: authState.isLoading ? null : _submit,
                              isLoading: authState.isLoading,
                              label: AppStrings.submit,
                              backgroundColor: themeConfig.buttonColor,
                              textColor: themeConfig.surfaceColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomBackButton(
                            onTap: () => context.pop(),
                            borderColor: themeConfig.primaryDarkColor,
                            textColor: themeConfig.primaryDarkColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomBackgroundCircles(themeConfig: themeConfig),
          if (authState.isLoading)
            Container(
              color: AppColors.shadowBlack25,
              child: Center(
                child: CircularLoadingIndicator(
                  size: 68,
                  color: themeConfig.primaryDarkColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: widget.session.email,
          otp: widget.session.otp,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    final selectedRole = ref.read(roleProvider) ?? UserRole.patient;

    if (authState.hasError) {
      AppToast.show(
        context,
        authState.error.toString(),
        type: AppToastType.error,
        role: selectedRole,
      );
      return;
    }

    AppToast.show(
      context,
      'Password reset successfully. Please log in again.'.tr(context),
      type: AppToastType.success,
      role: selectedRole,
    );
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.go(AppConstants.routeLogin);
    }
  }
}
