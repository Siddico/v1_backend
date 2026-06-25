import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../../shared/presentation/widgets/call/otp_box.dart';
import '../controllers/auth_providers.dart';
import '../controllers/role_controller.dart';
import '../../domain/password_reset_session.dart';
import '../widgets/custom_submit_button.dart';


class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key, this.phone, this.verificationId, this.email});

  final String? phone;
  final String? email;
  final String? verificationId;

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
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
          AppBarControls(
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
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsetsDirectional.only(
              top: 117,
              end: 20,
              start: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.9,
                  child: Text(
                    AppStrings.enterOtp,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authHeroTitleCroissant50TealDark
                        .copyWith(
                          fontSize: 50 * titleScale,
                          color: themeConfig.otpTitleColor,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter the 6-digit code sent to your email to verify your identity.'.tr(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.authSubtitleNeutral550_22.copyWith(
                    fontSize: 22 * subtitleScale,
                    color: themeConfig.otpDescriptionColor,
                  ),
                ),
                const SizedBox(height: 32),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: AppTextStyles.textStyleFontsize20WithWeight600AndBlackColor.copyWith(
                        fontSize: 22,
                        color: themeConfig.primaryDarkColor,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.otpBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack25,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: AppTextStyles.textStyleFontsize20WithWeight600AndBlackColor.copyWith(
                        fontSize: 22,
                        color: themeConfig.primaryDarkColor,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeConfig.primaryDarkColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack25,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 62.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'If you want to change your email'.tr(context),
                            style: AppTextStyles.authHintNeutral450_12Medium,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              'Change now',
                              style: AppTextStyles
                                  .authActionLinkAladin14UnderlineShadow
                                  .copyWith(
                                    color: themeConfig.primaryDarkColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: double.infinity,
                        child: Divider(
                          height: 1,
                          color: AppColors.neutralBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 201,
                      child: CustomSubmitButton(
                        onTap: _isLoading ? null : _submit,
                        isLoading: _isLoading,
                        label: AppStrings.submit,
                        backgroundColor: themeConfig.buttonColor,
                        textColor: themeConfig.surfaceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BottomBackgroundCircles(themeConfig: themeConfig),
        ],
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _submit() async {
    final emailTarget = widget.email ?? widget.phone;
    final selectedRole = ref.read(roleProvider) ?? UserRole.patient;
    if (emailTarget == null || emailTarget.isEmpty) {
      if (!mounted) return;
      AppToast.show(
        context,
        'Missing verification session.'.tr(context),
        type: AppToastType.error,
        role: selectedRole,
      );
      return;
    }

    final enteredCode = _pinController.text;
    if (enteredCode.length != 6) {
      if (!mounted) return;
      AppToast.show(
        context,
        'Enter the full 6-digit OTP code.'.tr(context),
        type: AppToastType.warning,
        role: selectedRole,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ref.read(authControllerProvider.notifier).verifyOtp(
        email: emailTarget,
        code: enteredCode,
      );

      final authState = ref.read(authControllerProvider);
      if (!mounted) return;
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
        'OTP verified successfully.'.tr(context),
        type: AppToastType.success,
        role: selectedRole,
      );
      
      context.push(
        AppConstants.routeResetPassword,
        extra: PasswordResetSession(email: emailTarget, otp: token),
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        '${'Invalid OTP code'.tr(context)}: $e',
        type: AppToastType.error,
        role: selectedRole,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
