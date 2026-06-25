import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
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
import '../controllers/auth_providers.dart';
import '../controllers/role_controller.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_submit_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = ref.watch(roleProvider) ?? UserRole.patient;
    final themeConfig = RoleThemeConfig.fromRole(selectedRole);
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
                          // 'Forgot Password'.tr(context),
                          'Forgot Password',
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
                          'Enter your email address and we will send you an OTP to reset your password.'
                              .tr(context),
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
                        controller: _emailController,
                        label: 'Email Address'.tr(context),
                        helperText: 'e.g. user@example.com'.tr(context),
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        focusedBorderColor: themeConfig.primaryDarkColor,
                      ),
                      const SizedBox(height: 63),
                      Row(
                        children: [
                          Expanded(
                            child: CustomSubmitButton(
                              onTap: _isLoading ? null : _submit,
                              isLoading: _isLoading,
                              label: 'Send OTP'.tr(context),
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
          if (_isLoading)
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

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final selectedRole = (ref.read(roleProvider) ?? UserRole.patient).name;

    await ref
        .read(authControllerProvider.notifier)
        .sendOtp(email: email, role: selectedRole);

    final authState = ref.read(authControllerProvider);
    if (!mounted) return;

    if (authState.hasError) {
      setState(() => _isLoading = false);
      AppToast.show(
        context,
        authState.error.toString(),
        type: AppToastType.error,
        role: ref.read(roleProvider) ?? UserRole.patient,
      );
      return;
    }

    setState(() => _isLoading = false);
    AppToast.show(
      context,
      'OTP has been sent to your email!'.tr(context),
      type: AppToastType.success,
      role: ref.read(roleProvider) ?? UserRole.patient,
    );

    context.push(
      AppConstants.routeOtp,
      extra: {
        'phone':
            email, // Using the same key 'phone' or 'email', but let's pass it as phone for compatibility if other screens expect 'phone' variable name, or we can just pass 'email' since we'll modify OTP page anyway.
        'email': email,
      },
    );
  }
}
