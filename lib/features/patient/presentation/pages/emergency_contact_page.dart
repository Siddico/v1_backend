import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/presentation/widgets/custom_form_field.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../injection/core_providers.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../core/localization/app_localizations.dart';

class EmergencyContactPage extends ConsumerStatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  ConsumerState<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends ConsumerState<EmergencyContactPage> {
  bool _isDarkMode = false;
  bool _isEditing = false;
  UserEntity? _lastUser;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact(UserEntity user) async {
    setState(() {
      _isEditing = false;
    });

    try {
      final userRepository = ref.read(userRepositoryProvider);
      
      // Update patient_profile document
      await userRepository.updatePatientProfile(user.id, {
        'emergency_number': _phoneController.text.trim(),
      });

      // Invalidate to refresh the profile content
      ref.invalidate(authStateProvider);

      if (mounted) {
        AppToast.show(
          context,
          'Emergency contact saved successfully.'.tr(context),
          type: AppToastType.success,
          role: UserRole.patient,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          '${'Error saving emergency contact: '.tr(context)}$e',
          type: AppToastType.error,
          role: UserRole.patient,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxContentWidth = size.width > 440 ? 420.0 : size.width - 24;

    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user != null && user != _lastUser) {
      _lastUser = user;
      final patientProfile = user.patientProfile;
      final emergencyPhone = patientProfile?['emergency_number']?.toString() ?? patientProfile?['emergency_contact_phone']?.toString() ?? '';
      _phoneController.text = emergencyPhone;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(top: 125, bottom: 140),
              child: SizedBox(
                width: maxContentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Emergency contact'.tr(context),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleTeal22BoldShadow,
                    ),
                    const SizedBox(height: 54),

                    // Emergency number field
                    CustomFormField(
                      controller: _phoneController,
                      label: 'Emergency number'.tr(context),
                      helperText:
                          'this number will appear in your profile with your closed doctor'.tr(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter emergency number'.tr(context);
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        // Change button
                        Expanded(
                          child: Container(
                            height: 61,
                            decoration: ShapeDecoration(
                              color: AppColors.tealP,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                              shadows: AppShadows.buttonShadow,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: AppRadius.button,
                                onTap: () {
                                  if (_isEditing) {
                                    if (user != null) {
                                      _saveContact(user);
                                    }
                                  } else {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    _isEditing ? 'Save'.tr(context) : 'Change'.tr(context),
                                    style: AppTextStyles
                                        .buttonTextTealSurface27ExtraBold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Back button
                        Expanded(
                          child: Container(
                            height: 61,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: AppColors.tealP,
                                ),
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: AppRadius.button,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Center(
                                  child: Text(
                                    'Back'.tr(context),
                                    style:
                                        AppTextStyles.buttonTextTeal27ExtraBold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: IgnorePointer(child: BottomBackgroundCircles()),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarControls(
              isDarkMode: _isDarkMode,
              onDarkModeToggle: () => setState(() => _isDarkMode = !_isDarkMode),
              onLanguageSelect: () {},
              darkModeToggleLightColor: AppColors.tealBorderLight,
              darkModeToggleDarkColor: AppColors.tealP,
            ),
          ),
        ],
      ),
    );
  }
}
