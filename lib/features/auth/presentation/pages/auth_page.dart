import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme_config.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../controllers/auth_providers.dart';
import '../controllers/role_controller.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/background_circle.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../widgets/toggle_button_group.dart';

/// Authentication view that handles both Sign Up and Log In flows
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _signupFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignupTab = true;
  bool _isDarkMode = false;

  String _homeRouteForRole(UserRole role) {
    if (role == UserRole.doctor) {
      return AppConstants.routeDoctorHome;
    }
    return AppConstants.routeHome;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(Gender gender) async {
    final selectedRole = ref.read(roleProvider);

    if (selectedRole == null) {
      AppToast.show(
        context,
        AppStrings.roleRequired,
        type: AppToastType.warning,
        role: UserRole.patient,
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signup(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          gender: gender,
          role: selectedRole,
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      if (mounted) {
        AppToast.show(
          context,
          authState.error.toString().tr(context),
          type: AppToastType.error,
          role: selectedRole,
        );
      }
      return;
    }

    if (mounted) {
      AppToast.show(
        context,
        'Account created successfully.'.tr(context),
        type: AppToastType.success,
        role: selectedRole,
      );
      final userRole = authState.valueOrNull?.role ?? selectedRole;
      context.go(_homeRouteForRole(userRole));
    }
  }

  Future<void> _handleLogin() async {
    final selectedRole = ref.read(roleProvider);

    if (selectedRole == null) {
      AppToast.show(
        context,
        AppStrings.roleRequired,
        type: AppToastType.warning,
        role: UserRole.patient,
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          selectedRole: selectedRole,
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      if (mounted) {
        AppToast.show(
          context,
          authState.error.toString().tr(context),
          type: AppToastType.error,
          role: selectedRole,
        );
      }
      return;
    }

    if (mounted) {
      AppToast.show(
        context,
        'Logged in successfully.'.tr(context),
        type: AppToastType.success,
        role: selectedRole,
      );
      final userRole = authState.valueOrNull?.role ?? selectedRole;
      context.go(_homeRouteForRole(userRole));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final selectedRole = ref.watch(roleProvider) ?? UserRole.patient;
    final isLoading = authState.isLoading;

    final themeConfig = RoleThemeConfig.fromRole(selectedRole);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsetsDirectional.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(themeConfig),
                _buildFormContent(isLoading, themeConfig),
              ],
            ),
          ),
          if (isLoading)
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

  Widget _buildHeader(RoleThemeConfig themeConfig) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleScale = (screenWidth / 402).clamp(0.76, 1.0);
    final subtitleScale = (screenWidth / 402).clamp(0.84, 1.0);

    return SizedBox(
      height: 305,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -48,
            right: -48,
            top: -163,
            child: BackgroundCircle(
              width: 500,
              height: 488,
              color: themeConfig.primaryColor,
              shadows: themeConfig.getCircleShadows(),
            ),
          ),
          Positioned(
            left: -48,
            right: -48,
            top: -156,
            child: BackgroundCircle(
              width: 500,
              height: 488,
              color: AppColors.white,
              shadows: const [
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
            left: 110,
            right: 110,
            top: -67,
            child: BackgroundCircle(
              width: 136,
              height: 135,
              color: themeConfig.accentColor,
            ),
          ),
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
          Positioned(
            left: 0,
            right: 0,
            top: 100,
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.88,
                  child: Text(
                    _isSignupTab
                        ? themeConfig.signupTitle
                        : themeConfig.loginTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.authHeroTitleCroissant50TealDark
                        .copyWith(
                          fontSize: 50 * titleScale,
                          color: _isSignupTab
                              ? themeConfig.signupTitleColor
                              : themeConfig.loginTitleColor,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    (_isSignupTab
                            ? themeConfig.signupSubtitle
                            : themeConfig.loginSubtitle)
                        .tr(context),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.authSubtitleNeutral550_22.copyWith(
                      fontSize: 22 * subtitleScale,
                      color: _isSignupTab
                          ? themeConfig.signupDescriptionColor
                          : themeConfig.loginDescriptionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isLoading, RoleThemeConfig themeConfig) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 70),
          _buildTabButtons(themeConfig),
          const SizedBox(height: 30),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
            crossFadeState: _isSignupTab
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: SignupForm(
              key: const ValueKey('signup-form'),
              onSubmit: _handleSignup,
              isLoading: isLoading,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              formKey: _signupFormKey,
              themeConfig: themeConfig,
            ),
            secondChild: LoginForm(
              key: const ValueKey('login-form'),
              onSubmit: _handleLogin,
              isLoading: isLoading,
              emailController: _emailController,
              passwordController: _passwordController,
              formKey: _loginFormKey,
              themeConfig: themeConfig,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons(RoleThemeConfig themeConfig) {
    return ToggleButtonGroup(
      firstLabel: 'Sign up',
      secondLabel: 'Log-in',
      isFirstSelected: _isSignupTab,
      onFirstTap: () => setState(() => _isSignupTab = true),
      onSecondTap: () => setState(() => _isSignupTab = false),
      borderColor: themeConfig.getToggleInactiveBorderColor(),
      activeBackgroundColor: themeConfig.primaryDarkColor,
      inactiveBackgroundColor: AppColors.white,
      activeTextColor: themeConfig.surfaceColor,
      inactiveTextColor: Colors.black,
    );
  }
}
