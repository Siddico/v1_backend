import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';

import '../../../../shared/ui/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/floating_notification_button.dart';
import '../../../../shared/presentation/widgets/floating_chatbot_button.dart';
import '../../../../shared/presentation/widgets/logout_confirm_dialog.dart';
import '../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../injection/core_providers.dart';
import '../widgets/doctor_profile/doctor_edit_profile_content.dart';
import '../widgets/doctor_profile/doctor_profile_content.dart';
import '../../../../core/localization/app_localizations.dart';

class DoctorProfilePage extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onNavigate;

  const DoctorProfilePage({super.key, this.currentIndex = 3, this.onNavigate});

  @override
  ConsumerState<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends ConsumerState<DoctorProfilePage> {
  late int _currentNavIndex;
  bool _isDarkMode = false;
  bool _isEditMode = false;
  bool _isMale = true;
  UserEntity? _lastUser;
  File? _selectedImage;
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _licenseController;
  late final TextEditingController _bioController;
  late final TextEditingController _yearsController;
  late final TextEditingController _patientsCountController;
  late final TextEditingController _specializationController;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _licenseController = TextEditingController();
    _bioController = TextEditingController();
    _yearsController = TextEditingController();
    _patientsCountController = TextEditingController();
    _specializationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    _patientsCountController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });
    ToastService.showInfo('Saving your profile…'.tr(context));

    try {
      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();

      final formDataMap = <String, dynamic>{
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _isMale ? 'male' : 'female',
        'license_number': _licenseController.text.trim(),
        'bio': _bioController.text.trim(),
        'years_of_experience': _yearsController.text.trim(),
        'patients_count': _patientsCountController.text.trim(),
        'specialty': _specializationController.text.trim(),
      };

      final formData = FormData.fromMap(formDataMap);

      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: 'profile.jpg',
            ),
          ),
        );
      }

      await dio.post(
        ApiConstants.doctorProfile,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final userRepository = ref.read(userRepositoryProvider);

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _isMale ? 'male' : 'female',
      );
      await userRepository.updateUser(updatedUser);

      _selectedImage = null;
      ref.invalidate(authStateProvider);

      if (mounted) {
        setState(() {
          _isEditMode = false;
          _isLoading = false;
        });
        AppToast.show(
          context,
          'Doctor profile updated successfully.'.tr(context),
          type: AppToastType.success,
          role: UserRole.doctor,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppToast.show(
          context,
          '${'Error updating profile:'.tr(context)} $e',
          type: AppToastType.error,
          role: UserRole.doctor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user != null && user != _lastUser) {
      _lastUser = user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _isMale = user.gender?.toLowerCase() != 'female';

      final docProfile = user.doctorProfile;
      _licenseController.text = docProfile?['license_number']?.toString() ?? '';
      _bioController.text = docProfile?['bio']?.toString() ?? '';
      _yearsController.text = docProfile?['years_experience']?.toString() ?? '';
      _patientsCountController.text =
          docProfile?['patients_count']?.toString() ?? '';
      _specializationController.text =
          docProfile?['specialization']?.toString() ?? '';
    }

    final displayName = user?.name ?? 'Doctor'.tr(context);
    final displayEmail = user?.email ?? '';
    final displayBio = user?.doctorProfile?['bio']?.toString() ?? '';
    final specialist = user?.doctorProfile?['specialization']?.toString() ?? '';
    final yearsExperience =
        user?.doctorProfile?['years_experience']?.toString() ?? '';
    final patientsCount =
        user?.doctorProfile?['patients_count']?.toString() ?? '';
    final licenseNumber =
        user?.doctorProfile?['license_number']?.toString() ?? '';

    return PopScope(
      canPop: !_isEditMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditMode) {
          setState(() {
            _isEditMode = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      height: 237,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.redCoral,
                        borderRadius: BorderRadiusDirectional.only(
                          bottomStart: Radius.circular(28),
                          bottomEnd: Radius.circular(28),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        14,
                        125,
                        14,
                        0,
                      ),
                      child: _isEditMode
                          ? DoctorEditProfileContent(
                              nameController: _nameController,
                              phoneController: _phoneController,
                              emailController: _emailController,
                              licenseController: _licenseController,
                              bioController: _bioController,
                              isMale: _isMale,
                              photoUrl: user?.photoUrl,
                              selectedImage: _selectedImage,
                              onImagePicked: (file) {
                                setState(() {
                                  _selectedImage = file;
                                });
                              },
                              yearsController: _yearsController,
                              patientsCountController: _patientsCountController,
                              specializationController:
                                  _specializationController,
                              onGenderChanged: (value) {
                                setState(() {
                                  _isMale = value;
                                });
                              },
                              onAvatarEdit: () {
                                setState(() {
                                  _isEditMode = false;
                                });
                              },
                              onSave: _saveProfile,
                            )
                          : DoctorProfileContent(
                              displayName: displayName,
                              displayEmail: displayEmail,
                              displayPhone: _phoneController.text,
                              displayBio: displayBio,
                              photoUrl: user?.photoUrl,
                              specialist: specialist,
                              yearsExperience: yearsExperience,
                              patientsCount: patientsCount,
                              licenseNumber: licenseNumber,
                              onAvatarEdit: () {
                                setState(() {
                                  _isEditMode = true;
                                });
                              },
                              onLogout: () async {
                                final confirmed = await showLogoutConfirmDialog(
                                  context,
                                  colors: LogoutDialogColors.doctor,
                                );
                                if (confirmed == true) {
                                  if (context.mounted) {
                                    AppToast.show(
                                      context,
                                      'Logged out successfully.'.tr(context),
                                      type: AppToastType.success,
                                      role: UserRole.doctor,
                                    );
                                  }
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .logout();
                                }
                              },
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
                      darkModeToggleLightColor: AppColors.pinkLight,
                      darkModeToggleDarkColor: AppColors.redDeep,
                    ),
                  ],
                ),
              ),
            ),
            if (!_isEditMode) ...[
              FloatingNotificationButton(
                onTap: () => context.push(AppConstants.doctorNotifications),
                backgroundColor: AppColors.redDeep,
              ),
              const FloatingChatbotButton(),
            ],
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularLoadingIndicator(
                      size: 50,
                      color: AppColors.redDeep,
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _isEditMode
            ? null
            : CustomBottomNavBar(
                currentIndex: _currentNavIndex,
                onTap: _handleNavTap,
                labels: [
                  'Home'.tr(context),
                  'Search'.tr(context),
                  'Message'.tr(context),
                  'Profile'.tr(context),
                ],
                selectedIcons: const [
                  AppImages.homeSelectedSvg,
                  AppImages.searchSelectedSvg,
                  AppImages.messageLogoSvg,
                  AppImages.profileSelectedSvg,
                ],
                unselectedIcons: const [
                  AppImages.homeUnselectedSvg,
                  AppImages.searchUnselectedSvg,
                  AppImages.messageLogoSvg,
                  AppImages.profileUnselectedSvg,
                ],
                activeColor: AppColors.redDeep,
                inactiveColor: AppColors.redSoft,
                centerButtonColor: AppColors.redDeep,
                centerButtonBorderColor: AppColors.pinkLight,
                centerButtonIcon: AppImages.scanQrCodeSvg,
                centerButtonOnTap: () {
                  context.push(AppConstants.routeDoctorScanQr);
                },
              ),
      ),
    );
  }
}
