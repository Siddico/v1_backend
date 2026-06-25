import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../core/utils/validators.dart';
import 'package:go_router/go_router.dart';
import 'custom_checkbox_with_label.dart';
import 'custom_form_field.dart';
import 'custom_submit_button.dart';

/// LogIn form widget that handles all login-related fields and validation
class LoginForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final RoleThemeConfig? themeConfig;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.themeConfig,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  String? _validateEmail(String? value) => Validators.validateEmail(value);

  String? _validatePassword(String? value) =>
      Validators.validatePassword(value);

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.themeConfig?.iconColor ?? AppColors.tealP;

    return Form(
      key: widget.formKey,
      child: Column(
        key: const ValueKey('login-fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: widget.emailController,
            label: AppStrings.email,
            hint: AppStrings.emailHelper,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: _themedSvgIcon(AppImages.emailLogoSvg, iconColor),
          ),
          const SizedBox(height: 12),
          _buildPasswordField(),
          const SizedBox(height: 12),
          _buildForgotPasswordRow(context),
          const SizedBox(height: 12),
          _buildRememberMeCheckbox(),
          const SizedBox(height: 24),
          CustomSubmitButton(
            onTap: widget.isLoading ? null : _submitForm,
            isLoading: widget.isLoading,
            label: AppStrings.submit,
            backgroundColor: widget.themeConfig?.buttonColor,
            textColor: widget.themeConfig?.surfaceColor,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? suffixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return CustomFormField(
      controller: controller,
      label: label,
      helperText: hint,
      validator: validator,
      keyboardType: keyboardType,
      focusedBorderColor:
          widget.themeConfig?.primaryDarkColor ?? AppColors.tealP,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildPasswordField() {
    final iconColor = widget.themeConfig?.iconColor ?? AppColors.tealP;

    return CustomFormField(
      controller: widget.passwordController,
      label: AppStrings.password,
      helperText: AppStrings.passwordHelper,
      validator: _validatePassword,
      obscureText: _obscurePassword,
      focusedBorderColor: iconColor,
      suffixIcon: IconButton(
        icon: _themedSvgIcon(
          _obscurePassword ? AppImages.viewLogoSvg : AppImages.passwordOffSvg,
          iconColor,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }

  Widget _buildForgotPasswordRow(BuildContext context) {
    final actionColor = widget.themeConfig?.primaryDarkColor ?? AppColors.tealP;

    return Column(
      children: [
        Row(
          children: [
            Text(
              (widget.themeConfig?.forgotPasswordHint ??
                  'If you forget your password ').tr(context),
              style: AppTextStyles.authHintNeutral450_12Medium,
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                context.push(AppConstants.routeForgot);
              },
              child: Text(
                'Click here',
                style: AppTextStyles.authActionLinkAladin14UnderlineShadow
                    .copyWith(color: actionColor),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Divider(height: 1, color: AppColors.neutralBlack),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return CustomCheckboxWithLabel(
      value: _rememberMe,
      onChanged: () => setState(() => _rememberMe = !_rememberMe),
      label: 'Remember me'.tr(context),
      activeColor: widget.themeConfig?.iconColor ?? AppColors.tealP,
    );
  }

  Widget _themedSvgIcon(String assetPath, Color color) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(
        assetPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
