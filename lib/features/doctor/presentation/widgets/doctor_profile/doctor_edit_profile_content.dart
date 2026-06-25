import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'doctor_avatar_panel.dart';
import 'gender_selector.dart';
import 'profile_input_card.dart';

class DoctorEditProfileContent extends StatelessWidget {
  const DoctorEditProfileContent({super.key, 
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.licenseController,
    required this.bioController,
    required this.isMale,
    required this.onGenderChanged,
    required this.onAvatarEdit,
    required this.onSave,
    this.photoUrl,
    this.yearsController,
    this.patientsCountController,
    this.specializationController,
    this.selectedImage,
    this.onImagePicked,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController licenseController;
  final TextEditingController bioController;
  final bool isMale;
  final ValueChanged<bool> onGenderChanged;
  final VoidCallback onAvatarEdit;
  final VoidCallback onSave;
  final String? photoUrl;
  final File? selectedImage;
  final ValueChanged<File>? onImagePicked;

  /// Optional controllers for additional doctor-specific fields.
  final TextEditingController? yearsController;
  final TextEditingController? patientsCountController;
  final TextEditingController? specializationController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoctorAvatarPanel(
          showIdentity: false,
          onAvatarEdit: onAvatarEdit,
          isEditMode: true,
          photoUrl: photoUrl,
          selectedImage: selectedImage,
          onImagePicked: onImagePicked,
        ),
        const SizedBox(height: 26),
        ProfileInputCard(
          label: 'Full name'.tr(context),
          controller: nameController,
          trailingIcon: Icons.edit_outlined,
        ),
        const SizedBox(height: 16),
        ProfileInputCard(
          label: 'Phone number'.tr(context),
          controller: phoneController,
          trailingIcon: Icons.edit_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        GenderSelector(isMale: isMale, onChanged: onGenderChanged),
        const SizedBox(height: 18),
        ProfileInputCard(
          label: 'Email'.tr(context),
          controller: emailController,
          trailingIcon: Icons.edit_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        ProfileInputCard(
          label: 'License number'.tr(context),
          controller: licenseController,
        ),
        if (specializationController != null) ...[
          const SizedBox(height: 16),
          ProfileInputCard(
            label: 'Specialization'.tr(context),
            controller: specializationController!,
          ),
        ],
        if (yearsController != null) ...[
          const SizedBox(height: 16),
          ProfileInputCard(
            label: 'Years of experience'.tr(context),
            controller: yearsController!,
            keyboardType: TextInputType.number,
          ),
        ],
        if (patientsCountController != null) ...[
          const SizedBox(height: 16),
          ProfileInputCard(
            label: 'Patients served'.tr(context),
            controller: patientsCountController!,
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 16),
        ProfileInputCard(label: 'Bio'.tr(context), controller: bioController, maxLines: 3),
        const SizedBox(height: 42),
        SizedBox(
          width: 201,
          height: 61,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: AppColors.shadowBlack25,
              backgroundColor: AppColors.redButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              'Save'.tr(context),
              style: AppTextStyles.doctorActionTextRedSurface27ExtraBold,
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}
