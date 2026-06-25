import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/validators.dart';
import 'custom_checkbox_with_label.dart';
import 'custom_form_field.dart';
import 'custom_submit_button.dart';
import 'toggle_button_group.dart';

/// SignUp form widget that handles all signup-related fields and validation
class SignupForm extends StatefulWidget {
  final Future<void> Function(Gender gender) onSubmit;
  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;
  final RoleThemeConfig? themeConfig;

  const SignupForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    this.themeConfig,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Gender? _selectedGender;
  bool _dataAgreement = false;

  // ── Phone uniqueness check state ──────────────────────────────────────────
  bool _checkingPhone = false;
  bool? _phoneAvailable; // null = not checked yet, true = ok, false = taken
  String _lastCheckedPhone = '';
  Timer? _phoneDebounce;

  @override
  void dispose() {
    _phoneDebounce?.cancel();
    super.dispose();
  }

  String? _validateName(String? value) => Validators.validateName(value);

  // Synchronous validator — also checks the async result cached in _phoneAvailable.
  String? _validatePhone(String? value) {
    final basic = Validators.validatePhone(value);
    if (basic != null) return basic;
    if (_phoneAvailable == false) {
      return 'This phone number is already registered.';
    }
    return null;
  }

  /// No longer querying Firebase for phone availability. Let the backend handle validation.
  void _onPhoneChanged(String value) {
    // Keep this empty or just setState if you want.
    // The Laravel backend will handle uniqueness validation.
  }

  String? _validateEmail(String? value) => Validators.validateEmail(value);

  String? _validatePassword(String? value) =>
      Validators.validatePassword(value);

  String? _validateConfirmPassword(String? value) =>
      Validators.validateConfirmPassword(value, widget.passwordController.text);

  bool get isFormValid =>
      _selectedGender != null &&
      _dataAgreement &&
      (widget.formKey.currentState?.validate() ?? false);

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      AppToast.show(
        context,
        AppStrings.genderRequired,
        type: AppToastType.warning,
        role: UserRole.patient,
      );
      return;
    }

    if (!_dataAgreement) {
      AppToast.show(
        context,
        AppStrings.dataAgreementRequired,
        type: AppToastType.warning,
        role: UserRole.patient,
      );
      return;
    }

    unawaited(widget.onSubmit(_selectedGender!));
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.themeConfig?.iconColor ?? AppColors.tealP;

    return Form(
      key: widget.formKey,
      child: Column(
        key: const ValueKey('signup-fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: widget.nameController,
            label: AppStrings.fullName,
            hint: AppStrings.fullNameHelper,
            validator: _validateName,
            suffixIcon: _themedSvgIcon(AppImages.accountCircleSvg, iconColor),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: widget.phoneController,
            label: AppStrings.phoneNumber,
            hint: AppStrings.phoneHelper,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
            onChanged: _onPhoneChanged,
            suffixIcon: _phoneStatusIcon(iconColor),
          ),
          const SizedBox(height: 12),
          _buildGenderSelector(),
          const SizedBox(height: 12),
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
          _buildConfirmPasswordField(),
          const SizedBox(height: 24),
          _buildDataAgreement(),
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
    void Function(String)? onChanged,
  }) {
    return CustomFormField(
      controller: controller,
      label: label,
      helperText: hint,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      focusedBorderColor:
          widget.themeConfig?.primaryDarkColor ?? AppColors.tealP,
      suffixIcon: suffixIcon,
    );
  }

  /// Shows a spinner / check / X in the phone field suffix.
  Widget _phoneStatusIcon(Color defaultColor) {
    if (_checkingPhone) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_phoneAvailable == true) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
      );
    }
    if (_phoneAvailable == false) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.cancel_rounded, color: Colors.red, size: 22),
      );
    }
    // Default: phone svg icon
    return _themedSvgIcon(AppImages.phoneLogoSvg, defaultColor);
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

  Widget _buildConfirmPasswordField() {
    final iconColor = widget.themeConfig?.iconColor ?? AppColors.tealP;

    return CustomFormField(
      controller: widget.confirmPasswordController,
      label: AppStrings.confirmPassword,
      helperText: AppStrings.confirmPasswordHelper.tr(context),
      validator: _validateConfirmPassword,
      obscureText: _obscureConfirmPassword,
      focusedBorderColor: iconColor,
      suffixIcon: IconButton(
        icon: _themedSvgIcon(
          _obscureConfirmPassword
              ? AppImages.viewLogoSvg
              : AppImages.passwordOffSvg,
          iconColor,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
    );
  }

  Widget _buildGenderSelector() {
    final theme = widget.themeConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleButtonGroup(
          firstLabel: AppStrings.male,
          secondLabel: AppStrings.female,
          isFirstSelected: _selectedGender == Gender.male,
          onFirstTap: () => setState(() => _selectedGender = Gender.male),
          onSecondTap: () => setState(() => _selectedGender = Gender.female),
          borderColor: theme?.getToggleBorderColor() ?? AppColors.neutral400,
          activeBackgroundColor: theme?.primaryDarkColor,
          inactiveBackgroundColor: AppColors.white,
          activeTextColor: theme?.surfaceColor,
          inactiveTextColor: Colors.black.withValues(alpha: 0.20),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
          child: Text(
            AppStrings.genderHelper.tr(context),
            style: AppTextStyles.formHelperNeutral12Regular,
          ),
        ),
      ],
    );
  }

  Widget _buildDataAgreement() {
    return CustomCheckboxWithLabel(
      value: _dataAgreement,
      onChanged: () => setState(() => _dataAgreement = !_dataAgreement),
      label: AppStrings.dataAgreement,
      description: AppStrings.dataAgreementText,
      activeColor: widget.themeConfig?.iconColor ?? AppColors.tealP,
      linkWidget: GestureDetector(
        onTap: () {
          _showPrivacyPolicyDialog(context);
        },
        child: Text(
          AppStrings.privacyPolicy.tr(context),
          style: AppTextStyles.privacyPolicyLinkInter14ExtraBold.copyWith(
            color: Color(
              int.parse(
                (widget.themeConfig?.privacyPolicyHighlightColor ?? '#24ABBD')
                    .replaceFirst('#', '0xFF'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    final theme =
        widget.themeConfig ?? RoleThemeConfig.fromRole(UserRole.patient);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 515, maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Privacy Policy Agreement'.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryDarkColor,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  height: 1,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please read our Privacy Policy carefully:'.tr(
                            context,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Inter',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPolicySection(
                          title: '1. Data Collection'.tr(context),
                          content:
                              'We collect health parameters (like heart rate and oxygen levels) from connected smartwatch devices to predict and prevent stroke risks.'
                                  .tr(context),
                          accentColor: theme.primaryDarkColor,
                        ),
                        const SizedBox(height: 16),
                        _buildPolicySection(
                          title: '2. Data Security'.tr(context),
                          content:
                              'Your medical data is encrypted and securely stored on Firebase, accessible only to you and your authorized healthcare providers.'
                                  .tr(context),
                          accentColor: theme.primaryDarkColor,
                        ),
                        const SizedBox(height: 16),
                        _buildPolicySection(
                          title: '3. Sharing & Privacy'.tr(context),
                          content:
                              'We never sell or share your personal data with third parties for commercial purposes.'
                                  .tr(context),
                          accentColor: theme.primaryDarkColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonColor,
                    foregroundColor: theme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Close'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: accentColor,
            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.neutral600,
            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
          ),
        ),
      ],
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
